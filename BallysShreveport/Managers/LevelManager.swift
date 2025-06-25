import Foundation
import SwiftUI

// MARK: - Level Manager
class LevelManager: ObservableObject {
    @Published var availableLevels: [GameLevel] = []
    @Published var currentLevel: GameLevel?
    
    init() {
        loadDefaultLevels()
    }
    
    private func loadDefaultLevels() {
        let defaultLevel = createLevelWith3Opponents()
        
        availableLevels = [defaultLevel]
        currentLevel = defaultLevel
    }
    
    private func createLevelWith1Opponent() -> GameLevel {
        let regions = [
            // USA regions
            RegionDefinition(shape: .usa1, position: CGPoint(x: 134.7, y: 109.3), width: 79.50, height: 57.38, country: .usa),
            RegionDefinition(shape: .usa2, position: CGPoint(x: 124.7, y: 158.3), width: 95.35, height: 78.62, country: .usa),
            RegionDefinition(shape: .usa3, position: CGPoint(x: 192.0, y: 150.0), width: 70.35, height: 113.83, country: .usa),
            RegionDefinition(shape: .usa4, position: CGPoint(x: 153.3, y: 248.3), width: 75.05, height: 116.08, country: .usa),
            RegionDefinition(shape: .usa5, position: CGPoint(x: 121.0, y: 260.7), width: 102.40, height: 161.08, country: .usa),

            // North Korea regions
            RegionDefinition(shape: .nk1, position: CGPoint(x: 562.3, y: 146.3), width: 90.02, height: 60.81, country: .northKorea),
            RegionDefinition(shape: .nk2, position: CGPoint(x: 528.0, y: 209.7), width: 100.84, height: 75.66, country: .northKorea),
            RegionDefinition(shape: .nk3, position: CGPoint(x: 580.7, y: 213.7), width: 90.97, height: 108.56, country: .northKorea),
            RegionDefinition(shape: .nk4, position: CGPoint(x: 539.3, y: 275.0), width: 84.21, height: 91.79, country: .northKorea),
            RegionDefinition(shape: .nk5, position: CGPoint(x: 605.3, y: 283.3), width: 87.09, height: 121.19, country: .northKorea),
        ]
        
        return GameLevel(id: 0, regions: regions, name: "Classic Layout")
    }
    
    private func createLevelWith2Opponents() -> GameLevel {
        let regions = [
            // USA regions
            RegionDefinition(shape: .usa1, position: CGPoint(x: 134.7, y: 109.3), width: 79.50, height: 57.38, country: .usa),
            RegionDefinition(shape: .usa2, position: CGPoint(x: 124.7, y: 158.3), width: 95.35, height: 78.62, country: .usa),
            RegionDefinition(shape: .usa3, position: CGPoint(x: 192.0, y: 150.0), width: 70.35, height: 113.83, country: .usa),
            RegionDefinition(shape: .usa4, position: CGPoint(x: 153.3, y: 248.3), width: 75.05, height: 116.08, country: .usa),
            RegionDefinition(shape: .usa5, position: CGPoint(x: 121.0, y: 260.7), width: 102.40, height: 161.08, country: .usa),

            // Iran regions
            RegionDefinition(shape: .iran1, position: CGPoint(x: 314.7, y: 76.7), width: 100.76, height: 77.23, country: .iran),
            RegionDefinition(shape: .iran2, position: CGPoint(x: 309.0, y: 127.7), width: 97.18, height: 72.20, country: .iran),
            RegionDefinition(shape: .iran3, position: CGPoint(x: 378.0, y: 108.7), width: 73.43, height: 77.09, country: .iran),
            RegionDefinition(shape: .iran4, position: CGPoint(x: 372.7, y: 169.3), width: 117.47, height: 76.65, country: .iran),
            RegionDefinition(shape: .iran5, position: CGPoint(x: 430.0, y: 121.3), width: 79.12, height: 95.10, country: .iran),

            // North Korea regions
            RegionDefinition(shape: .nk1, position: CGPoint(x: 562.3, y: 146.3), width: 90.02, height: 60.81, country: .northKorea),
            RegionDefinition(shape: .nk2, position: CGPoint(x: 528.0, y: 209.7), width: 100.84, height: 75.66, country: .northKorea),
            RegionDefinition(shape: .nk3, position: CGPoint(x: 580.7, y: 213.7), width: 90.97, height: 108.56, country: .northKorea),
            RegionDefinition(shape: .nk4, position: CGPoint(x: 539.3, y: 275.0), width: 84.21, height: 91.79, country: .northKorea),
            RegionDefinition(shape: .nk5, position: CGPoint(x: 605.3, y: 283.3), width: 87.09, height: 121.19, country: .northKorea),
        ]
        
        return GameLevel(id: 1, regions: regions, name: "Classic Layout")
    }
    
