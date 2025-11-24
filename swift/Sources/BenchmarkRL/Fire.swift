import Foundation

// A tile component that damages any unit that's standing on it.
class FireTileComponent: ITileComponent {
    var numTurnsRemaining: UInt32
    var componentIndex: Int?

    init(numTurnsRemaining: UInt32) {
        self.numTurnsRemaining = numTurnsRemaining
    }

    func onTurn(
        rand: LCGRand,
        game: Game,
        selfTileLoc: Location,
        selfTileComponentIndex: Int
    ) -> GameMutator {
        // We can't modify the &Game from here, so we return a lambda that takes
        // a &mut Game to do the modification for us, kind of like a state monad.
        return { rand, innerGame in
            let maybeUnitIndex = innerGame.getCurrentLevel().unitByLocation[selfTileLoc]

            // Get a mutable reference to our containing component
            guard let tile = innerGame.getCurrentLevel().tiles[selfTileLoc] else { return }
            guard let componentIndex = self.componentIndex else { return }
            guard let component = tile.components[componentIndex] as? FireTileComponent else { return }

            if component.numTurnsRemaining == 0 {
                // Remove the fire tile component, and unregister the tile as an acting tile.
                tile.components.remove(at: componentIndex)
                innerGame.levels[innerGame.getPlayer().levelIndex].tiles[selfTileLoc] = tile
                // register/unregister use an int under the hood, so this won't unregister
                // if there are other FireTileComponents on this space.
                innerGame.levels[innerGame.getPlayer().levelIndex].unregisterActingTile(loc: selfTileLoc)
            } else {
                // Now we decrement the num_turns_remaining, and damage any unit standing on us.
                component.numTurnsRemaining -= 1

                if let unitIndex = maybeUnitIndex {
                    innerGame.damageUnit(rand: rand, unitIndex: unitIndex, damage: 3)
                }
            }
        }
    }
}
