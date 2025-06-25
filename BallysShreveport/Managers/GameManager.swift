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
    
    init() {
        self.game = Game()
        initializeAISystems()
    }
    
    init(opponentCount: Int) {
        self.game = Game(opponentCount: opponentCount)
        initializeAISystems()
    }
    
    // MARK: - Game Lifecycle
    func startNewGame() {
        game = Game()
        initializeAISystems()
        game.startGame()
    }
    
    func startNewGame(opponentCount: Int) {
        game = Game(opponentCount: opponentCount)
        initializeAISystems()
        game.startGame()
    }
    
    // MARK: - AI Systems Setup
    private func initializeAISystems() {
        aiSystems.removeAll()
        for player in game.players {
            if player.isAI {
                aiSystems[player.countryIndex] = AISystem.createForPlayer(at: player.countryIndex)
            }
        }
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
        for player in game.aiPlayers {
            guard let aiSystem = aiSystems[player.countryIndex],
                  let playerIndex = game.players.firstIndex(where: { $0.id == player.id }),
                  let country = game.countries.first(where: { $0.countryIndex == player.countryIndex }) else { continue }
            
            let decisions = aiSystem.makePurchaseDecisions(for: player, country: country, allCountries: game.countries)
            
            // Execute AI decisions
            for decision in decisions {
                switch decision {
                case .buyRocket(_):
                    if game.players[playerIndex].buyRocket() {
                        game.playerActions[player.id]?.addPurchaseAction(decision)
                    }
                case .buyAirDefense(let regionIndex):
                    if game.players[playerIndex].buyAirDefense(),
                       let countryArrayIndex = game.countries.firstIndex(where: { $0.countryIndex == player.countryIndex }) {
                        if game.countries[countryArrayIndex].addAirDefenseToRegion(at: regionIndex) {
                            game.playerActions[player.id]?.addPurchaseAction(decision)
                        }
                    }
                case .none:
                    break
                }
            }
        }
    }
    
    private func executeAITargeting() {
        for player in game.aiPlayers {
            guard let aiSystem = aiSystems[player.countryIndex],
                  let playerIndex = game.players.firstIndex(where: { $0.id == player.id }),
                  let country = game.countries.first(where: { $0.countryIndex == player.countryIndex }) else { continue }
            
            let targets = aiSystem.selectAttackTargets(for: player, country: country, allCountries: game.countries)
            
            // Execute AI targeting
            for target in targets {
                if game.players[playerIndex].useRocket() {
                    game.playerActions[player.id]?.addAttackTarget(target)
                }
            }
        }
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
