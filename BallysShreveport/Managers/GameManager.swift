import Foundation

// MARK: - Game Manager
@MainActor
class GameManager: ObservableObject {
    @Published var game: Game
    @Published var selectedRegionIndex: Int?
    @Published var showingRegionMenu: Bool = false
    @Published var isProcessingTurn: Bool = false
    @Published var animationInProgress: Bool = false
    @Published var lastTurnResolution: TurnResolution?
    
    private var aiSystems: [Int: AISystem] = [:]
    
    init(opponentCount: Int) {
        self.game = Game(opponentCount: opponentCount)
        initializeAISystems()
    }
    
    // MARK: - AI Systems Setup
    private func initializeAISystems() {
        aiSystems.removeAll()
        print("=== Initializing AI Systems ===")
        print("Total players: \(game.players.count)")
        for player in game.players {
            print("Player: type=\(player.type), countryIndex=\(player.countryIndex)")
            if player.isAI {
                print("Creating AI for countryIndex: \(player.countryIndex)")
                aiSystems[player.countryIndex] = AISystem.createForPlayer(at: player.countryIndex)
                print("AI created successfully: \(aiSystems[player.countryIndex] != nil)")
            }
        }
        print("Total AI systems created: \(aiSystems.count)")
        print("AI system keys: \(Array(aiSystems.keys).sorted())")
        print("=== AI Systems Init Complete ===")
    }
    
    // MARK: - Game Lifecycle
    func startNewGame(opponentCount: Int) {
        game = Game(opponentCount: opponentCount)
        initializeAISystems()
        game.startGame()
    }
    
    // MARK: - Phase Management
    func endCurrentPhase() {
        guard !isProcessingTurn else { return }
        
        switch game.currentPhase {
        case .economy:
            processEconomyPhaseEnd()
        case .targeting:
            processTargetingPhaseEnd()
        case .resolution:
            processResolutionPhaseEnd()
        }
    }
    
    private func processEconomyPhaseEnd() {
        // Execute AI purchases for all AI players
        executeAIPurchases()
        game.nextPhase()
        objectWillChange.send()
    }
    
    private func processTargetingPhaseEnd() {
        // Execute AI targeting for all AI players
        executeAITargeting()
        // Automatically proceed to resolution phase
        game.nextPhase()
        objectWillChange.send()
        // Start resolution processing immediately
        processResolutionPhaseEnd()
    }
    
