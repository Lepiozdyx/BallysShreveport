import Foundation

// MARK: - Country
struct Country: Identifiable, Codable, Equatable {
    var id = UUID()
    var regions: [Region]
    let name: String
    let countryIndex: Int
    
    init(name: String, countryIndex: Int) {
        self.name = name
        self.countryIndex = countryIndex
        self.regions = Region.createRegions(for: countryIndex)
    }
    
    var totalIncome: Int {
        return regions.reduce(0) { $0 + $1.income }
    }
    
    var aliveRegionsCount: Int {
        return regions.filter { !$0.isDestroyed }.count
    }
    
    var isDestroyed: Bool {
        return aliveRegionsCount == 0
    }
    
    var aliveRegions: [Region] {
        return regions.filter { !$0.isDestroyed }
    }
    
    mutating func destroyRegion(at index: Int) {
        guard index < regions.count else { return }
        regions[index].destroy()
    }
    
    mutating func addAirDefenseToRegion(at index: Int) -> Bool {
        guard index < regions.count else { return false }
        guard regions[index].canBuyAirDefense else { return false }
        regions[index].addAirDefense()
        return true
    }
    
    func canBuyAirDefense(at regionIndex: Int) -> Bool {
        guard regionIndex < regions.count else { return false }
        return regions[regionIndex].canBuyAirDefense
    }
    
    mutating func consumeAirDefense(at index: Int) -> Bool {
        guard index < regions.count else { return false }
        return regions[index].consumeAirDefense()
    }
    
    func getRegionIndex(by regionId: UUID) -> Int? {
        return regions.firstIndex { $0.id == regionId }
    }
}

// MARK: - Country Factory
extension Country {
    static func createDefaultCountries() -> [Country] {
        return [
            Country(name: "USA", countryIndex: 0),
            Country(name: "Iran", countryIndex: 1),
            Country(name: "China", countryIndex: 2),
            Country(name: "North Korea", countryIndex: 3)
        ]
    }
    
    static func createCountries(for opponentCount: Int) -> [Country] {
        switch opponentCount {
        case 1:
            return [
                Country(name: "USA", countryIndex: 0),
                Country(name: "North Korea", countryIndex: 3)
            ]
        case 2:
            return [
                Country(name: "USA", countryIndex: 0),
                Country(name: "Iran", countryIndex: 1),
                Country(name: "North Korea", countryIndex: 3)
            ]
        case 3:
            return [
                Country(name: "USA", countryIndex: 0),
                Country(name: "Iran", countryIndex: 1),
                Country(name: "China", countryIndex: 2),
                Country(name: "North Korea", countryIndex: 3)
            ]
        default:
            return createDefaultCountries()
        }
    }
}
