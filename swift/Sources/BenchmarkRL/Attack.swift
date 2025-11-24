import Foundation

// A unit capability which wants to attack anything that the unit is next to.
class AttackUnitCapability: IUnitCapability {
    func getDesire(rand: LCGRand, selfUnit: Unit, game: Game) -> IUnitDesire {
        // If there's an enemy right next to us, attack them!
        if let enemyUnit = selfUnit.getNearestEnemyInSight(game: game, range: 150) {
            return AttackUnitDesire(strength: DesireStrength.NEED, targetUnitIndex: enemyUnit.index)
        }

        // No enemy next to us. If we have a ChaseUnitCapability, maybe it will tell us to
        // go chase one. As for us, we dont really want anything.
        return DoNothingUnitDesire()
    }
}

// A desire to attack a unit.
class AttackUnitDesire: IUnitDesire {
    let strength: Int32
    let targetUnitIndex: Int

    init(strength: Int32, targetUnitIndex: Int) {
        self.strength = strength
        self.targetUnitIndex = targetUnitIndex
    }

    func getStrength() -> Int32 {
        return strength
    }

    func enact(rand: LCGRand, selfUnitIndex: Int, game: Game) {
        guard let selfUnit = game.units[selfUnitIndex] else { return }

        var attackModifiers: [AttackModifier] = []
        for component in selfUnit.components {
            attackModifiers.append(component.modifyOutgoingAttack(game: game, selfUnit: targetUnitIndex))
        }

        // 100 means over 100, like we're doing fixed point numbers.
        // See AttackModifier for what this is all trying to do.
        var damage100: Int32 = 0
        for am in attackModifiers {
            damage100 += am.initialDamage100
        }
        for am in attackModifiers {
            damage100 = damage100 * am.damageMultiply100 / 100
        }
        for am in attackModifiers {
            damage100 += am.damageAdd100
        }
        let actualDamage = damage100 / 100

        game.damageUnit(rand: rand, unitIndex: targetUnitIndex, damage: actualDamage)
    }
}
