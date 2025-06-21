import Foundation

// MARK: - Game Phase
enum GamePhase: String, Codable, CaseIterable {
    case economy = "economy"
    case targeting = "targeting"
    case resolution = "resolution"
    
    var displayName: String {
        switch self {
        case .economy:
            return "Economy Phase"
        case .targeting:
            return "Targeting Phase"
        case .resolution:
            return "Resolution Phase"
        }
    }
}

// MARK: - Game State
enum GameState: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case victory = "victory"
    case defeat = "defeat"
    case draw = "draw"
    case maxRoundsReached = "max_rounds_reached"
}

// MARK: - Game Result
struct GameResult: Codable, Equatable {
    let state: GameState
    let winnerCountryIndex: Int?
    let roundsPlayed: Int
    let finalRegionCounts: [Int: Int] // countryIndex: regionCount
    
    init(state: GameState, winnerCountryIndex: Int? = nil, roundsPlayed: Int, finalRegionCounts: [Int: Int]) {
        self.state = state
        self.winnerCountryIndex = winnerCountryIndex
        self.roundsPlayed = roundsPlayed
        self.finalRegionCounts = finalRegionCounts
    }
}

// MARK: - Game
struct Game: Codable, Equatable {
    var id = UUID()
    var countries: [Country]
    var players: [Player]
    var currentPhase: GamePhase = .economy
    var currentRound: Int = 1
    var gameState: GameState = .notStarted
    var playerActions: [UUID: PlayerTurnActions] = [:]
    var turnResolutions: [TurnResolution] = []
    let maxRounds: Int
    var currentPlayerIndex: Int = 0
    
    init() {
        self.maxRounds = 50
        self.countries = Country.createDefaultCountries()
        self.players = Player.createPlayers()
        self.initializePlayerActions()
    }
    
    private mutating func initializePlayerActions() {
        for player in players {
            playerActions[player.id] = PlayerTurnActions(playerId: player.id)
        }
    }
    
    var humanPlayer: Player? {
        return players.first { $0.type == .human }
    }
    
    var aiPlayers: [Player] {
        return players.filter { $0.type == .ai }
    }
    
    var aliveCountries: [Country] {
        return countries.filter { !$0.isDestroyed }
    }
    
    var aliveCountriesCount: Int {
        return aliveCountries.count
    }
    
    mutating func startGame() {
        gameState = .inProgress
        distributeInitialIncome()
    }
    
    mutating func nextPhase() {
        switch currentPhase {
        case .economy:
            currentPhase = .targeting
        case .targeting:
            currentPhase = .resolution
            resolveCurrentTurn()
        case .resolution:
            if checkGameEndConditions() {
                return
            }
            startNewRound()
        }
    }
    
    private mutating func startNewRound() {
        currentRound += 1
        currentPhase = .economy
        currentPlayerIndex = 0
        
        // Reset player turn counters
        for i in 0..<players.count {
            players[i].resetTurnCounters()
        }
        
        // Clear previous actions
        for (playerId, _) in playerActions {
            playerActions[playerId]?.clearActions()
        }
        
        // Distribute income
        distributeInitialIncome()
    }
    
    private mutating func distributeInitialIncome() {
        for i in 0..<players.count {
            let countryIndex = players[i].countryIndex
            let income = countries[countryIndex].totalIncome
            players[i].addIncome(income)
        }
    }
    
    private mutating func resolveCurrentTurn() {
        var attackResults: [AttackResult] = []
        var destroyedRegions: [DestroyedRegion] = []
        
        // Collect all attacks
        var allAttacks: [AttackTarget] = []
        for actions in playerActions.values {
            allAttacks.append(contentsOf: actions.attackTargets)
        }
        
        // Process each attack
        for attack in allAttacks {
            let targetCountryIndex = attack.targetCountryIndex
            let targetRegionIndex = attack.targetRegionIndex
            
            // Check if target has air defense
            let wasBlocked = countries[targetCountryIndex].consumeAirDefense(at: targetRegionIndex)
            let result = AttackResult(attack: attack, wasBlocked: wasBlocked)
            attackResults.append(result)
            
            // If not blocked, destroy the region
            if !wasBlocked {
                countries[targetCountryIndex].destroyRegion(at: targetRegionIndex)
                destroyedRegions.append(DestroyedRegion(countryIndex: targetCountryIndex, regionIndex: targetRegionIndex))
            }
        }
        
        let resolution = TurnResolution(
            roundNumber: currentRound,
            attackResults: attackResults,
            destroyedRegions: destroyedRegions
        )
        turnResolutions.append(resolution)
    }
    
    private mutating func checkGameEndConditions() -> Bool {
        let aliveCount = aliveCountriesCount
        
        // Check for victory/defeat
        if aliveCount == 1 {
            let winnerCountry = aliveCountries.first!
            if let humanPlayer = humanPlayer, humanPlayer.countryIndex == winnerCountry.countryIndex {
                gameState = .victory
            } else {
                gameState = .defeat
            }
            return true
        }
        
        // Check for draw (no survivors)
        if aliveCount == 0 {
            gameState = .draw
            return true
        }
        
        // Check for max rounds
        if currentRound >= maxRounds {
            gameState = .maxRoundsReached
            return true
        }
        
        return false
    }
    
    func getGameResult() -> GameResult? {
        guard gameState != .inProgress && gameState != .notStarted else { return nil }
        
        var winnerIndex: Int? = nil
        if gameState == .victory || gameState == .defeat {
            winnerIndex = aliveCountries.first?.countryIndex
        } else if gameState == .maxRoundsReached {
            // Find country with most regions
            let regionCounts = countries.enumerated().map { ($0.offset, $0.element.aliveRegionsCount) }
            let maxCount = regionCounts.max { $0.1 < $1.1 }?.1 ?? 0
            winnerIndex = regionCounts.first { $0.1 == maxCount }?.0
        }
        
        let finalCounts = Dictionary(uniqueKeysWithValues:
            countries.enumerated().map { ($0.offset, $0.element.aliveRegionsCount) })
        
        return GameResult(
            state: gameState,
            winnerCountryIndex: winnerIndex,
            roundsPlayed: currentRound,
            finalRegionCounts: finalCounts
        )
    }
}
