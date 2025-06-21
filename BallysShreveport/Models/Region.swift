import Foundation
import SwiftUI

// MARK: - Region
struct Region: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var isDestroyed: Bool = false
    var hasAirDefense: Bool = false
    var position: CGPoint = .zero
    
    var income: Int {
        return isDestroyed ? 0 : 10
    }
    
    mutating func destroy() {
        isDestroyed = true
        hasAirDefense = false
    }
    
    mutating func addAirDefense() {
        guard !isDestroyed && !hasAirDefense else { return }
        hasAirDefense = true
    }
    
    mutating func consumeAirDefense() -> Bool {
        guard hasAirDefense else { return false }
        hasAirDefense = false
        return true
    }
    
    var canBuyAirDefense: Bool {
        return !isDestroyed && !hasAirDefense
    }
}

// MARK: - Region Extensions
extension Region {
    static func createRegions(for countryIndex: Int) -> [Region] {
        let regionsPerCountry = 5
        var regions: [Region] = []
        
        for regionIndex in 0..<regionsPerCountry {
            var region = Region()
            region.position = calculateRegionPosition(countryIndex: countryIndex, regionIndex: regionIndex)
            regions.append(region)
        }
        
        return regions
    }
    
    private static func calculateRegionPosition(countryIndex: Int, regionIndex: Int) -> CGPoint {
        let regionSize: CGFloat = 60
        let countrySpacing: CGFloat = 100
        
        // Arrange countries in 2x2 grid
        let countryRow = countryIndex / 2
        let countryCol = countryIndex % 2
        
        // Arrange regions in a horizontal line for each country
        let regionX = CGFloat(countryCol) * (regionSize * 5 + countrySpacing) + CGFloat(regionIndex) * regionSize
        let regionY = CGFloat(countryRow) * (regionSize + countrySpacing)
        
        return CGPoint(x: regionX, y: regionY)
    }
}
