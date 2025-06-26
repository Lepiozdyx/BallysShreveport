import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    enum Difficulty {
        case novice, strategist, agressor
    }
    
    enum GameMode {
        case vsAI
        case campaign
    }
    
    @Published var currentScreen: Navigation = .menu
    @Published var coins: Int = 0
    @Published var isLoading: Bool = false
    @Published var difficulty: Difficulty = .strategist
    @Published var opponentCount: Int = 3
    @Published var currentGameMode: GameMode = .vsAI
    @Published var campaignManager = CampaignManager()
    
    private let coinsKey = "bally_player_coins"
    
    init() {
        loadPlayerData()
    }
    
    // MARK: - Navigation Management
    func navigateTo(_ screen: Navigation) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
    
    func navigateBackToMenu() {
        navigateTo(.menu)
    }
    
    func navigateToModeSelection() {
        navigateTo(.modeSelection)
    }
    
    func navigateToAIModeSetup() {
        currentGameMode = .vsAI
        navigateTo(.aiModeSetup)
    }
    
    func navigateToGame() {
        currentGameMode = .vsAI
        navigateTo(.game)
    }
    
    func navigateToCampaignLevelSelection() {
        currentGameMode = .campaign
        navigateTo(.campaignLevelSelection)
    }
    
    func navigateToCampaignGame(level: Int) {
        currentGameMode = .campaign
        campaignManager.selectLevel(level)
        opponentCount = campaignManager.getOpponentCount(for: level)
        navigateTo(.game)
    }
    
    // MARK: - Player Data Management
    private func loadPlayerData() {
        coins = UserDefaults.standard.integer(forKey: coinsKey)
    }
    
    private func savePlayerData() {
        UserDefaults.standard.set(coins, forKey: coinsKey)
    }
    
    // MARK: - Coins Management
    func addCoins(_ amount: Int) {
        coins += amount
        savePlayerData()
    }
    
    func canSpendCoins(_ amount: Int) -> Bool {
        return coins >= amount
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard canSpendCoins(amount) else { return false }
        coins -= amount
        savePlayerData()
        return true
    }
    
    // MARK: - Game Completion Rewards
    func handleGameCompletion(result: GameResult) {
        switch result.state {
        case .victory:
            addCoins(100)
            if currentGameMode == .campaign {
                campaignManager.completeLevel(campaignManager.currentLevel)
            }
        case .defeat, .draw, .maxRoundsReached:
            break
        case .notStarted, .inProgress:
            break
        }
    }
    
    // MARK: - Campaign Management
    func hasNextCampaignLevel() -> Bool {
        return currentGameMode == .campaign && campaignManager.hasNextLevel()
    }
    
    func goToNextCampaignLevel() {
        guard let nextLevel = campaignManager.getNextLevel() else { return }
        navigateToCampaignGame(level: nextLevel)
    }
}
