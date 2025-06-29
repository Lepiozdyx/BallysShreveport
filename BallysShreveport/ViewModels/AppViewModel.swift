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
    @Published var achievementManager = AchievementManager()
    @Published var backgrounds: [BackgroundItem] = []
    @Published var currentBackground: BackgroundType = .bg
    @Published var gameManager: GameManager?
    
    @AppStorage("musicEnabled") var musicEnabled: Bool = true
    
    private let coinsKey = "bally_player_coins"
    private let ownedBackgroundsKey = "bally_owned_backgrounds"
    private let currentBackgroundKey = "bally_current_background"
    
    init() {
        loadPlayerData()
        initializeBackgrounds()
    }
    
    // MARK: - Navigation Management
    func navigateTo(_ screen: Navigation) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
    
    func navigateBackToMenu() {
        // Clear game manager when returning to menu
        gameManager = nil
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
        createGameManager()
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
        createGameManager()
        navigateTo(.game)
    }
    
    // MARK: - Game Manager Management
    private func createGameManager() {
        gameManager = GameManager(opponentCount: opponentCount)
    }
    
    func restartGame() {
        createGameManager()
    }
    
    // MARK: - Player Data Management
    private func loadPlayerData() {
        coins = UserDefaults.standard.integer(forKey: coinsKey)
        loadBackgroundData()
    }
    
    private func savePlayerData() {
        UserDefaults.standard.set(coins, forKey: coinsKey)
        saveBackgroundData()
    }
    
    // MARK: - Background Management
    private func initializeBackgrounds() {
        let ownedBackgrounds = getOwnedBackgrounds()
        
        backgrounds = BackgroundType.allCases.map { type in
            var item = BackgroundItem(type: type)
            item.isOwned = ownedBackgrounds.contains(type.rawValue) || type.isFree
            return item
        }
    }
    
    private func loadBackgroundData() {
        if let backgroundRawValue = UserDefaults.standard.string(forKey: currentBackgroundKey),
           let background = BackgroundType(rawValue: backgroundRawValue) {
            currentBackground = background
        }
    }
    
    private func saveBackgroundData() {
        UserDefaults.standard.set(currentBackground.rawValue, forKey: currentBackgroundKey)
        
        let ownedBackgroundRawValues = backgrounds
            .filter { $0.isOwned }
            .map { $0.type.rawValue }
        UserDefaults.standard.set(ownedBackgroundRawValues, forKey: ownedBackgroundsKey)
    }
    
    private func getOwnedBackgrounds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: ownedBackgroundsKey) ?? []
    }
    
    func handleBackgroundAction(for backgroundType: BackgroundType) {
        guard let index = backgrounds.firstIndex(where: { $0.type == backgroundType }) else { return }
        let backgroundItem = backgrounds[index]
        
        if backgroundItem.isOwned {
            // Select background
            currentBackground = backgroundType
            saveBackgroundData()
        } else {
            // Try to buy background
            if canSpendCoins(backgroundItem.price) {
                if spendCoins(backgroundItem.price) {
                    backgrounds[index].isOwned = true
                    currentBackground = backgroundType
                    saveBackgroundData()
                    
                    // Trigger SHOPPER achievement on first purchase
                    if !achievementManager.isAchievementUnlocked(type: .shopper) {
                        achievementManager.onFirstPurchase()
                    }
                }
            }
        }
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
    
    // MARK: - Settings Management
    func toggleMusic() {
        musicEnabled.toggle()
        if musicEnabled {
            SoundManager.shared.playBackgroundMusic()
        } else {
            SoundManager.shared.stopBackgroundMusic()
        }
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        musicEnabled = enabled
        if enabled {
            SoundManager.shared.playBackgroundMusic()
        } else {
            SoundManager.shared.stopBackgroundMusic()
        }
    }
}
