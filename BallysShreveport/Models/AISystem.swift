import Foundation

// MARK: - AI Strategy
enum AIStrategy: String, Codable, CaseIterable {
    case aggressive = "aggressive"
    case balanced = "balanced"
    case defensive = "defensive"
    
    var rocketPriority: Double {
        switch self {
        case .aggressive: return 0.8
        case .balanced: return 0.6
        case .defensive: return 0.4
        }
    }
    
    var airDefensePriority: Double {
        switch self {
        case .aggressive: return 0.2
        case .balanced: return 0.4
        case .defensive: return 0.6
        }
    }
}

// MARK: - AI Decision
struct AIDecision {
    let action: GameAction
    let priority: Double
    let regionIndex: Int
}

// MARK: - AI Target Selection
struct AITargetSelection {
    let target: AttackTarget
    let priority: Double
    let reasoning: String
}

// MARK: - AI System
class AISystem {
    private let strategy: AIStrategy
    
    init(strategy: AIStrategy = .aggressive) {
        self.strategy = strategy
    }
    
    // MARK: - Economy Phase Decision Making
    func makePurchaseDecisions(for player: Player, country: Country, allCountries: [Country]) -> [GameAction] {
        var decisions: [AIDecision] = []
        var availableCoins = player.coins
        
        // Evaluate each region for potential purchases
        for (regionIndex, region) in country.regions.enumerated() {
            if region.isDestroyed { continue }
            
            // Consider buying air defense
            if region.canBuyAirDefense && availableCoins >= player.airDefenseCost {
                let priority = calculateAirDefensePriority(for: regionIndex, country: country, allCountries: allCountries)
                decisions.append(AIDecision(
                    action: .buyAirDefense(regionIndex: regionIndex),
                    priority: priority * strategy.airDefensePriority,
                    regionIndex: regionIndex
                ))
            }
        }
        
        // Consider buying rockets (up to 2 per turn)
        var rocketsCanBuy = min(player.maxRocketsPerTurn - player.rocketsUsedThisTurn, availableCoins / player.rocketCost)
        
        while rocketsCanBuy > 0 && availableCoins >= player.rocketCost {
            let regionIndex = selectBestRegionForRocket(country: country)
            let priority = calculateRocketPriority(allCountries: allCountries)
            
            decisions.append(AIDecision(
                action: .buyRocket(regionIndex: regionIndex),
                priority: priority * strategy.rocketPriority,
                regionIndex: regionIndex
            ))
            
            availableCoins -= player.rocketCost
            rocketsCanBuy -= 1
        }
        
        // Sort by priority and execute affordable decisions
        decisions.sort { $0.priority > $1.priority }
        
        var finalActions: [GameAction] = []
        availableCoins = player.coins
        var rocketsUsed = player.rocketsUsedThisTurn
        
        for decision in decisions {
            switch decision.action {
            case .buyRocket:
                if availableCoins >= player.rocketCost && rocketsUsed < player.maxRocketsPerTurn {
                    finalActions.append(decision.action)
                    availableCoins -= player.rocketCost
                    rocketsUsed += 1
                }
            case .buyAirDefense:
                if availableCoins >= player.airDefenseCost {
                    finalActions.append(decision.action)
                    availableCoins -= player.airDefenseCost
                }
            case .none:
                break
            }
        }
        
        return finalActions
    }
    
    // MARK: - Targeting Phase Decision Making
    func selectAttackTargets(for player: Player, country: Country, allCountries: [Country]) -> [AttackTarget] {
        guard player.availableRockets > 0 else { return [] }
        
        var targetSelections: [AITargetSelection] = []
        
        // Evaluate all possible targets
        for (countryIndex, targetCountry) in allCountries.enumerated() {
            if countryIndex == player.countryIndex || targetCountry.isDestroyed { continue }
            
            for (regionIndex, region) in targetCountry.regions.enumerated() {
                if region.isDestroyed { continue }
                
                let priority = calculateTargetPriority(
                    targetCountryIndex: countryIndex,
                    targetRegionIndex: regionIndex,
                    targetCountry: targetCountry,
                    allCountries: allCountries,
                    attackerCountryIndex: player.countryIndex
                )
                
                let target = AttackTarget(
                    attackerCountryIndex: player.countryIndex,
                    targetCountryIndex: countryIndex,
                    targetRegionIndex: regionIndex
                )
                
                targetSelections.append(AITargetSelection(
                    target: target,
                    priority: priority,
                    reasoning: "Strategic target"
                ))
            }
        }
        
        // Sort by priority and select top targets up to available rockets
        targetSelections.sort { $0.priority > $1.priority }
        
        let selectedTargets = Array(targetSelections.prefix(player.availableRockets)).map { $0.target }
        
        return selectedTargets
    }
    
    // MARK: - Priority Calculation Methods
    private func calculateAirDefensePriority(for regionIndex: Int, country: Country, allCountries: [Country]) -> Double {
        var priority: Double = 0.5
        
        // Higher priority if region doesn't have air defense
        if !country.regions[regionIndex].hasAirDefense {
            priority += 0.3
        }
        
        // Higher priority if under threat (enemies have many rockets)
        let totalEnemyRockets = allCountries.enumerated().compactMap { (index, _) in
            if index == country.countryIndex { return nil }
            return 1 // Assume enemies might have rockets
        }.reduce(0, +)
        
        if totalEnemyRockets > 0 {
            priority += 0.4
        }
        
        return min(priority, 1.0)
    }
    
    private func calculateRocketPriority(allCountries: [Country]) -> Double {
        let aliveEnemies = allCountries.filter { !$0.isDestroyed }.count - 1
        return aliveEnemies > 0 ? 0.8 : 0.2
    }
    
    private func selectBestRegionForRocket(country: Country) -> Int {
        // Select first alive region for rocket purchase
        for (index, region) in country.regions.enumerated() {
            if !region.isDestroyed {
                return index
            }
        }
        return 0
    }
    
    private func calculateTargetPriority(
        targetCountryIndex: Int,
        targetRegionIndex: Int,
        targetCountry: Country,
        allCountries: [Country],
        attackerCountryIndex: Int
    ) -> Double {
        var priority: Double = 0.5
        
        let targetRegion = targetCountry.regions[targetRegionIndex]
        
        // Prefer targets without air defense
        if !targetRegion.hasAirDefense {
            priority += 0.4
        }
        
        // Prefer countries with fewer regions (closer to elimination)
        let regionCount = targetCountry.aliveRegionsCount
        if regionCount <= 2 {
            priority += 0.4
        } else if regionCount <= 3 {
            priority += 0.2
        }
        
        // Prefer human player if they're strong
        if let humanCountryIndex = allCountries.enumerated().first(where: { $0.element.aliveRegionsCount > 3 })?.offset {
            if targetCountryIndex == humanCountryIndex {
                priority += 0.3
            }
        }
        
        // Random factor for unpredictability
        priority += Double.random(in: 0...0.2)
        
        return min(priority, 1.0)
    }
}

// MARK: - AI System Factory
extension AISystem {
    static func createForPlayer(at countryIndex: Int) -> AISystem {
        // Vary AI strategies slightly
        let strategies: [AIStrategy] = [.aggressive, .balanced, .aggressive, .aggressive]
        let strategy = strategies[min(countryIndex, strategies.count - 1)]
        return AISystem(strategy: strategy)
    }
}