    private func processResolutionPhaseEnd() {
        isProcessingTurn = true
        animationInProgress = true
        
        // Store resolution for animation
        if let lastResolution = game.turnResolutions.last {
            lastTurnResolution = lastResolution
        }
        
        // Process resolution
        game.nextPhase()
        
        // Check for immediate player defeat
        if checkForPlayerDefeat() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isProcessingTurn = false
                self.animationInProgress = false
            }
            return
        }
        
        // Check for other game end conditions
        if checkGameEndConditions() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isProcessingTurn = false
                self.animationInProgress = false
            }
            return
        }
        
        // Continue game with animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isProcessingTurn = false
            self.animationInProgress = false
        }
    }
    
    private func checkForPlayerDefeat() -> Bool {
        guard let humanPlayer = game.humanPlayer,
              let humanCountry = game.countries.first(where: { $0.countryIndex == humanPlayer.countryIndex }) else { return false }
        
        if humanCountry.isDestroyed {
            game.gameState = .defeat
            return true
        }
        
        return false
    }
    
    private func checkGameEndConditions() -> Bool {
        let aliveCount = game.aliveCountriesCount
        
        // Check for victory/defeat
        if aliveCount == 1 {
            let winnerCountry = game.aliveCountries.first!
            if let humanPlayer = game.humanPlayer, humanPlayer.countryIndex == winnerCountry.countryIndex {
                game.gameState = .victory
            } else {
                game.gameState = .defeat
            }
            return true
        }
        
        // Check for draw (no survivors)
        if aliveCount == 0 {
            game.gameState = .draw
            return true
        }
        
        // Check for max rounds
        if game.currentRound >= game.maxRounds {
            game.gameState = .maxRoundsReached
            return true
        }
        
        return false
    }
    
    // MARK: - Human Player Actions
    func selectRegion(_ regionIndex: Int) {
        guard game.currentPhase == .economy else { return }
        selectedRegionIndex = regionIndex
        showingRegionMenu = true
    }
    
    func buyRocketForRegion(_ regionIndex: Int) {
        guard let humanPlayer = game.humanPlayer,
              let playerIndex = game.players.firstIndex(where: { $0.id == humanPlayer.id }) else { return }
        
        if game.players[playerIndex].buyRocket() {
            let action = GameAction.buyRocket(regionIndex: regionIndex)
            game.playerActions[humanPlayer.id]?.addPurchaseAction(action)
            objectWillChange.send()
        }
        
        closeRegionMenu()
    }
    
    func buyAirDefenseForRegion(_ regionIndex: Int) {
        guard let humanPlayer = game.humanPlayer,
              let playerIndex = game.players.firstIndex(where: { $0.id == humanPlayer.id }),
              let humanCountryIndex = game.humanPlayer?.countryIndex,
              let countryArrayIndex = game.countries.firstIndex(where: { $0.countryIndex == humanCountryIndex }) else { return }
        
        if game.players[playerIndex].buyAirDefense() &&
           game.countries[countryArrayIndex].addAirDefenseToRegion(at: regionIndex) {
            let action = GameAction.buyAirDefense(regionIndex: regionIndex)
            game.playerActions[humanPlayer.id]?.addPurchaseAction(action)
            objectWillChange.send()
        }
        
        closeRegionMenu()
    }
    
    func closeRegionMenu() {
        showingRegionMenu = false
        selectedRegionIndex = nil
    }
    
    // MARK: - Attack Target Selection
    func selectAttackTarget(countryIndex: Int, regionIndex: Int) {
        guard game.currentPhase == .targeting,
              let humanPlayer = game.humanPlayer,
              humanPlayer.availableRockets > 0 else { return }
        
        let target = AttackTarget(
            attackerCountryIndex: humanPlayer.countryIndex,
            targetCountryIndex: countryIndex,
            targetRegionIndex: regionIndex
        )
        
        game.playerActions[humanPlayer.id]?.addAttackTarget(target)
        
        // Use rocket
        if let playerIndex = game.players.firstIndex(where: { $0.id == humanPlayer.id }) {
            _ = game.players[playerIndex].useRocket()
        }
        
        // Notify UI of changes
        objectWillChange.send()
    }
    
    func removeAttackTarget(at index: Int) {
        guard let humanPlayer = game.humanPlayer else { return }
        
        game.playerActions[humanPlayer.id]?.removeAttackTarget(at: index)
        
        // Return rocket
        if let playerIndex = game.players.firstIndex(where: { $0.id == humanPlayer.id }) {
            game.players[playerIndex].availableRockets += 1
        }
        
        // Notify UI of changes
        objectWillChange.send()
    }
    
    // MARK: - AI Execution
    private func executeAIPurchases() {
        print("=== AI Purchases Phase ===")
        print("AI players count: \(game.aiPlayers.count)")
        for player in game.aiPlayers {
            print("Processing AI player countryIndex: \(player.countryIndex), coins: \(player.coins)")
            
            guard let aiSystem = aiSystems[player.countryIndex] else {
                print("ERROR: No AI system found for countryIndex: \(player.countryIndex)")
                continue
            }
            
            guard let playerIndex = game.players.firstIndex(where: { $0.id == player.id }) else {
                print("ERROR: Player index not found for countryIndex: \(player.countryIndex)")
                continue
            }
            
            guard let country = game.countries.first(where: { $0.countryIndex == player.countryIndex }) else {
                print("ERROR: Country not found for countryIndex: \(player.countryIndex)")
                continue
            }
            
            print("AI system found, making decisions for countryIndex: \(player.countryIndex)")
            let decisions = aiSystem.makePurchaseDecisions(for: player, country: country, allCountries: game.countries)
            print("AI decisions count: \(decisions.count) for countryIndex: \(player.countryIndex)")
            
            // Execute AI decisions
            for decision in decisions {
                switch decision {
                case .buyRocket(_):
                    if game.players[playerIndex].buyRocket() {
                        game.playerActions[player.id]?.addPurchaseAction(decision)
                        print("AI bought rocket for countryIndex: \(player.countryIndex)")
                    }
                case .buyAirDefense(let regionIndex):
                    if game.players[playerIndex].buyAirDefense(),
                       let countryArrayIndex = game.countries.firstIndex(where: { $0.countryIndex == player.countryIndex }) {
                        if game.countries[countryArrayIndex].addAirDefenseToRegion(at: regionIndex) {
                            game.playerActions[player.id]?.addPurchaseAction(decision)
                            print("AI bought air defense for countryIndex: \(player.countryIndex), region: \(regionIndex)")
                        }
                    }
                case .none:
                    break
                }
            }
        }
        print("=== AI Purchases Complete ===")
    }
    
    private func executeAITargeting() {
        print("=== AI Targeting Phase ===")
        for player in game.aiPlayers {
            print("Processing AI targeting for countryIndex: \(player.countryIndex), rockets: \(player.availableRockets)")
            
            guard let aiSystem = aiSystems[player.countryIndex],
                  let playerIndex = game.players.firstIndex(where: { $0.id == player.id }),
                  let country = game.countries.first(where: { $0.countryIndex == player.countryIndex }) else {
                print("ERROR: Failed to get AI system/player/country for countryIndex: \(player.countryIndex)")
                continue
            }
            
            let targets = aiSystem.selectAttackTargets(for: player, country: country, allCountries: game.countries)
            print("AI selected \(targets.count) targets for countryIndex: \(player.countryIndex)")
            
            // Execute AI targeting
            for target in targets {
                if game.players[playerIndex].useRocket() {
                    game.playerActions[player.id]?.addAttackTarget(target)
                    print("AI targeted countryIndex: \(target.targetCountryIndex), region: \(target.targetRegionIndex)")
                }
            }
        }
        print("=== AI Targeting Complete ===")
    }
    
    // MARK: - Game State Queries
    var humanPlayer: Player? {
        return game.humanPlayer
    }
    
    var humanCountry: Country? {
        guard let humanPlayer = game.humanPlayer else { return nil }
        return game.countries.first(where: { $0.countryIndex == humanPlayer.countryIndex })
    }
    
    var currentPhaseDisplayName: String {
        return game.currentPhase.displayName
    }
    
    var canEndPhase: Bool {
        switch game.currentPhase {
        case .economy:
            return !isProcessingTurn
        case .targeting:
            return !isProcessingTurn
        case .resolution:
            return !isProcessingTurn && !animationInProgress
        }
    }
    
    var isGameOver: Bool {
        return game.gameState != .inProgress && game.gameState != .notStarted
    }
    
    func getGameResult() -> GameResult? {
        return game.getGameResult()
    }
    
    // MARK: - Helper Methods
    func canBuyRocket() -> Bool {
        guard let humanPlayer = game.humanPlayer else { return false }
        return humanPlayer.canBuyRocket
    }
    
    func canBuyAirDefense(for regionIndex: Int) -> Bool {
        guard let humanPlayer = game.humanPlayer,
              let humanCountryIndex = game.humanPlayer?.countryIndex,
              let country = game.countries.first(where: { $0.countryIndex == humanCountryIndex }) else { return false }
        
        return humanPlayer.canBuyAirDefense && country.canBuyAirDefense(at: regionIndex)
    }
    
    func getAttackTargets() -> [AttackTarget] {
        guard let humanPlayer = game.humanPlayer else { return [] }
        return game.playerActions[humanPlayer.id]?.attackTargets ?? []
    }
    
    func isRegionDestroyed(countryIndex: Int, regionIndex: Int) -> Bool {
        guard let country = game.countries.first(where: { $0.countryIndex == countryIndex }),
              regionIndex < country.regions.count else { return true }
        return country.regions[regionIndex].isDestroyed
    }
}
