import Foundation
import SwiftUI

// MARK: - Region Shape Names
enum RegionShape: String, CaseIterable {
    case usa1, usa2, usa3, usa4, usa5
    case iran1, iran2, iran3, iran4, iran5
    case china1, china2, china3, china4, china5
    case nk1, nk2, nk3, nk4, nk5
    
    var imageName: String {
        return self.rawValue
    }
}

// MARK: - Country Type
enum CountryType: String, CaseIterable {
    case usa = "USA"
    case iran = "Iran"
    case china = "China"
    case northKorea = "North Korea"
    
    var countryIndex: Int {
        switch self {
        case .usa: return 0
        case .iran: return 1
        case .china: return 2
        case .northKorea: return 3
        }
    }
    
    var isPlayerControlled: Bool {
        return self == .usa
    }
    
    static func shapesForCountry(_ country: CountryType) -> [RegionShape] {
        switch country {
        case .usa:
            return [.usa1, .usa2, .usa3, .usa4, .usa5]
        case .iran:
            return [.iran1, .iran2, .iran3, .iran4, .iran5]
        case .china:
            return [.china1, .china2, .china3, .china4, .china5]
        case .northKorea:
            return [.nk1, .nk2, .nk3, .nk4, .nk5]
        }
    }
}

// MARK: - Region Definition
struct RegionDefinition: Identifiable {
    var id = UUID()
    let shape: RegionShape
    var position: CGPoint
    var width: CGFloat
    var height: CGFloat
    let country: CountryType
    
    init(shape: RegionShape, position: CGPoint, width: CGFloat, height: CGFloat, country: CountryType) {
        self.shape = shape
        self.position = position
        self.width = width
        self.height = height
        self.country = country
    }
}

// MARK: - Game Level
struct GameLevel: Identifiable {
    var id: Int
    let regions: [RegionDefinition]
    let name: String
    
    init(id: Int, regions: [RegionDefinition], name: String) {
        self.id = id
        self.regions = regions
        self.name = name
    }
    
    var regionsByCountry: [CountryType: [RegionDefinition]] {
        var result: [CountryType: [RegionDefinition]] = [:]
        
        for region in regions {
            if result[region.country] == nil {
                result[region.country] = []
            }
            result[region.country]?.append(region)
        }
        
        return result
    }
    
    func getRegionsForCountry(_ countryType: CountryType) -> [RegionDefinition] {
        return regionsByCountry[countryType] ?? []
    }
}
