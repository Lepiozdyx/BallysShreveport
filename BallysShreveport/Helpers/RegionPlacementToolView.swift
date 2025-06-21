////
////  RegionPlacementToolView.swift
////  BallysShreveport
////
////  Created by Alex on 20.06.2025.
////
//
//import SwiftUI
//
//#warning("delete before publish")
///// Инструмент для визуального размещения регионов на карте
//struct RegionPlacementToolView: View {
//    // Массив для хранения данных о размещаемых регионах
//    @State private var regionData: [RegionPlacementData] = []
//    
//    // Текущий выбранный регион (для редактирования)
//    @State private var selectedRegionIndex: Int? = nil
//    
//    // Выбранный тип региона для добавления
//    @State private var selectedShapeIndex = 0
//    @State private var selectedOwnerIndex = 0
//    @State private var initialTroops: Int = 0
//    @State private var regionWidth: CGFloat = 180
//    @State private var regionHeight: CGFloat = 180
//    
//    // Уникальный идентификатор для регионов (для перемещения)
//    @State private var nextId: Int = 1
//    
//    // Вспомогательные массивы для выбора параметров
//    let availableShapes: [ImageResource] = [.usa1, .usa2, .usa3, .usa4, .usa5, .iran1, .iran2, .iran3, .iran4, .iran5, .china1, .china2, .china3, .china4, .china5, .nk1, .nk2, .nk3, .nk4, .nk5]
//    
//    let availableOwners: [Player] = [.usa, .iran, .china, .nk]
//    
//    // Генерируемый код
//    @State private var generatedCode: String = ""
//    @State private var showingCode: Bool = false
//    
//    // Размеры экрана для лучшего понимания масштаба
//    let screenWidth = UIScreen.main.bounds.height
//    let screenHeight = UIScreen.main.bounds.width
//    
//    // Режим редактирования размера
//    @State private var isResizeMode: Bool = false
//    
//    var body: some View {
//        ZStack {
//            BackgroundView()
//            
//            // Сетка для ориентации (каждые 50 точек)
//            gridOverlay
//            
//            // Регионы, которые можно перетаскивать
//            ForEach(regionData.indices, id: \.self) { index in
//                let isSelected = selectedRegionIndex == index
//                
//                Image(regionData[index].shape)
//                    .resizable()
//                    .frame(width: regionData[index].width, height: regionData[index].height)
//                    .colorMultiply(regionData[index].owner.color)
//                    .opacity(isSelected ? 0.8 : 0.6)
//                    .position(regionData[index].position)
//                    .overlay(
//                        // Текст с координатами и информацией
//                        VStack(spacing: 2) {
//                            Text("\(regionData[index].owner.rawValue)")
//                                .font(.system(size: 14, weight: .bold))
//                            Text("\(Int(regionData[index].position.x)),\(Int(regionData[index].position.y))")
//                                .font(.system(size: 12))
//                            Text("\(Int(regionData[index].width))×\(Int(regionData[index].height))")
//                                .font(.system(size: 10))
//                            if regionData[index].owner != .neutral {
//                                Text("💪 \(regionData[index].initialTroops)")
//                                    .font(.system(size: 14, weight: .bold))
//                            }
//                        }
//                        .foregroundColor(.white)
//                        .shadow(color: .black, radius: 1)
//                        .position(regionData[index].position)
//                    )
//                    .overlay(
//                        // Индикатор выбора
//                        Circle()
//                            .stroke(Color.yellow, lineWidth: 3)
//                            .frame(width: max(regionData[index].width, regionData[index].height) + 10,
//                                   height: max(regionData[index].width, regionData[index].height) + 10)
//                            .position(regionData[index].position)
//                            .opacity(isSelected ? 1 : 0)
//                    )
//                    // Ручки изменения размера
//                    .overlay(
//                        Group {
//                            if isSelected && isResizeMode {
//                                // Ручка изменения размера (нижний правый угол)
//                                Circle()
//                                    .fill(Color.yellow)
//                                    .frame(width: 20, height: 20)
//                                    .position(
//                                        x: regionData[index].position.x + regionData[index].width/2,
//                                        y: regionData[index].position.y + regionData[index].height/2
//                                    )
//                                    .gesture(
//                                        DragGesture()
//                                            .onChanged { value in
//                                                let deltaX = value.location.x - regionData[index].position.x
//                                                let deltaY = value.location.y - regionData[index].position.y
//                                                
//                                                // Обновляем размер, но не меньше 60x60
//                                                regionData[index].width = max(abs(deltaX) * 2, 60)
//                                                regionData[index].height = max(abs(deltaY) * 2, 60)
//                                            }
//                                    )
//                            }
//                        }
//                    )
//                    .onTapGesture {
//                        selectedRegionIndex = index
//                    }
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                // Перемещаем регион при перетаскивании, только если не в режиме изменения размера
//                                if selectedRegionIndex == index && !isResizeMode {
//                                    regionData[index].position = value.location
//                                }
//                            }
//                    )
//            }
//            
//            // Панель управления в нижней части экрана
//            VStack {
//                Spacer()
//                
//                HStack {
//                    // Информация о размерах экрана
//                    VStack(alignment: .leading) {
//                        Text("Экран: \(Int(screenWidth)) × \(Int(screenHeight))")
//                            .font(.caption)
//                        if let idx = selectedRegionIndex {
//                            Text("Выбрано: \(idx + 1), \(availableOwners[regionData[idx].ownerIndex].rawValue)")
//                                .font(.caption)
//                        }
//                    }
//                    .frame(width: 120, alignment: .leading)
//                    
//                    // Кнопки управления
//                    HStack(spacing: 15) {
//                        // Добавить новый регион
//                        Button {
//                            addNewRegion()
//                        } label: {
//                            Image(systemName: "plus.circle.fill")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                                .foregroundColor(.green)
//                        }
//                        
//                        // Удалить выбранный регион
//                        Button {
//                            if let index = selectedRegionIndex {
//                                regionData.remove(at: index)
//                                selectedRegionIndex = nil
//                            }
//                        } label: {
//                            Image(systemName: "trash.circle.fill")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                                .foregroundColor(.red)
//                        }
//                        .disabled(selectedRegionIndex == nil)
//                        
//                        // Переключатель режима изменения размера
//                        Button {
//                            isResizeMode.toggle()
//                        } label: {
//                            Image(systemName: isResizeMode ? "arrow.up.left.and.arrow.down.right.circle.fill" : "arrow.up.left.and.arrow.down.right.circle")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                                .foregroundColor(.orange)
//                        }
//                        .disabled(selectedRegionIndex == nil)
//                        
//                        // Сгенерировать код
//                        Button {
//                            generateCode()
//                            showingCode.toggle()
//                        } label: {
//                            Image(systemName: "doc.on.doc.fill")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    
//                    Spacer()
//                    
//                    // Выбор параметров для нового/выбранного региона
//                    if selectedRegionIndex == nil {
//                        // Для создания нового региона
//                        VStack {
//                            HStack {
//                                // Выбор формы
//                                Picker("", selection: $selectedShapeIndex) {
//                                    ForEach(0..<availableShapes.count, id: \.self) { index in
//                                        Image(availableShapes[index])
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 30, height: 30)
//                                            .tag(index)
//                                    }
//                                }
//                                .frame(width: 60)
//                                
//                                // Выбор владельца
//                                Picker("", selection: $selectedOwnerIndex) {
//                                    ForEach(0..<availableOwners.count, id: \.self) { index in
//                                        Text(availableOwners[index].rawValue)
//                                            .foregroundColor(availableOwners[index].color)
//                                            .tag(index)
//                                    }
//                                }
//                                .frame(width: 80)
//                                
//                                // Количество войск
//                                if selectedOwnerIndex != 2 { // Не показывать для нейтральных
//                                    Stepper("\(initialTroops)", value: $initialTroops, in: 0...50)
//                                        .frame(width: 120)
//                                }
//                            }
//                            
//                            // Настройка размера нового региона
//                            HStack {
//                                Text("Размер:")
//                                    .font(.caption)
//                                
//                                Slider(value: $regionWidth, in: 60...300, step: 10)
//                                    .frame(width: 100)
//                                
//                                Text("\(Int(regionWidth))×\(Int(regionHeight))")
//                                    .font(.caption)
//                                
//                                Slider(value: $regionHeight, in: 60...300, step: 10)
//                                    .frame(width: 100)
//                            }
//                        }
//                    } else {
//                        // Для редактирования выбранного региона
//                        VStack {
//                            HStack {
//                                // Выбор владельца
//                                Picker("", selection: $regionData[selectedRegionIndex!].ownerIndex) {
//                                    ForEach(0..<availableOwners.count, id: \.self) { index in
//                                        Text(availableOwners[index].rawValue)
//                                            .foregroundColor(availableOwners[index].color)
//                                            .tag(index)
//                                    }
//                                }
//                                .frame(width: 80)
//                                
//                                // Количество войск
//                                if regionData[selectedRegionIndex!].owner != .neutral {
//                                    Stepper("\(regionData[selectedRegionIndex!].initialTroops)",
//                                            value: $regionData[selectedRegionIndex!].initialTroops,
//                                            in: 0...50)
//                                        .frame(width: 120)
//                                }
//                            }
//                            
//                            // Точная настройка размера выбранного региона
//                            HStack {
//                                Text("W:")
//                                    .font(.caption)
//                                
//                                Slider(value: $regionData[selectedRegionIndex!].width, in: 60...300, step: 10)
//                                    .frame(width: 100)
//                                
//                                Text("\(Int(regionData[selectedRegionIndex!].width))×\(Int(regionData[selectedRegionIndex!].height))")
//                                    .font(.caption)
//                                
//                                Text("H:")
//                                    .font(.caption)
//                                
//                                Slider(value: $regionData[selectedRegionIndex!].height, in: 60...300, step: 10)
//                                    .frame(width: 100)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .background(Color.white.opacity(0.3))
//                .cornerRadius(10)
//            }
//            
//            // Всплывающее окно с сгенерированным кодом
//            if showingCode {
//                codeOverlay
//            }
//            
//            // Индикатор режима изменения размера
//            if isResizeMode && selectedRegionIndex != nil {
//                VStack {
//                    HStack {
//                        Text("РЕЖИМ ИЗМЕНЕНИЯ РАЗМЕРА")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding(8)
//                            .background(Color.orange)
//                            .cornerRadius(8)
//                    }
//                    .padding(.top)
//                    
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    // Сетка для ориентации
//    var gridOverlay: some View {
//        Canvas { context, size in
//            // Горизонтальные линии (каждые 50 точек)
//            for y in stride(from: 0, to: size.height, by: 50) {
//                let path = Path { p in
//                    p.move(to: CGPoint(x: 0, y: y))
//                    p.addLine(to: CGPoint(x: size.width, y: y))
//                }
//                context.stroke(path, with: .color(.gray.opacity(0.5)), lineWidth: 1)
//                
//                // Добавляем метки координат по Y
//                let yText = Text("\(Int(y))")
//                    .font(.system(size: 10))
//                    .foregroundColor(.gray)
//                context.draw(yText, at: CGPoint(x: 15, y: y))
//            }
//            
//            // Вертикальные линии (каждые 50 точек)
//            for x in stride(from: 0, to: size.width, by: 50) {
//                let path = Path { p in
//                    p.move(to: CGPoint(x: x, y: 0))
//                    p.addLine(to: CGPoint(x: x, y: size.height))
//                }
//                context.stroke(path, with: .color(.gray.opacity(0.5)), lineWidth: 1)
//                
//                // Добавляем метки координат по X
//                let xText = Text("\(Int(x))")
//                    .font(.system(size: 10))
//                    .foregroundColor(.gray)
//                context.draw(xText, at: CGPoint(x: x, y: 15))
//            }
//        }
//    }
//    
//    // Всплывающее окно с сгенерированным кодом
//    var codeOverlay: some View {
//        ZStack {
//            // Затемнение фона
//            Color.black.opacity(0.7)
//                .ignoresSafeArea()
//                .onTapGesture {
//                    showingCode = false
//                }
//            
//            // Окно с информацией
//            VStack {
//                Text("Код сгенерирован!")
//                    .font(.headline)
//                    .padding(.top)
//                
//                Text("Код для вставки в GameLevel.swift выведен в консоль Xcode.")
//                    .font(.subheadline)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                    .padding(.bottom, 5)
//                
//                Text("Пожалуйста, проверьте консоль Debug внизу окна Xcode и скопируйте сгенерированный код.")
//                    .font(.caption)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                Divider()
//                    .padding(.vertical)
//                
//                Image(systemName: "terminal")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 60, height: 60)
//                    .foregroundColor(.blue)
//                    .padding()
//                
//                Button("Закрыть") {
//                    showingCode = false
//                }
//                .padding()
//            }
//            .frame(width: screenWidth * 0.6)
//            .background(Color.white)
//            .cornerRadius(15)
//            .shadow(radius: 10)
//        }
//    }
//    
//    // Получить название ресурса изображения
//    private func getImageResourceName(_ resource: ImageResource) -> String {
//        // Получаем строку из имени ресурса
//        // В Xcode имя ресурса автоматически доступно как .vector1, .vector2 и т.д.
//        let fullName = String(describing: resource)
//        
//        // Извлекаем только имя без дополнительной информации
//        if let range = fullName.range(of: "name: ") {
//            let nameStart = range.upperBound
//            if let endRange = fullName[nameStart...].range(of: ",") {
//                return String(fullName[nameStart..<endRange.lowerBound])
//            }
//            return String(fullName[nameStart...])
//        }
//        
//        // Запасной вариант - возвращаем индекс из массива
//        for (index, shape) in availableShapes.enumerated() {
//            if shape == resource {
//                return "vector\(index + 1)"
//            }
//        }
//        
//        return "unknownVector"
//    }
//    
//    // Добавление нового региона
//    private func addNewRegion() {
//        let newRegion = RegionPlacementData(
//            id: nextId,
//            shape: availableShapes[selectedShapeIndex],
//            position: CGPoint(x: screenWidth / 2, y: screenHeight / 2),
//            width: regionWidth,
//            height: regionHeight,
//            ownerIndex: selectedOwnerIndex,
//            initialTroops: initialTroops,
//            availableOwners: availableOwners
//        )
//        
//        regionData.append(newRegion)
//        selectedRegionIndex = regionData.count - 1
//        nextId += 1
//    }
//    
//    // Генерация кода для GameLevel.swift
//    private func generateCode() {
//        var code = "// Уровень с \(regionData.count) регионами\n"
//        code += "GameLevel(id: 1, regions: [\n"
//        
//        // Группируем регионы по владельцам для лучшей организации
//        let usaRegions = regionData.filter { $0.owner == .usa }
//        let chinaRegions = regionData.filter { $0.owner == .china }
//        let iranRegions = regionData.filter { $0.owner == .iran }
//        let nkRegions = regionData.filter { $0.owner == .nk }
//        
//        //
//        if !usaRegions.isEmpty {
//            code += "    // Регионы игрока (\(usaRegions.count))\n"
//            for region in usaRegions {
//                let shapeName = getImageResourceName(region.shape)
//                code += "    RegionDefinition(shape: .\(shapeName), position: CGPoint(x: \(Int(region.position.x)), y: \(Int(region.position.y))), width: \(Int(region.width)), height: \(Int(region.height)), owner: .player, initialTroops: \(region.initialTroops)),\n"
//            }
//            code += "\n"
//        }
//        
//        //
//        if !chinaRegions.isEmpty {
//            code += "    // Регионы CPU (\(chinaRegions.count))\n"
//            for region in chinaRegions {
//                let shapeName = getImageResourceName(region.shape)
//                code += "    RegionDefinition(shape: .\(shapeName), position: CGPoint(x: \(Int(region.position.x)), y: \(Int(region.position.y))), width: \(Int(region.width)), height: \(Int(region.height)), owner: .cpu, initialTroops: \(region.initialTroops)),\n"
//            }
//            code += "\n"
//        }
//        
//        //
//        if !iranRegions.isEmpty {
//            code += "    // Нейтральные регионы (\(iranRegions.count))\n"
//            for region in iranRegions {
//                let shapeName = getImageResourceName(region.shape)
//                code += "    RegionDefinition(shape: .\(shapeName), position: CGPoint(x: \(Int(region.position.x)), y: \(Int(region.position.y))), width: \(Int(region.width)), height: \(Int(region.height)), owner: .neutral, initialTroops: \(region.initialTroops)),\n"
//            }
//        }
//        
//        //
//        if !nkRegions.isEmpty {
//            code += "    // Нейтральные регионы (\(nkRegions.count))\n"
//            for region in nkRegions {
//                let shapeName = getImageResourceName(region.shape)
//                code += "    RegionDefinition(shape: .\(shapeName), position: CGPoint(x: \(Int(region.position.x)), y: \(Int(region.position.y))), width: \(Int(region.width)), height: \(Int(region.height)), owner: .neutral, initialTroops: \(region.initialTroops)),\n"
//            }
//        }
//        
//        code += "]),\n"
//        
//        // Сохраняем сгенерированный код во внутреннюю переменную
//        generatedCode = code
//        
//        // НОВОЕ: Выводим код напрямую в консоль Xcode
//        print("\n\n=== СГЕНЕРИРОВАННЫЙ КОД ДЛЯ ВСТАВКИ В GAMELEVEL.SWIFT ===\n")
//        print(code)
//        print("=== КОНЕЦ СГЕНЕРИРОВАННОГО КОДА ===\n\n")
//        
//        // Показываем информационное сообщение
//        showingCode = true
//    }
//}
//
//// Структура для хранения данных о размещаемом регионе
//struct RegionPlacementData {
//    let id: Int
//    let shape: ImageResource
//    var position: CGPoint
//    var width: CGFloat
//    var height: CGFloat
//    var ownerIndex: Int
//    var initialTroops: Int
//    let availableOwners: [Player]
//    
//    // Вычисляемое свойство для получения владельца
//    var owner: Player {
//        return availableOwners[ownerIndex]
//    }
//}
//
//#Preview {
//    RegionPlacementToolView()
//}
//
//
