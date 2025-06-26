import Foundation

enum LevelStatus: String, Codable {
    case locked = "locked"
    case unlocked = "unlocked"
    case completed = "completed"
}

struct CampaignLevel: Identifiable, Codable {
    let id: Int
    let levelNumber: Int
    var status: LevelStatus
    let opponentCount: Int
    
    init(levelNumber: Int, status: LevelStatus = .locked) {
        self.id = levelNumber
        self.levelNumber = levelNumber
        self.status = status
        
        switch levelNumber {
        case 1:
            self.opponentCount = 1
        case 2:
            self.opponentCount = 2
        default:
            self.opponentCount = 3
        }
    }
    
    var isPlayable: Bool {
        return status == .unlocked || status == .completed
    }
    
    var displayText: String {
        return "\(levelNumber)"
    }
}
