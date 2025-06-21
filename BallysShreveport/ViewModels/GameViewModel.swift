import SwiftUI
import Foundation

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameManager: GameManager
    @Published var showPauseMenu: Bool = false
    @Published var showResultScreen: Bool = false
    @Published var gameResult: GameResult?
    @Published var selectedRegionIndex: Int?
    @Published var showingRegionMenu: Bool = false
    @Published var regionMenuPosition: CGPoint = .zero
    
    weak var appViewModel: AppViewModel?
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    // MARK: - Game Lifecycle
    func startNewGame() {
        gameManager.startNewGame()
        resetGameUI()
    }
    
    func pauseGame() {
        showPauseMenu = true
        gameManager.pauseGame()
    }
    
    func resumeGame() {
        showPauseMenu = false
        gameManager.resumeGame()
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
    }
    
    // MARK: - Phase Management
    func endCurrentPhase() {
        gameManager.endCurrentPhase()
        closeRegionMenu()
        checkForGameEnd()
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
        switch currentPhase {
        case .economy:
            handleEconomyPhaseTap(countryIndex: countryIndex, regionIndex: regionIndex, position: position)
        case .targeting:
            handleTargetingPhaseTap(countryIndex: countryIndex, regionIndex: regionIndex)
        case .resolution:
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
            regionMenuPosition = position
            showingRegionMenu = true
        }
    }
    
    private func handleTargetingPhaseTap(countryIndex: Int, regionIndex: Int) {
        guard !isHumanRegion(countryIndex: countryIndex),
              !isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex),
              humanPlayer?.availableRockets ?? 0 > 0 else { return }
        
        selectAttackTarget(countryIndex: countryIndex, regionIndex: regionIndex)
    }
    
    // MARK: - Economy Phase Actions
    func buyRocket() {
        guard let regionIndex = selectedRegionIndex,
              canBuyRocket() else { return }
        
        gameManager.buyRocketForRegion(regionIndex)
        closeRegionMenu()
    }
    
    func buyAirDefense() {
        guard let regionIndex = selectedRegionIndex,
              canBuyAirDefense(for: regionIndex) else { return }
        
        gameManager.buyAirDefenseForRegion(regionIndex)
        closeRegionMenu()
    }
    
    func closeRegionMenu() {
        showingRegionMenu = false
        selectedRegionIndex = nil
    }
    
    // MARK: - Targeting Phase Actions
    func selectAttackTarget(countryIndex: Int, regionIndex: Int) {
        gameManager.selectAttackTarget(countryIndex: countryIndex, regionIndex: regionIndex)
    }
    
    func removeAttackTarget(at index: Int) {
        gameManager.removeAttackTarget(at: index)
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
    
    var attackTargets: [AttackTarget] {
        gameManager.getAttackTargets()
    }
    
    // MARK: - Region State Queries
    func isRegionDestroyed(countryIndex: Int, regionIndex: Int) -> Bool {
        gameManager.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex)
    }
    
    func isHumanRegion(countryIndex: Int) -> Bool {
        humanPlayer?.countryIndex == countryIndex
    }
    
    func regionHasAirDefense(countryIndex: Int, regionIndex: Int) -> Bool {
        guard countryIndex < currentGame.countries.count,
              regionIndex < currentGame.countries[countryIndex].regions.count else { return false }
        return currentGame.countries[countryIndex].regions[regionIndex].hasAirDefense
    }
    
    func isRegionTargeted(countryIndex: Int, regionIndex: Int) -> Bool {
        attackTargets.contains { target in
            target.targetCountryIndex == countryIndex && target.targetRegionIndex == regionIndex
        }
    }
    
    func canInteractWithRegion(countryIndex: Int, regionIndex: Int) -> Bool {
        guard !isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) else { return false }
        
        switch currentPhase {
        case .economy:
            return isHumanRegion(countryIndex: countryIndex)
        case .targeting:
            return !isHumanRegion(countryIndex: countryIndex) && (humanPlayer?.availableRockets ?? 0) > 0
        case .resolution:
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
        guard countryIndex < currentGame.countries.count,
              regionIndex < currentGame.countries[countryIndex].regions.count else {
            return .zero
        }
        return currentGame.countries[countryIndex].regions[regionIndex].position
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
        guard index < currentGame.countries.count else { return "Unknown" }
        return currentGame.countries[index].name
    }
    
    func getCountryRegionCount(at index: Int) -> Int {
        guard index < currentGame.countries.count else { return 0 }
        return currentGame.countries[index].aliveRegionsCount
    }
    
    func isCountryDestroyed(at index: Int) -> Bool {
        guard index < currentGame.countries.count else { return true }
        return currentGame.countries[index].isDestroyed
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
    
    func getRegionMenuPosition(for regionPosition: CGPoint, screenSize: CGSize) -> CGPoint {
        let menuWidth: CGFloat = 200
        let menuHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        var x = regionPosition.x - menuWidth / 2
        var y = regionPosition.y - menuHeight - padding
        
        // Keep menu within screen bounds
        if x + menuWidth > screenSize.width - padding {
            x = screenSize.width - menuWidth - padding
        }
        if x < padding {
            x = padding
        }
        if y < padding {
            y = regionPosition.y + padding + 60
        }
        
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - Phase Instructions
    func getCurrentPhaseInstructions() -> String {
        switch currentPhase {
        case .economy:
            return "Tap your regions to buy rockets (20 coins) or air defense (20 coins). Press 'End Phase' when ready."
        case .targeting:
            return "Tap enemy regions to attack with rockets. You can skip attacks. Press 'End Phase' when ready."
        case .resolution:
            return "Attacks are being resolved. Watch the results!"
        }
    }
    
    // MARK: - Game End Messages
    func getGameEndMessage() -> String {
        guard let result = gameResult else { return "" }
        
        switch result.state {
        case .victory:
            return "Victory! You are the last nation standing!"
        case .defeat:
            return "Defeat! Your nation has been destroyed."
        case .draw:
            return "Draw! All nations destroyed each other."
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
    }
}
