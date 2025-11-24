import Foundation

let BLAST_RANGE: Int32 = 400

// A unit component that makes a unit explode on death and leave
// a bunch of flames on the ground.
class ExplodeyUnitComponent: IUnitComponent {
    func onUnitDeath(
        rand: LCGRand,
        game: Game,
        selfUnitIndex: Int,
        attacker: Int
    ) -> GameMutator {
        // We can't modify the &Game from here, so we return a lambda that takes
        // a &mut Game to do the modification for us, kind of like a state monad.
        return { rand, innerGame in
            // Look for all the enemies around us.
            let level = innerGame.getCurrentLevel()
            guard let selfUnit = innerGame.units[selfUnitIndex] else { return }
            // The visible area is a good approximation of where a blast
            // would go.
            let blastedLocs = level.getLocationsWithinSight(
                startLoc: selfUnit.loc,
                includeSelf: false,
                sightRange: BLAST_RANGE
            )
            var walkableBlastedLocs: [Location] = []
            for blastedLoc in blastedLocs {
                if level.locIsWalkable(loc: blastedLoc, considerUnits: false) {
                    walkableBlastedLocs.append(blastedLoc)
                }
            }
            let centerLoc = selfUnit.loc

            for blastedLoc in walkableBlastedLocs {
                // Lets make it burn longer if it was close.
                let distanceFromCenter100 = centerLoc.diagonalManhattanDistance100(blastedLoc)
                // 0 means on the edge, 100 means at center.
                let closenessToCenter100 = 100 - distanceFromCenter100 * 100 / BLAST_RANGE
                let numTurnsToBurn = UInt32(closenessToCenter100) / 10 + rand.next() % 10

                let levelIndex = innerGame.getPlayer().levelIndex
                if let tile = innerGame.levels[levelIndex].tiles[blastedLoc] {
                    let fireComponent = FireTileComponent(numTurnsRemaining: numTurnsToBurn)
                    fireComponent.componentIndex = tile.components.count
                    tile.components.append(fireComponent)
                    innerGame.levels[levelIndex].tiles[blastedLoc] = tile
                    innerGame.levels[levelIndex].registerActingTile(loc: blastedLoc)
                }
            }
        }
    }
}
