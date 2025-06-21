import Foundation

// MARK: - Game Action
enum GameAction: Codable, Equatable {
    case buyRocket(regionIndex: Int)
    case buyAirDefense(regionIndex: Int)
    case none
}

// MARK: - Attack Target
struct AttackTarget: Identifiable, Codable, Equatable {
    var id = UUID()
    let attackerCountryIndex: Int
    let targetCountryIndex: Int
    let targetRegionIndex: Int
    
    init(attackerCountryIndex: Int, targetCountryIndex: Int, targetRegionIndex: Int) {
        self.attackerCountryIndex = attackerCountryIndex
        self.targetCountryIndex = targetCountryIndex
        self.targetRegionIndex = targetRegionIndex
    }
}

// MARK: - Attack Result
struct AttackResult: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let attack: AttackTarget
    let wasBlocked: Bool
    let wasSuccessful: Bool
    
    init(attack: AttackTarget, wasBlocked: Bool) {
        self.attack = attack
        self.wasBlocked = wasBlocked
        self.wasSuccessful = !wasBlocked
    }
}

// MARK: - Player Turn Actions
struct PlayerTurnActions: Identifiable, Codable, Equatable {
    var id: UUID { playerId }
    let playerId: UUID
    var purchaseActions: [GameAction] = []
    var attackTargets: [AttackTarget] = []
    
    init(playerId: UUID) {
        self.playerId = playerId
    }
    
    mutating func addPurchaseAction(_ action: GameAction) {
        purchaseActions.append(action)
    }
    
    mutating func addAttackTarget(_ target: AttackTarget) {
        attackTargets.append(target)
    }
    
    mutating func removeAttackTarget(at index: Int) {
        guard index < attackTargets.count else { return }
        attackTargets.remove(at: index)
    }
    
    mutating func clearActions() {
        purchaseActions.removeAll()
        attackTargets.removeAll()
    }
    
    var hasActions: Bool {
        return !purchaseActions.isEmpty || !attackTargets.isEmpty
    }
}

// MARK: - Destroyed Region
struct DestroyedRegion: Codable, Equatable {
    let countryIndex: Int
    let regionIndex: Int
    
    init(countryIndex: Int, regionIndex: Int) {
        self.countryIndex = countryIndex
        self.regionIndex = regionIndex
    }
}

// MARK: - Turn Resolution
struct TurnResolution: Codable, Equatable {
    let roundNumber: Int
    let attackResults: [AttackResult]
    let destroyedRegions: [DestroyedRegion]
    
    init(roundNumber: Int, attackResults: [AttackResult], destroyedRegions: [DestroyedRegion]) {
        self.roundNumber = roundNumber
        self.attackResults = attackResults
        self.destroyedRegions = destroyedRegions
    }
    
    var hasDestroyedRegions: Bool {
        return !destroyedRegions.isEmpty
    }
    
    var successfulAttacks: [AttackResult] {
        return attackResults.filter { $0.wasSuccessful }
    }
    
    var blockedAttacks: [AttackResult] {
        return attackResults.filter { $0.wasBlocked }
    }
}
