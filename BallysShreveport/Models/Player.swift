import Foundation

// MARK: - Player Type
enum PlayerType: String, Codable, CaseIterable {
    case human = "human"
    case ai = "ai"
}

// MARK: - Player
struct Player: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: PlayerType
    var countryIndex: Int
    var coins: Int = 0
    var availableRockets: Int = 0
    var rocketsUsedThisTurn: Int = 0
    let maxRocketsPerTurn: Int
    let rocketCost: Int
    let airDefenseCost: Int
    
    init(type: PlayerType, countryIndex: Int) {
        self.type = type
        self.countryIndex = countryIndex
        self.maxRocketsPerTurn = 2
        self.rocketCost = 20
        self.airDefenseCost = 20
    }
    
    var canBuyRocket: Bool {
        return coins >= rocketCost && rocketsUsedThisTurn < maxRocketsPerTurn
    }
    
    var canBuyAirDefense: Bool {
        return coins >= airDefenseCost
    }
    
    mutating func addIncome(_ amount: Int) {
        coins += amount
    }
    
    mutating func buyRocket() -> Bool {
        guard canBuyRocket else { return false }
        coins -= rocketCost
        availableRockets += 1
        rocketsUsedThisTurn += 1
        return true
    }
    
    mutating func buyAirDefense() -> Bool {
        guard canBuyAirDefense else { return false }
        coins -= airDefenseCost
        return true
    }
    
    mutating func useRocket() -> Bool {
        guard availableRockets > 0 else { return false }
        availableRockets -= 1
        return true
    }
    
    mutating func resetTurnCounters() {
        rocketsUsedThisTurn = 0
    }
    
    var isAI: Bool {
        return type == .ai
    }
    
    var isHuman: Bool {
        return type == .human
    }
}

// MARK: - Player Factory
extension Player {
    static func createPlayers() -> [Player] {
        return [
            Player(type: .human, countryIndex: 0),
            Player(type: .ai, countryIndex: 1),
            Player(type: .ai, countryIndex: 2),
            Player(type: .ai, countryIndex: 3)
        ]
    }
    
    static func createPlayers(for opponentCount: Int) -> [Player] {
        switch opponentCount {
        case 1:
            return [
                Player(type: .human, countryIndex: 0),
                Player(type: .ai, countryIndex: 3)
            ]
        case 2:
            return [
                Player(type: .human, countryIndex: 0),
                Player(type: .ai, countryIndex: 1),
                Player(type: .ai, countryIndex: 3)
            ]
        case 3:
            return [
                Player(type: .human, countryIndex: 0),
                Player(type: .ai, countryIndex: 1),
                Player(type: .ai, countryIndex: 2),
                Player(type: .ai, countryIndex: 3)
            ]
        default:
            return createPlayers()
        }
    }
}
