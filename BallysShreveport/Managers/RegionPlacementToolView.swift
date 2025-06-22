import SwiftUI

#warning("Delete before publish - This is a development tool")

struct RegionPlacementToolView: View {
    @State private var regionData: [RegionDefinition] = []
    @State private var selectedRegionIndex: Int? = nil
    @State private var showingCode: Bool = false
    @State private var widthText: String = "80.0"
    @State private var heightText: String = "80.0"
    
    let screenWidth = UIScreen.main.bounds.height
    let screenHeight = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            gridOverlay
            
            // All 20 regions that can be dragged
            ForEach(regionData.indices, id: \.self) { index in
                let isSelected = selectedRegionIndex == index
                
                Image(regionData[index].shape.imageName)
                    .resizable()
                    .frame(width: regionData[index].width, height: regionData[index].height)
                    .opacity(isSelected ? 1.0 : 0.7)
                    .position(regionData[index].position)
                    .overlay(
                        VStack(spacing: 1) {
                            Text("\(regionData[index].country.rawValue)")
                                .font(.system(size: 10, weight: .bold))
                            Text("\(String(format: "%.1f", regionData[index].width))×\(String(format: "%.1f", regionData[index].height))")
                                .font(.system(size: 8))
                        }
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1)
                        .position(regionData[index].position)
                    )
                    .overlay(
                        Rectangle()
                            .stroke(Color.yellow, lineWidth: 2)
                            .frame(width: regionData[index].width, height: regionData[index].height)
                            .position(regionData[index].position)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .onTapGesture {
                        selectRegion(at: index)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                regionData[index].position = value.location
                            }
                    )
            }
            
            controlPanel
            
            if showingCode {
                codeOverlay
            }
        }
        .onAppear {
            if regionData.isEmpty {
                createAllRegions()
            }
        }
    }
    
    var gridOverlay: some View {
        Canvas { context, size in
            for y in stride(from: 0, to: size.height, by: 50) {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
                
                let yText = Text("\(Int(y))")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                context.draw(yText, at: CGPoint(x: 15, y: y))
            }
            
            for x in stride(from: 0, to: size.width, by: 50) {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
                
                let xText = Text("\(Int(x))")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                context.draw(xText, at: CGPoint(x: x, y: 15))
            }
        }
    }
    
    var controlPanel: some View {
        VStack {
            Spacer()
            
            HStack {
                if selectedRegionIndex != nil {
                    regionSizeControls
                    
                    Spacer()
                }
                
                Button {
                    generateCode()
                    showingCode.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Generate Code")
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.3))
            .cornerRadius(10)
        }
    }
    
    var regionSizeControls: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Text("Width:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("W", text: $widthText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .keyboardType(.decimalPad)
                    .onChange(of: widthText) { newValue in
                        updateRegionWidth(newValue)
                    }
            }
            
            HStack(spacing: 4) {
                Text("Height:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("H", text: $heightText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .keyboardType(.decimalPad)
                    .onChange(of: heightText) { newValue in
                        updateRegionHeight(newValue)
                    }
            }
        }
    }
    
    var codeOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    showingCode = false
                }
            
            VStack(spacing: 16) {
                Text("Code Generated!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("Code for LevelManager.swift has been printed to Xcode console.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Check the Debug console and copy the generated regions array.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Image(systemName: "terminal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                
                Button("Close") {
                    showingCode = false
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.bottom)
            }
            .frame(width: min(screenWidth * 0.5, 400))
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 10)
        }
    }
    
    private func createAllRegions() {
        regionData.removeAll()
        
        let defaultSize: CGFloat = 80.0
        let spacing: CGFloat = 100.0
        let startX: CGFloat = 120.0
        let startY: CGFloat = 100.0
        
        // USA regions (row 1)
        for i in 0..<5 {
            let region = RegionDefinition(
                shape: [RegionShape.usa1, .usa2, .usa3, .usa4, .usa5][i],
                position: CGPoint(x: startX + CGFloat(i) * spacing, y: startY),
                width: defaultSize,
                height: defaultSize,
                country: .usa
            )
            regionData.append(region)
        }
        
        // Iran regions (row 2)
        for i in 0..<5 {
            let region = RegionDefinition(
                shape: [RegionShape.iran1, .iran2, .iran3, .iran4, .iran5][i],
                position: CGPoint(x: startX + CGFloat(i) * spacing, y: startY + spacing),
                width: defaultSize,
                height: defaultSize,
                country: .iran
            )
            regionData.append(region)
        }
        
        // China regions (row 3)
        for i in 0..<5 {
            let region = RegionDefinition(
                shape: [RegionShape.china1, .china2, .china3, .china4, .china5][i],
                position: CGPoint(x: startX + CGFloat(i) * spacing, y: startY + spacing * 2),
                width: defaultSize,
                height: defaultSize,
                country: .china
            )
            regionData.append(region)
        }
        
        // North Korea regions (row 4)
        for i in 0..<5 {
            let region = RegionDefinition(
                shape: [RegionShape.nk1, .nk2, .nk3, .nk4, .nk5][i],
                position: CGPoint(x: startX + CGFloat(i) * spacing, y: startY + spacing * 3),
                width: defaultSize,
                height: defaultSize,
                country: .northKorea
            )
            regionData.append(region)
        }
    }
    
    private func selectRegion(at index: Int) {
        selectedRegionIndex = index
        let region = regionData[index]
        widthText = String(format: "%.2f", region.width)
        heightText = String(format: "%.2f", region.height)
    }
    
    private func updateRegionWidth(_ text: String) {
        guard let index = selectedRegionIndex,
              let width = Double(text),
              width > 0 else { return }
        
        regionData[index].width = CGFloat(width)
    }
    
    private func updateRegionHeight(_ text: String) {
        guard let index = selectedRegionIndex,
              let height = Double(text),
              height > 0 else { return }
        
        regionData[index].height = CGFloat(height)
    }
    
    private func generateCode() {
        var code = "// All 20 regions layout\n"
        code += "let regions = [\n"
        
        let countries: [CountryType] = [.usa, .iran, .china, .northKorea]
        
        for country in countries {
            let countryRegions = regionData.filter { $0.country == country }
            if !countryRegions.isEmpty {
                code += "    // \(country.rawValue) regions (\(countryRegions.count))\n"
                for region in countryRegions {
                    code += "    RegionDefinition(shape: .\(region.shape.rawValue), position: CGPoint(x: \(String(format: "%.1f", region.position.x)), y: \(String(format: "%.1f", region.position.y))), width: \(String(format: "%.2f", region.width)), height: \(String(format: "%.2f", region.height)), country: .\(region.country == .northKorea ? "northKorea" : region.country.rawValue.lowercased()), initialTroops: 0),\n"
                }
                code += "\n"
            }
        }
        
        code += "]\n"
        
        print("\n\n=== GENERATED CODE FOR LEVELMANAGER.SWIFT ===\n")
        print(code)
        print("=== END OF GENERATED CODE ===\n\n")
        
        showingCode = true
    }
}

#Preview {
    RegionPlacementToolView()
}
