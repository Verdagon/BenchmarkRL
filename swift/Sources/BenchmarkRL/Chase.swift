import Foundation

struct CurrentTarget {
    let targetUnitIndex: Int
    let pathToTarget: [Location]
}

// A unit capability that wants to chase units it can see.
class ChaseUnitCapability: IUnitCapability {
    // We remember which unit we're chasing (and the path to them) even between
    // turns.
    // When the enemy goes out of sight (such as around a corner), we keep following
    // the path to them, in hopes that we'll see them when they get there.
    var currentTarget: CurrentTarget?

    init() {
        self.currentTarget = nil
    }

    func getDesire(rand: LCGRand, selfUnit: Unit, game: Game) -> IUnitDesire {
        // A helper function to make a ChaseUnitDesire from a path we found
        // towards an enemy.
        func makeDesireFromPath(
            game: Game,
            selfUnit: Unit,
            strength: Int32,
            targetUnitIndex: Int,
            newPath: [Location]
        ) -> IUnitDesire {
            assert(!newPath.isEmpty)
            assert(newPath[0] != selfUnit.loc)
            assert(newPath[newPath.count - 1] != selfUnit.loc)

            let nextStep = newPath[0]
            var futurePath = newPath
            futurePath.remove(at: 0)

            assert(game.getCurrentLevel().locIsWalkable(loc: nextStep, considerUnits: true))

            return ChaseUnitDesire(
                strength: DesireStrength.ALMOST_NEED, // Gotta protect your territory, man
                targetUnitIndex: targetUnitIndex,
                nextStepLoc: nextStep,
                futurePathToTarget: futurePath
            )
        }

        // If we're targeting a unit and have a path, make sure we're
        // next to the first step on the path.
        if let currentTarget = currentTarget {
            if !selfUnit.loc.nextTo(
                currentTarget.pathToTarget[0],
                considerCornersAdjacent: true,
                includeSelf: false
            ) {
                fatalError("Unit at \(selfUnit.loc) not next to next step in path at \(currentTarget.pathToTarget[0])")
            }
        }

        // If the enemy we were previously targeting is still alive and
        // still within sight range, chase them!
        // If not (such as them going around a corner), follow
        // the last known path to them, maybe we'll see them again.
        if let currentTarget = currentTarget {
            // Ignore target_unit if they're dead
            if let targetUnit = game.units[currentTarget.targetUnitIndex] {
                // target_unit is alive!

                if game.getCurrentLevel().canSee(
                    fromLoc: selfUnit.loc,
                    toLoc: targetUnit.loc,
                    sightRange: DEFAULT_SIGHT_RANGE_100
                ) {
                    // We can see the enemy right now, chase them!
                    // Recalculate a new path to the unit!

                    // Enemies are lazy, they'll only chase you if you're 2x their sight range away.
                    let maxTravelDistance = DEFAULT_SIGHT_RANGE_100 * 2

                    if let (newPath, _) = game.getCurrentLevel().findPath(
                        fromLoc: selfUnit.loc,
                        toLoc: targetUnit.loc,
                        maxDistance: maxTravelDistance,
                        considerCornersAdjacent: true
                    ) {
                        if game.getCurrentLevel().locIsWalkable(loc: newPath[0], considerUnits: true) {
                            return makeDesireFromPath(
                                game: game,
                                selfUnit: selfUnit,
                                strength: DesireStrength.ALMOST_NEED, // Gotta protect your territory, man
                                targetUnitIndex: currentTarget.targetUnitIndex,
                                newPath: newPath
                            )
                        } else {
                            // We can't follow the path to the last position the enemy was at.
                            // Continue on, maybe we'll find a new enemy.
                        }
                    } else {
                        // Cant find an acceptable path to the unit, even though we can see them.
                        // This could happen if it's too far, or the level was separated by a river,
                        // for example.
                        // Continue on, maybe we'll find a new enemy.
                    }
                } else {
                    // We can't see the enemy right now. Follow the stored path to them!

                    if game.getCurrentLevel().locIsWalkable(
                        loc: currentTarget.pathToTarget[0],
                        considerUnits: true
                    ) {
                        return makeDesireFromPath(
                            game: game,
                            selfUnit: selfUnit,
                            strength: DesireStrength.REALLY_WANT, // If they're out of sight, it's slightly less important
                            targetUnitIndex: currentTarget.targetUnitIndex,
                            newPath: currentTarget.pathToTarget
                        )
                    } else {
                        // We can't follow the path to the last position the enemy was at.
                        // Continue on, maybe we'll find a new enemy.
                    }
                }
            } else {
                // Target unit is dead. Continue on, maybe we'll find a new enemy.
            }
        }

        // There's no target, or we couldn't follow them, or something,
        // so lets look around and see if we can find one.
        if let nearestEnemyUnit = selfUnit.getNearestEnemyInSight(game: game, range: DEFAULT_SIGHT_RANGE_100) {
            // Calculate a path to the unit.

            // Enemies are lazy, they'll only chase you if you're 2x their sight range away.
            let maxTravelDistance = DEFAULT_SIGHT_RANGE_100 * 2

            if let (newPath, _) = game.getCurrentLevel().findPath(
                fromLoc: selfUnit.loc,
                toLoc: nearestEnemyUnit.loc,
                maxDistance: maxTravelDistance,
                considerCornersAdjacent: true
            ) {
                if game.getCurrentLevel().locIsWalkable(loc: newPath[0], considerUnits: true) {
                    return makeDesireFromPath(
                        game: game,
                        selfUnit: selfUnit,
                        strength: DesireStrength.ALMOST_NEED, // Gotta protect your territory, man
                        targetUnitIndex: nearestEnemyUnit.index,
                        newPath: newPath
                    )
                } else {
                    // We have a path, but we can't take the first step.
                }
            } else {
                // Cant find a path to the unit, even though we can see them. This could
                // happen if a level was separated by a river, for example.
            }
        }

        // No enemy in sight, and no path. Welp, guess it's time to just relax!
        return DoNothingUnitDesire()
    }

