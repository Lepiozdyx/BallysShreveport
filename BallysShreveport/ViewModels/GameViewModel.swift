import SwiftUI
import Foundation
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameManager: GameManager
    @Published var showPauseMenu: Bool = false
    @Published var showResultScreen: Bool = false
    @Published var gameResult: GameResult?
    @Published var selectedRegionIndex: Int?
    @Published var showingRegionMenu: Bool = false
    @Published var attackTargets: [AttackTarget] = []
    @Published var explodingRegions: Set<String> = []
    
    weak var appViewModel: AppViewModel?
    private var cancellables = Set<AnyCancellable>()
    private var lastProcessedRound: Int = 0
    private var opponentCount: Int = 3
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        setupObservers()
    }
    
    init(opponentCount: Int) {
        self.opponentCount = opponentCount
        self.gameManager = GameManager(opponentCount: opponentCount)
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe changes in gameManager
        gameManager.$game
            .sink { [weak self] _ in
                self?.updateAttackTargets()
            }
            .store(in: &cancellables)
        
        // Observe lastTurnResolution changes to trigger explosions
        gameManager.$lastTurnResolution
            .sink { [weak self] resolution in
                self?.handleTurnResolution(resolution)
            }
            .store(in: &cancellables)
    }
    
    private func updateAttackTargets() {
        attackTargets = gameManager.getAttackTargets()
    }
    
    private func handleTurnResolution(_ resolution: TurnResolution?) {
        guard let resolution = resolution,
              resolution.roundNumber > lastProcessedRound else { return }
        
        lastProcessedRound = resolution.roundNumber
        
        // Trigger explosion animations for destroyed regions
        for destroyedRegion in resolution.destroyedRegions {
            startExplosionAnimation(for: destroyedRegion.countryIndex, regionIndex: destroyedRegion.regionIndex)
        }
    }
    
    // MARK: - Explosion Animation
    func startExplosionAnimation(for countryIndex: Int, regionIndex: Int) {
        let regionKey = "\(countryIndex)-\(regionIndex)"
        explodingRegions.insert(regionKey)
        
        // Remove explosion after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.explodingRegions.remove(regionKey)
        }
    }
    
    func isRegionExploding(countryIndex: Int, regionIndex: Int) -> Bool {
        let regionKey = "\(countryIndex)-\(regionIndex)"
        return explodingRegions.contains(regionKey)
    }
    
    // MARK: - Game Lifecycle
    func startNewGame() {
        gameManager.startNewGame(opponentCount: opponentCount)
        resetGameUI()
        updateAttackTargets()
    }
    
    func pauseGame() {
        showPauseMenu = true
    }
    
    func resumeGame() {
        showPauseMenu = false
    }
    
    func exitToMenu() {
        appViewModel?.navigateBackToMenu()
    }
    
    private func resetGameUI() {
        showPauseMenu = false
        showResultScreen = false
        gameResult = nil
        selectedRegionIndex = nil
        showingRegionMenu = false
        attackTargets = []
        explodingRegions.removeAll()
        lastProcessedRound = 0
    }
    
    // MARK: - Phase Management
    func endCurrentPhase() {
        print("=== Ending Phase ===")
        print("Current phase: \(currentPhase)")
        print("Player rockets: \(humanPlayer?.availableRockets ?? 0)")
        print("Player coins: \(humanPlayer?.coins ?? 0)")
        
        gameManager.endCurrentPhase()
        closeRegionMenu()
        updateAttackTargets()
        checkForGameEnd()
        
        print("New phase: \(currentPhase)")
    }
    
    private func checkForGameEnd() {
        if gameManager.isGameOver {
            gameResult = gameManager.getGameResult()
            if let result = gameResult {
                appViewModel?.handleGameCompletion(result: result)
                showResultScreen = true
            }
        }
    }
    
    // MARK: - Region Interaction
    func handleRegionTap(countryIndex: Int, regionIndex: Int, position: CGPoint) {
        print("=== Region Tap ===")
        print("Tapped countryIndex: \(countryIndex), regionIndex: \(regionIndex)")
        print("Current phase: \(currentPhase)")
        
        switch currentPhase {
        case .economy:
            print("Economy phase tap")
            handleEconomyPhaseTap(countryIndex: countryIndex, regionIndex: regionIndex, position: position)
        case .targeting:
            print("Targeting phase tap")
            print("Is human region: \(isHumanRegion(countryIndex: countryIndex))")
            print("Is region destroyed: \(isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex))")
            print("Available rockets: \(humanPlayer?.availableRockets ?? 0)")
            handleTargetingPhaseTap(countryIndex: countryIndex, regionIndex: regionIndex)
        case .resolution:
            print("Resolution phase tap - no interaction")
            break // No interaction during resolution
        }
    }
    
    private func handleEconomyPhaseTap(countryIndex: Int, regionIndex: Int, position: CGPoint) {
        guard isHumanRegion(countryIndex: countryIndex),
              !isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) else { return }
        
        if showingRegionMenu && selectedRegionIndex == regionIndex {
            closeRegionMenu()
        } else {
            selectedRegionIndex = regionIndex
            showingRegionMenu = true
        }
    }
    
    private func handleTargetingPhaseTap(countryIndex: Int, regionIndex: Int) {
        print("=== Targeting Phase Tap ===")
        print("Target countryIndex: \(countryIndex), regionIndex: \(regionIndex)")
        
        guard !isHumanRegion(countryIndex: countryIndex) else {
            print("Cannot target own region - this is human region")
            return
        }
        
        guard !isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) else {
            print("Cannot target destroyed region")
            return
        }
        
        // Check if this region is already targeted
        if let existingTargetIndex = attackTargets.firstIndex(where: {
            $0.targetCountryIndex == countryIndex && $0.targetRegionIndex == regionIndex
        }) {
            print("Region already targeted - removing target")
            // Remove existing target (untarget)
            removeAttackTarget(at: existingTargetIndex)
        } else if humanPlayer?.availableRockets ?? 0 > 0 {
            print("Adding new target - rockets available: \(humanPlayer?.availableRockets ?? 0)")
            // Add new target (only if we have rockets available)
            selectAttackTarget(countryIndex: countryIndex, regionIndex: regionIndex)
        } else {
            print("Cannot add target - no rockets available")
        }
    }
    
    // MARK: - Economy Phase Actions
    func buyRocket() {
        guard let regionIndex = selectedRegionIndex,
              canBuyRocket() else {
            print("Cannot buy rocket - regionIndex: \(selectedRegionIndex ?? -1), canBuy: \(canBuyRocket())")
            return
        }
        
        print("Buying rocket for region: \(regionIndex)")
        gameManager.buyRocketForRegion(regionIndex)
        updateAttackTargets()
        closeRegionMenu()
        print("Rocket purchased. Player rockets: \(humanPlayer?.availableRockets ?? 0)")
    }
    
    func buyAirDefense() {
        guard let regionIndex = selectedRegionIndex,
              canBuyAirDefense(for: regionIndex) else { return }
        
        gameManager.buyAirDefenseForRegion(regionIndex)
        updateAttackTargets()
        closeRegionMenu()
    }
    
    func closeRegionMenu() {
        showingRegionMenu = false
        selectedRegionIndex = nil
        updateAttackTargets()
    }
    
    // MARK: - Targeting Phase Actions
    func selectAttackTarget(countryIndex: Int, regionIndex: Int) {
        gameManager.selectAttackTarget(countryIndex: countryIndex, regionIndex: regionIndex)
        updateAttackTargets()
    }
    
    func removeAttackTarget(at index: Int) {
        gameManager.removeAttackTarget(at: index)
        updateAttackTargets()
    }
    
    // MARK: - Game State Properties
    var currentGame: Game {
        gameManager.game
    }
    
    var humanPlayer: Player? {
        gameManager.humanPlayer
    }
    
    var humanCountry: Country? {
        gameManager.humanCountry
    }
    
    var currentPhase: GamePhase {
        currentGame.currentPhase
    }
    
    var currentRound: Int {
        currentGame.currentRound
    }
    
    var maxRounds: Int {
        currentGame.maxRounds
    }
    
    var currentPhaseDisplayName: String {
        currentPhase.displayName
    }
    
    var canEndPhase: Bool {
        gameManager.canEndPhase
    }
    
    var isProcessingTurn: Bool {
        gameManager.isProcessingTurn
    }
    
    var animationInProgress: Bool {
        gameManager.animationInProgress
    }
    
    // MARK: - Region State Queries
    func isRegionDestroyed(countryIndex: Int, regionIndex: Int) -> Bool {
        print("=== isRegionDestroyed Check ===")
        print("Checking countryIndex: \(countryIndex), regionIndex: \(regionIndex)")
        print("Total countries in game: \(currentGame.countries.count)")
        
        for (index, country) in currentGame.countries.enumerated() {
            print("Country[\(index)]: countryIndex=\(country.countryIndex), name=\(country.name), regions=\(country.regions.count)")
        }
        
        guard let country = currentGame.countries.first(where: { $0.countryIndex == countryIndex }) else {
            print("ERROR: Country not found for countryIndex: \(countryIndex)")
            return true
        }
        
        print("Found country: \(country.name) with \(country.regions.count) regions")
        
        guard regionIndex < country.regions.count else {
            print("ERROR: regionIndex \(regionIndex) >= regions count \(country.regions.count)")
            return true
        }
        
        let isDestroyed = country.regions[regionIndex].isDestroyed
        print("Region[\(regionIndex)] isDestroyed: \(isDestroyed)")
        print("=== isRegionDestroyed Check Complete ===")
        
        return isDestroyed
    }
    
    func isHumanRegion(countryIndex: Int) -> Bool {
        let humanCountryIndex = humanPlayer?.countryIndex
        let isHuman = humanCountryIndex == countryIndex
        print("isHumanRegion check: countryIndex=\(countryIndex), humanCountryIndex=\(humanCountryIndex ?? -1), isHuman=\(isHuman)")
        return isHuman
    }
    
    func regionHasAirDefense(countryIndex: Int, regionIndex: Int) -> Bool {
        guard let country = currentGame.countries.first(where: { $0.countryIndex == countryIndex }),
              regionIndex < country.regions.count else { return false }
        return country.regions[regionIndex].hasAirDefense
    }
    
    func isRegionTargeted(countryIndex: Int, regionIndex: Int) -> Bool {
        return attackTargets.contains { target in
            target.targetCountryIndex == countryIndex && target.targetRegionIndex == regionIndex
        }
    }
    
    func canInteractWithRegion(countryIndex: Int, regionIndex: Int) -> Bool {
        let destroyed = isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex)
        
        guard !destroyed else {
            print("Cannot interact - region destroyed: countryIndex=\(countryIndex), regionIndex=\(regionIndex)")
            return false
        }
        
        switch currentPhase {
        case .economy:
            let canInteract = isHumanRegion(countryIndex: countryIndex)
            print("Economy phase - can interact with countryIndex=\(countryIndex): \(canInteract)")
            return canInteract
        case .targeting:
            let isHuman = isHumanRegion(countryIndex: countryIndex)
            let hasRockets = (humanPlayer?.availableRockets ?? 0) > 0
            let canInteract = !isHuman && hasRockets
            print("Targeting phase - countryIndex=\(countryIndex), isHuman=\(isHuman), hasRockets=\(hasRockets), canInteract=\(canInteract)")
            return canInteract
        case .resolution:
            print("Resolution phase - no interaction allowed")
            return false
        }
    }
    
    // MARK: - Purchase Capabilities
    func canBuyRocket() -> Bool {
        gameManager.canBuyRocket()
    }
    
    func canBuyAirDefense(for regionIndex: Int) -> Bool {
        gameManager.canBuyAirDefense(for: regionIndex)
    }
    
    // MARK: - Visual Properties
    func getRegionOpacity(countryIndex: Int, regionIndex: Int) -> Double {
        isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) ? 0.5 : 1.0
    }
    
    func getRegionPosition(countryIndex: Int, regionIndex: Int) -> CGPoint {
        guard let country = currentGame.countries.first(where: { $0.countryIndex == countryIndex }),
              regionIndex < country.regions.count else {
            return .zero
        }
        return country.regions[regionIndex].position
    }
    
    func getRegionShape(countryIndex: Int, regionIndex: Int) -> String {
        switch (countryIndex, regionIndex) {
        case (0, 0): return "usa1"
        case (0, 1): return "usa2"
        case (0, 2): return "usa3"
        case (0, 3): return "usa4"
        case (0, 4): return "usa5"
        case (1, 0): return "iran1"
        case (1, 1): return "iran2"
        case (1, 2): return "iran3"
        case (1, 3): return "iran4"
        case (1, 4): return "iran5"
        case (2, 0): return "china1"
        case (2, 1): return "china2"
        case (2, 2): return "china3"
        case (2, 3): return "china4"
        case (2, 4): return "china5"
        case (3, 0): return "nk1"
        case (3, 1): return "nk2"
        case (3, 2): return "nk3"
        case (3, 3): return "nk4"
        case (3, 4): return "nk5"
        default: return "usa1"
        }
    }
    
    // MARK: - Country Information
    func getCountryName(at index: Int) -> String {
        guard let country = currentGame.countries.first(where: { $0.countryIndex == index }) else { return "Unknown" }
        return country.name
    }
    
    func getCountryRegionCount(at index: Int) -> Int {
        guard let country = currentGame.countries.first(where: { $0.countryIndex == index }) else { return 0 }
        return country.aliveRegionsCount
    }
    
    func isCountryDestroyed(at index: Int) -> Bool {
        guard let country = currentGame.countries.first(where: { $0.countryIndex == index }) else { return true }
        return country.isDestroyed
    }
    
    // MARK: - Player Statistics
    func getPlayerStats() -> (regions: Int, coins: Int, rockets: Int, income: Int) {
        guard let player = humanPlayer, let country = humanCountry else {
            return (0, 0, 0, 0)
        }
        return (
            regions: country.aliveRegionsCount,
            coins: player.coins,
            rockets: player.availableRockets,
            income: country.totalIncome
        )
    }
    
    // MARK: - Purchase Menu Properties
    var rocketCost: Int { 20 }
    var airDefenseCost: Int { 20 }
    
    func getRocketButtonText() -> String {
        guard let player = humanPlayer else { return "Buy Rocket 20" }
        
        if !canBuyRocket() {
            if player.coins < rocketCost {
                return "Need \(rocketCost) coins"
            } else if player.rocketsUsedThisTurn >= player.maxRocketsPerTurn {
                return "Max rockets (\(player.maxRocketsPerTurn))"
            } else {
                return "Cannot buy rocket"
            }
        }
        return "Buy Rocket \(rocketCost)"
    }
    
    func getAirDefenseButtonText() -> String {
        guard let player = humanPlayer,
              let regionIndex = selectedRegionIndex else { return "Buy Air Defense 20" }
        
        if !canBuyAirDefense(for: regionIndex) {
            if player.coins < airDefenseCost {
                return "Need \(airDefenseCost) coins"
            } else if let humanCountryIndex = humanPlayer?.countryIndex,
                      regionHasAirDefense(countryIndex: humanCountryIndex, regionIndex: regionIndex) {
                return "Already protected"
            } else {
                return "Cannot buy defense"
            }
        }
        return "Buy Air Defense \(airDefenseCost)"
    }
    
    // MARK: - Phase Instructions
    func getCurrentPhaseInstructions() -> String {
        switch currentPhase {
        case .economy:
            return "Tap your regions to buy rockets or air defense. Press 'End Phase' when ready."
        case .targeting:
            return "Tap enemy regions to attack with rockets. Press 'End Phase' after."
        case .resolution:
            return "Attacks are being resolved. Watch the results!"
        }
    }
    
    // MARK: - Game End Messages
    func getGameEndMessage() -> String {
        guard let result = gameResult else { return "" }
        
        switch result.state {
        case .victory:
            return "Victory! \nYou are the last nation standing!"
        case .defeat:
            return "Defeat! \nYour nation has been destroyed."
        case .draw:
            return "Draw! \nAll nations destroyed each other."
        case .maxRoundsReached:
            if let winnerIndex = result.winnerCountryIndex {
                return "Time limit reached! \(getCountryName(at: winnerIndex)) wins with the most regions."
            }
            return "Time limit reached! Game ended in a tie."
        case .notStarted, .inProgress:
            return ""
        }
    }
    
    // MARK: - Round Progress
    func getRoundProgress() -> Double {
        guard maxRounds > 0 else { return 0 }
        return Double(currentRound) / Double(maxRounds)
    }
    
    func getRoundDisplayText() -> String {
        return "Round \(currentRound)/\(maxRounds)"
    }
    
    // MARK: - Setup
    func setupWith(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        
        // Update opponent count if it has changed
        if self.opponentCount != appViewModel.opponentCount {
            self.opponentCount = appViewModel.opponentCount
            self.gameManager = GameManager(opponentCount: opponentCount)
            setupObservers()
        }
        
        updateAttackTargets()
    }
}