    private func createLevelWith3Opponents() -> GameLevel {
        let regions = [
            // USA regions
            RegionDefinition(shape: .usa1, position: CGPoint(x: 134.7, y: 109.3), width: 79.50, height: 57.38, country: .usa),
            RegionDefinition(shape: .usa2, position: CGPoint(x: 124.7, y: 158.3), width: 95.35, height: 78.62, country: .usa),
            RegionDefinition(shape: .usa3, position: CGPoint(x: 192.0, y: 150.0), width: 70.35, height: 113.83, country: .usa),
            RegionDefinition(shape: .usa4, position: CGPoint(x: 153.3, y: 248.3), width: 75.05, height: 116.08, country: .usa),
            RegionDefinition(shape: .usa5, position: CGPoint(x: 121.0, y: 260.7), width: 102.40, height: 161.08, country: .usa),

            // Iran regions
            RegionDefinition(shape: .iran1, position: CGPoint(x: 314.7, y: 76.7), width: 100.76, height: 77.23, country: .iran),
            RegionDefinition(shape: .iran2, position: CGPoint(x: 309.0, y: 127.7), width: 97.18, height: 72.20, country: .iran),
            RegionDefinition(shape: .iran3, position: CGPoint(x: 378.0, y: 108.7), width: 73.43, height: 77.09, country: .iran),
            RegionDefinition(shape: .iran4, position: CGPoint(x: 372.7, y: 169.3), width: 117.47, height: 76.65, country: .iran),
            RegionDefinition(shape: .iran5, position: CGPoint(x: 430.0, y: 121.3), width: 79.12, height: 95.10, country: .iran),

            // China regions
            RegionDefinition(shape: .china1, position: CGPoint(x: 301.0, y: 249.7), width: 125.29, height: 95.61, country: .china),
            RegionDefinition(shape: .china2, position: CGPoint(x: 313.7, y: 324.0), width: 122.39, height: 64.28, country: .china),
            RegionDefinition(shape: .china3, position: CGPoint(x: 359.0, y: 302.7), width: 78.30, height: 55.30, country: .china),
            RegionDefinition(shape: .china4, position: CGPoint(x: 387.0, y: 288.7), width: 89.62, height: 72.80, country: .china),
            RegionDefinition(shape: .china5, position: CGPoint(x: 398.3, y: 342.3), width: 66.68, height: 59.05, country: .china),

            // North Korea regions
            RegionDefinition(shape: .nk1, position: CGPoint(x: 562.3, y: 146.3), width: 90.02, height: 60.81, country: .northKorea),
            RegionDefinition(shape: .nk2, position: CGPoint(x: 528.0, y: 209.7), width: 100.84, height: 75.66, country: .northKorea),
            RegionDefinition(shape: .nk3, position: CGPoint(x: 580.7, y: 213.7), width: 90.97, height: 108.56, country: .northKorea),
            RegionDefinition(shape: .nk4, position: CGPoint(x: 539.3, y: 275.0), width: 84.21, height: 91.79, country: .northKorea),
            RegionDefinition(shape: .nk5, position: CGPoint(x: 605.3, y: 283.3), width: 87.09, height: 121.19, country: .northKorea),

        ]
        
        return GameLevel(id: 2, regions: regions, name: "Classic Layout")
    }
    
    func setCurrentLevel(_ level: GameLevel) {
        currentLevel = level
    }
    
    func setLevelForOpponentCount(_ opponentCount: Int) {
        switch opponentCount {
        case 1:
            currentLevel = createLevelWith1Opponent()
        case 2:
            currentLevel = createLevelWith2Opponents()
        case 3:
            currentLevel = createLevelWith3Opponents()
        default:
            currentLevel = createLevelWith3Opponents()
        }
    }
    
    func addCustomLevel(_ level: GameLevel) {
        availableLevels.append(level)
    }
    
    func getRegionsForCountry(_ countryType: CountryType) -> [RegionDefinition] {
        guard let level = currentLevel else { return [] }
        return level.getRegionsForCountry(countryType)
    }
}