    // Called when an desire is about to be enacted by this unit.
    // If a non-chase desire is being enacted, this gives us the opportunity
    // to throw away our state which was tracking how we'd get to our target
    // enemy.
    func preAct(desire: IUnitDesire) {
        if desire is ChaseUnitDesire {
            // Do nothing, the desire will take care of it
        } else {
            // Some other capability's desire is about to be enacted!
            // Our chase is interrupted, throw away our state.
            currentTarget = nil
        }
    }
}

// The desire produced by the chase capability above on a given turn.
class ChaseUnitDesire: IUnitDesire {
    // How much we want to chase them this turn.
    let strength: Int32

    // The unit to chase.
    let targetUnitIndex: Int

    // First step towards them.
    let nextStepLoc: Location

    // Where we should go in the future if we lose sight of them.
    let futurePathToTarget: [Location]

    init(strength: Int32, targetUnitIndex: Int, nextStepLoc: Location, futurePathToTarget: [Location]) {
        self.strength = strength
        self.targetUnitIndex = targetUnitIndex
        self.nextStepLoc = nextStepLoc
        self.futurePathToTarget = futurePathToTarget
    }

    func getStrength() -> Int32 {
        return strength
    }

    func enact(rand: LCGRand, selfUnitIndex: Int, game: Game) {
        guard var selfUnit = game.units[selfUnitIndex] else { return }

        // Find the chase capability and update its state
        for (index, component) in selfUnit.components.enumerated() {
            if let chaseCapability = component as? ChaseUnitCapability {
                if !futurePathToTarget.isEmpty {
                    chaseCapability.currentTarget = CurrentTarget(
                        targetUnitIndex: targetUnitIndex,
                        pathToTarget: futurePathToTarget
                    )
                } else {
                    chaseCapability.currentTarget = nil
                }
                selfUnit.components[index] = chaseCapability
                break
            }
        }

        let levelIndex = selfUnit.levelIndex
        game.levels[levelIndex].moveUnit(unit: &selfUnit, destination: nextStepLoc)
        game.units[selfUnitIndex] = selfUnit
    }
}
