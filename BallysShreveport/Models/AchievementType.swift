import Foundation

enum AchievementType: String, CaseIterable, Codable {
    case shopper = "shopper"
    case collector = "collector"
    case campaignMaster = "campaign_master"
    case loyalCommander = "loyal_commander"
    case tacticalDuo = "tactical_duo"
    
    var iconName: ImageResource {
        switch self {
        case .shopper:
            return .achi1
        case .collector:
            return .achi2
        case .campaignMaster:
            return .achi3
        case .loyalCommander:
            return .achi4
        case .tacticalDuo:
            return .achi5
        }
    }
    
    var title: String {
        switch self {
        case .shopper:
            return "SHOPPER"
        case .collector:
            return "COLLECTOR"
        case .campaignMaster:
            return "CAMPAIGN MASTER"
        case .loyalCommander:
            return "LOYAL COMMANDER"
        case .tacticalDuo:
            return "TACTICAL"
        }
    }
    
    var description: String {
        switch self {
        case .shopper:
            return "PURCHASE THE FIRST ITEM IN THE STORE"
        case .collector:
            return "PURCHASE ALL AVAILABLE ITEMS IN THE STORE"
        case .campaignMaster:
            return "COMPLETE THE STORY CAMPAIGN"
        case .loyalCommander:
            return "LOG INTO THE GAME FOR 7 CONSECUTIVE DAYS"
        case .tacticalDuo:
            return "PLAY A MULTIPLAYER GAME"
        }
    }
    
    var canBeUnlocked: Bool {
        switch self {
        case .shopper:
            return true
        case .collector, .campaignMaster, .loyalCommander, .tacticalDuo:
            return false
        }
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    var id = UUID()
    let type: AchievementType
    var isUnlocked: Bool = false
    
    init(type: AchievementType) {
        self.type = type
        self.isUnlocked = false
    }
    
    var title: String {
        return type.title
    }
    
    var description: String {
        return type.description
    }
    
    var iconName: ImageResource {
        return type.iconName
    }
    
    var canBeUnlocked: Bool {
        return type.canBeUnlocked
    }
}
