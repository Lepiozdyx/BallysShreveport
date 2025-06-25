import SwiftUI
import Foundation

@MainActor
class AppViewModel: ObservableObject {
    
    enum Difficulty {
        case novice, strategist, agressor
    }
    
    @Published var currentScreen: Navigation = .menu
    @Published var coins: Int = 0
    @Published var isLoading: Bool = false
    @Published var difficulty: Difficulty = .strategist
    @Published var opponentCount: Int = 3
    
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
        navigateTo(.aiModeSetup)
    }
    
    func navigateToGame() {
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
            addCoins(100) // +100 coins for victory as per Terms
        case .defeat, .draw, .maxRoundsReached:
            break // No reward for these outcomes
        case .notStarted, .inProgress:
            break // Invalid completion states
        }
    }
}
