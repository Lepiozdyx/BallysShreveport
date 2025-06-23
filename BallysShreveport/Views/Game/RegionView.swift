import SwiftUI

struct RegionView: View {
    let regionDef: RegionDefinition
    let countryIndex: Int
    let regionIndex: Int
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Image(regionDef.shape.imageName)
                .resizable()
                .frame(width: regionDef.width, height: regionDef.height)
                .opacity(regionOpacity)
                .colorMultiply(regionColorMultiplier)
                .onTapGesture {
                    viewModel.handleRegionTap(
                        countryIndex: countryIndex,
                        regionIndex: regionIndex,
                        position: regionDef.position
                    )
                }
                .animation(.easeInOut(duration: 1.5), value: viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex))
            
            if viewModel.regionHasAirDefense(countryIndex: countryIndex, regionIndex: regionIndex) {
                Image(.airdefense)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .opacity(regionOpacity)
                    .animation(.easeInOut(duration: 1.5), value: viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex))
            }
        }
    }
    
    private var regionOpacity: Double {
        viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) ? 0.5 : 1.0
    }
    
    private var regionColorMultiplier: Color {
        if viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) {
            return .gray
        }
        
        // Targeting phase - highlight targeted enemy regions in red
        if viewModel.currentPhase == .targeting &&
           !viewModel.isHumanRegion(countryIndex: countryIndex) &&
           viewModel.isRegionTargeted(countryIndex: countryIndex, regionIndex: regionIndex) {
            return .red.opacity(0.5)
        }
        
        // Economy phase - highlight selected human region in blue
        if viewModel.currentPhase == .economy &&
           viewModel.selectedRegionIndex == regionIndex &&
           viewModel.isHumanRegion(countryIndex: countryIndex) {
            return .blue.opacity(0.3)
        }
        
        return .white
    }
}

#Preview {
    let sampleRegion = RegionDefinition(
        shape: .usa1,
        position: CGPoint(x: 100, y: 100),
        width: 80,
        height: 80,
        country: .usa
    )
    
    RegionView(
        regionDef: sampleRegion,
        countryIndex: 0,
        regionIndex: 0,
        viewModel: GameViewModel(gameManager: GameManager())
    )
}
