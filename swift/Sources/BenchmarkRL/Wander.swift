import Foundation

// A capability for a unit to randomly wander in some direction.
class WanderUnitCapability: IUnitCapability {
    func getDesire(rand: LCGRand, selfUnit: Unit, game: Game) -> IUnitDesire {
        let level = game.getCurrentLevel()
        let adjacentLocations = level.getAdjacentLocations(center: selfUnit.loc, considerCornersAdjacent: true)
        let walkableAdjacentLocations = adjacentLocations.filter { loc in
            level.locIsWalkable(loc: loc, considerUnits: true)
        }
        if walkableAdjacentLocations.isEmpty {
            return DoNothingUnitDesire()
        } else {
            let index = Int(rand.next() % UInt32(walkableAdjacentLocations.count))
            return MoveUnitDesire(strength: DesireStrength.MEH, destination: walkableAdjacentLocations[index])
        }
    }
}
