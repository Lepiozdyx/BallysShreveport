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
                    
                    RegionView(
                        regionDef: regionDef,
                        countryIndex: countryIndex,
                        regionIndex: regionIndex,
                        viewModel: viewModel
                    )
                    .position(regionDef.position)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getRegionIndexInCountry(regionDef: RegionDefinition) -> Int {
        let countryRegions = levelManager.getRegionsForCountry(regionDef.country)
        return countryRegions.firstIndex(where: { $0.id == regionDef.id }) ?? 0
    }
}

#Preview {
    GameFieldView(viewModel: GameViewModel(gameManager: GameManager()))
}
