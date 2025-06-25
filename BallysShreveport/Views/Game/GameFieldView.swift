import SwiftUI

struct GameFieldView: View {
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var levelManager = LevelManager()
    
    var body: some View {
        ZStack {
            if let currentLevel = levelManager.currentLevel {
                ForEach(Array(currentLevel.regions.enumerated()), id: \.element.id) { index, regionDef in
                    let countryIndex = regionDef.country.countryIndex
                    let regionIndex = getRegionIndexInCountry(regionDef: regionDef)
                    
                    if countryExists(countryIndex: countryIndex) {
                        RegionView(
                            regionDef: regionDef,
                            countryIndex: countryIndex,
                            regionIndex: regionIndex,
                            viewModel: viewModel
                        )
                        .position(regionDef.position)
                        .zIndex(getZIndexForRegion(countryIndex: countryIndex, regionIndex: regionIndex))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            setupLevelForCurrentGame()
        }
        .onChange(of: viewModel.currentGame.countries.count) { _ in
            setupLevelForCurrentGame()
        }
    }
    
    private func setupLevelForCurrentGame() {
        let countryCount = viewModel.currentGame.countries.count
        let opponentCount = countryCount - 1 // Subtract 1 for human player
        levelManager.setLevelForOpponentCount(opponentCount)
    }
    
    private func countryExists(countryIndex: Int) -> Bool {
        return viewModel.currentGame.countries.contains { $0.countryIndex == countryIndex }
    }
    
    private func getRegionIndexInCountry(regionDef: RegionDefinition) -> Int {
        let countryRegions = levelManager.getRegionsForCountry(regionDef.country)
        return countryRegions.firstIndex(where: { $0.id == regionDef.id }) ?? 0
    }
    
    private func getZIndexForRegion(countryIndex: Int, regionIndex: Int) -> Double {
        switch (countryIndex, regionIndex) {
        case (0, 3): // .usa4
            return 10.0
        case (2, 2): // .china3
            return 10.0
        case (0, 4): // .usa5
            return 5.0
        case (2, 3): // .china4
            return 5.0
        default:
            return 1.0
        }
    }
}

#Preview {
    GameFieldView(viewModel: GameViewModel(gameManager: GameManager()))
}
