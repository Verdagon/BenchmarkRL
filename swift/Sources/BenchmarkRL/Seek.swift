import Foundation

class SeekUnitCapability: IUnitCapability {
    func getDesire(rand: LCGRand, selfUnit: Unit, game: Game) -> IUnitDesire {
        // Pick a random enemy and head towards them.
        var maybeNearestEnemy: Unit?
        for (thisLoc, unitIndex) in game.getCurrentLevel().unitByLocation {
            if unitIndex == selfUnit.index {
                continue
            }
            guard let unit = game.units[unitIndex] else { continue }
            if unit.allegiance == selfUnit.allegiance {
                continue
            }
            if let nearestEnemy = maybeNearestEnemy {
                let distFromSelfToNearestEnemy = selfUnit.loc.diagonalManhattanDistance100(nearestEnemy.loc)
                let distFromSelfToThisLoc = selfUnit.loc.diagonalManhattanDistance100(thisLoc)
                if distFromSelfToNearestEnemy < distFromSelfToThisLoc {
                    continue
                }
            }
            maybeNearestEnemy = unit
        }

        if let enemy = maybeNearestEnemy {
            if let (newPath, _) = game.getCurrentLevel().findPath(
                fromLoc: selfUnit.loc,
                toLoc: enemy.loc,
                maxDistance: Int32.max,
                considerCornersAdjacent: true
            ) {
                if game.getCurrentLevel().locIsWalkable(loc: newPath[0], considerUnits: true) {
                    return MoveUnitDesire(strength: DesireStrength.WANT, destination: newPath[0])
                }
                return DoNothingUnitDesire()
            } else {
                fatalError("No path!")
            }
        } else {
            // No enemies left, just relax!
            return DoNothingUnitDesire()
        }
    }
}
