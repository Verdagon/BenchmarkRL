import Foundation

protocol ITileComponent: AnyObject {
    // Called on a component every turn. It must be registered with the level
    // as an acting tile for it to actually be called though.
    // Returns a GameMutator lambda with which it can modify the game.
    func onTurn(
        rand: LCGRand,
        game: Game,
        selfTileLoc: Location,
        selfTileComponentIndex: Int
    ) -> GameMutator
}

// Default implementation
extension ITileComponent {
    func onTurn(
        rand: LCGRand,
        game: Game,
        selfTileLoc: Location,
        selfTileComponentIndex: Int
    ) -> GameMutator {
        return doNothingGameMutator()
    }
}

class Tile {
    let walkable: Bool

    // A string that the UI can recognize so it knows what to display. This should
    // ONLY be read by the UI, and not by any special logic. Any special logic
    // should be specified in components on the tile (which we don't have yet).
    let displayClass: String

    var components: [ITileComponent]

    init(walkable: Bool, displayClass: String, components: [ITileComponent] = []) {
        self.walkable = walkable
        self.displayClass = displayClass
        self.components = components
    }

    // Gets the component of the given type.
    func getFirstComponent<T: ITileComponent>(ofType type: T.Type) -> T? {
        for component in components {
            if let typed = component as? T {
                return typed
            }
        }
        return nil
    }
}
