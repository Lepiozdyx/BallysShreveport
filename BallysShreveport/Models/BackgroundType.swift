import Foundation

enum BackgroundType: String, CaseIterable, Codable {
    case bg = "bg"
    case bg2 = "bg2"
    case bg3 = "bg3"
    case bg4 = "bg4"
    
    var imageName: String {
        return self.rawValue
    }
    
    var price: Int {
        switch self {
        case .bg:
            return 0
        case .bg2:
            return 100
        case .bg3:
            return 200
        case .bg4:
            return 300
        }
    }
    
    var isFree: Bool {
        return price == 0
    }
    
    var displayIndex: Int {
        switch self {
        case .bg: return 1
        case .bg2: return 2
        case .bg3: return 3
        case .bg4: return 4
        }
    }
}

// MARK: - Background Item
struct BackgroundItem: Identifiable, Codable {
    var id = UUID()
    let type: BackgroundType
    var isOwned: Bool
    
    init(type: BackgroundType) {
        self.type = type
        self.isOwned = type.isFree
    }
    
    var price: Int {
        return type.price
    }
    
    var imageName: String {
        return type.imageName
    }
    
    var displayIndex: Int {
        return type.displayIndex
    }
}

// MARK: - Background Button State
enum BackgroundButtonState {
    case selected
    case select
    case buy(price: Int)
    
    var text: String {
        switch self {
        case .selected:
            return "SELECTED"
        case .select:
            return "SELECT"
        case .buy(let price):
            return "BUY \(price)"
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .selected:
            return false
        case .select:
            return true
        case .buy:
            return true
        }
    }
}
