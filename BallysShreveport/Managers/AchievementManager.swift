import Foundation

@MainActor
class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    private let achievementsKey = "bally_achievements"
    
    init() {
        loadAchievements()
    }
    
    // MARK: - Achievement Management
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = savedAchievements
        } else {
            createDefaultAchievements()
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    private func createDefaultAchievements() {
        achievements = AchievementType.allCases.map { Achievement(type: $0) }
        saveAchievements()
    }
    
    // MARK: - Unlock Methods
    func unlockAchievement(type: AchievementType) {
        guard let index = achievements.firstIndex(where: { $0.type == type }),
              achievements[index].canBeUnlocked,
              !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        saveAchievements()
        
        print("Achievement unlocked: \(type.title)")
    }
    
    func isAchievementUnlocked(type: AchievementType) -> Bool {
        return achievements.first(where: { $0.type == type })?.isUnlocked ?? false
    }
    
    // MARK: - Specific Achievement Triggers
    func onFirstPurchase() {
        unlockAchievement(type: .shopper)
    }
    
    // MARK: - Statistics
    var unlockedCount: Int {
        return achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        return achievements.count
    }
    
    var unlockedAchievements: [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    // MARK: - Debug Methods
    func resetAllAchievements() {
        for i in 0..<achievements.count {
            achievements[i].isUnlocked = false
        }
        saveAchievements()
    }
    
    func unlockAllTestAchievements() {
        unlockAchievement(type: .shopper)
    }
}
