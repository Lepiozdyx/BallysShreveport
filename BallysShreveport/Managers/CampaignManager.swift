import Foundation

@MainActor
class CampaignManager: ObservableObject {
    @Published var levels: [CampaignLevel] = []
    @Published var currentLevel: Int = 1
    @Published var maxUnlockedLevel: Int = 1
    
    private let maxUnlockedLevelKey = "campaign_max_unlocked_level"
    private let completedLevelsKey = "campaign_completed_levels"
    private let totalLevels = 15
    
    init() {
        loadProgress()
        createLevels()
    }
    
    private func createLevels() {
        levels.removeAll()
        
        for levelNumber in 1...totalLevels {
            var status: LevelStatus
            
            if levelNumber == 1 && maxUnlockedLevel == 0 {
                status = .unlocked
            } else if levelNumber <= maxUnlockedLevel {
                status = getCompletedLevels().contains(levelNumber) ? .completed : .unlocked
            } else {
                status = .locked
            }
            
            let level = CampaignLevel(levelNumber: levelNumber, status: status)
            levels.append(level)
        }
    }
    
    func selectLevel(_ levelNumber: Int) {
        guard levelNumber <= maxUnlockedLevel else { return }
        currentLevel = levelNumber
    }
    
    func completeLevel(_ levelNumber: Int) {
        guard levelNumber <= totalLevels else { return }
        
        var completedLevels = getCompletedLevels()
        completedLevels.insert(levelNumber)
        saveCompletedLevels(completedLevels)
        
        if levelNumber == maxUnlockedLevel && levelNumber < totalLevels {
            maxUnlockedLevel = levelNumber + 1
            saveProgress()
        }
        
        createLevels()
    }
    
    func getOpponentCount(for levelNumber: Int) -> Int {
        switch levelNumber {
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 3
        }
    }
    
    func hasNextLevel() -> Bool {
        return currentLevel < maxUnlockedLevel || (currentLevel < totalLevels && maxUnlockedLevel > currentLevel)
    }
    
    func getNextLevel() -> Int? {
        let nextLevel = currentLevel + 1
        return nextLevel <= maxUnlockedLevel ? nextLevel : nil
    }
    
    private func loadProgress() {
        maxUnlockedLevel = max(1, UserDefaults.standard.integer(forKey: maxUnlockedLevelKey))
        if maxUnlockedLevel == 0 {
            maxUnlockedLevel = 1
        }
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(maxUnlockedLevel, forKey: maxUnlockedLevelKey)
    }
    
    private func getCompletedLevels() -> Set<Int> {
        let data = UserDefaults.standard.data(forKey: completedLevelsKey) ?? Data()
        return (try? JSONDecoder().decode(Set<Int>.self, from: data)) ?? []
    }
    
    private func saveCompletedLevels(_ levels: Set<Int>) {
        let data = (try? JSONEncoder().encode(levels)) ?? Data()
        UserDefaults.standard.set(data, forKey: completedLevelsKey)
    }
    
    func resetProgress() {
        maxUnlockedLevel = 1
        UserDefaults.standard.removeObject(forKey: maxUnlockedLevelKey)
        UserDefaults.standard.removeObject(forKey: completedLevelsKey)
        createLevels()
    }
}
