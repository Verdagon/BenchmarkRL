import Foundation

// The 100 means it's multiplied by 100 (for more precision)
let DEFAULT_SIGHT_RANGE_100: Int32 = 800

// Ints describing how much a unit wants to do something.
enum DesireStrength {
    static let NEED: Int32 = 800
    static let ALMOST_NEED: Int32 = 700
    static let REALLY_WANT: Int32 = 600
    static let WANT: Int32 = 500
    static let MEH: Int32 = 100
}

// A struct that partakes in the equation to calculate a unit's damage.
struct AttackModifier {
    // This is how much we contribute to the initial attack amount.
    // Weapons will usually contribute to this; a claw might be 1.2,
    // a shortsword would be 1.3, broadsword would be 1.4.
    // 100 means over 100, so we can have attack values like 1.25,
    // which would be represented here as 125.
    let initialDamage100: Int32

    // 100 means over 100. 150 would mean 1.5x damage, 70 would mean 70% damage.
    // Certain abilities might do this, like if we double damage for 10 turns it
    // would show up here.
    // Try to keep this low, we dont want things as high as 2x, prefer things
    // like 110 to represent +10%.
    let damageMultiply100: Int32

    // Extra final additions go here. For example we might have a ring
    // of +3 damage, that would show up here as 300.
    let damageAdd100: Int32

    static func `default`() -> AttackModifier {
        return AttackModifier(initialDamage100: 0, damageMultiply100: 100, damageAdd100: 0)
    }
}

// This is how units know who to attack.
// When we add pets, they'll also have the Good allegiance.
enum Allegiance: Equatable {
    case good
    case evil
}

// Protocol for unit components
protocol IUnitComponent: AnyObject {
    // Called on a component when its unit is attacking another unit.
    // Used for weapons, damage modifiers, etc.
    func modifyOutgoingAttack(game: Game, selfUnit: Int) -> AttackModifier

    // Called on a component whenever its unit dies.
    // Returns a lambda with which it can modify the game.
    func onUnitDeath(
        rand: LCGRand,
        game: Game,
        selfUnitIndex: Int,
        attacker: Int
    ) -> GameMutator

    // If this component is a capability, return a reference to itself.
    // Otherwise, nil.
    func asCapability() -> IUnitCapability?
}

// Default implementations
extension IUnitComponent {
    func modifyOutgoingAttack(game: Game, selfUnit: Int) -> AttackModifier {
        return AttackModifier.default()
    }

    func onUnitDeath(
        rand: LCGRand,
        game: Game,
        selfUnitIndex: Int,
        attacker: Int
    ) -> GameMutator {
        return doNothingGameMutator()
    }

    func asCapability() -> IUnitCapability? {
        return nil
    }
}

// A capability is a special kind of component that factors into the unit's AI.
protocol IUnitCapability: IUnitComponent {
    // Produces a desire describing what the unit wants to do and how much it wants
    // to do it.
    func getDesire(rand: LCGRand, selfUnit: Unit, game: Game) -> IUnitDesire

    // Called before any desire is enacted. Usually used to clean up a capability's
    // internal state.
    func preAct(desire: IUnitDesire)
}

// Default implementation
extension IUnitCapability {
    func preAct(desire: IUnitDesire) {}

    func asCapability() -> IUnitCapability? {
        return self
    }
}

// Describes what the unit wants to do and how much it wants to do it.
protocol IUnitDesire: AnyObject {
    func getStrength() -> Int32
    func enact(rand: LCGRand, selfUnitIndex: Int, game: Game)
}

// A basic desire to do nothing.
class DoNothingUnitDesire: IUnitDesire {
    func getStrength() -> Int32 {
        return 0
    }

    func enact(rand: LCGRand, selfUnitIndex: Int, game: Game) {}
}

// A basic desire to move to somewhere.
class MoveUnitDesire: IUnitDesire {
    // Describes how much the unit wants to move here.
    // Could be low (if it was just meandering) or high (if it was attacking or fleeing).
    let strength: Int32

    // Where the unit wants to step to.
    let destination: Location

    init(strength: Int32, destination: Location) {
        self.strength = strength
        self.destination = destination
    }

    func getStrength() -> Int32 {
        return strength
    }

    func enact(rand: LCGRand, selfUnitIndex: Int, game: Game) {
        guard var unit = game.units[selfUnitIndex] else { return }
        let levelIndex = game.getPlayer().levelIndex
        game.levels[levelIndex].moveUnit(unit: &unit, destination: destination)
        game.units[selfUnitIndex] = unit
    }
}

// Anything that has consciousness or takes action in the world (person, pet, golems, etc)
struct Unit {
    let index: Int
    var hp: Int32
    let maxHp: Int32
    var levelIndex: Int
    var loc: Location
    let allegiance: Allegiance
    let displayClass: String
    var components: [IUnitComponent]

    // Takes a turn. Will do some AI to figure out what it wants to do, then do it.
    static func act(selfIndex: Int, rand: LCGRand, game: Game) {
        guard let selfUnit = game.units[selfIndex] else { return }

        // First, loop over all the capabilities this unit has, and produce a desire for each,
        // keeping only the strongest one.
        var greatestDesire: IUnitDesire = DoNothingUnitDesire()
        for component in selfUnit.components {
            if let capability = component.asCapability() {
                let desire = capability.getDesire(rand: rand, selfUnit: selfUnit, game: game)
                if desire.getStrength() > greatestDesire.getStrength() {
                    greatestDesire = desire
                }
            }
        }

        // Now, inform all of the capabilities of what's about to happen
        guard let selfUnitMut = game.units[selfIndex] else { return }
        for component in selfUnitMut.components {
            if let capability = component.asCapability() {
                capability.preAct(desire: greatestDesire)
            }
        }

        // Now, let the desire implement itself onto the world and make things happen.
        greatestDesire.enact(rand: rand, selfUnitIndex: selfIndex, game: game)
    }

    func getNearestEnemyInSight(game: Game, range: Int32) -> Unit? {
        let locationsWithinSight = game.getCurrentLevel().getLocationsWithinSight(
            startLoc: self.loc,
            includeSelf: false,
            sightRange: range
        )

        var maybeNearestEnemy: Unit?
        for locationWithinSight in locationsWithinSight {
            let level = game.getCurrentLevel()
            guard let otherUnitIndex = level.unitByLocation[locationWithinSight] else {
                continue
            }
            guard let otherUnit = game.units[otherUnitIndex] else { continue }

            if self.allegiance != otherUnit.allegiance {
                let isNearestEnemy: Bool
                if let nearestEnemy = maybeNearestEnemy {
                    isNearestEnemy = self.loc.distSquared(nearestEnemy.loc)
                        < self.loc.distSquared(otherUnit.loc)
                } else {
                    isNearestEnemy = true
                }
                if isNearestEnemy {
                    maybeNearestEnemy = otherUnit
                }
            }
        }

        return maybeNearestEnemy
    }
}
