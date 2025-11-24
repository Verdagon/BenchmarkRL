import Foundation

// From https://stackoverflow.com/a/3062783
class LCGRand {
    var seed: UInt32
    var callCount: UInt32

    init(seed: UInt32) {
        self.seed = seed
        self.callCount = 0
    }

    func next() -> UInt32 {
        let a: UInt32 = 1103515245
        let c: UInt32 = 12345
        let m: UInt32 = 0x7FFFFFFF
        let result = (a &* seed &+ c) % m
        seed = result
        callCount += 1
        return result
    }
}

// Type alias for game mutator closures
typealias GameMutator = (LCGRand, Game) -> Void

// Makes a GameMutator that does nothing
func doNothingGameMutator() -> GameMutator {
    return { _, _ in }
}

// Get all the locations adjacent to `center`.
func getPatternAdjacentLocations(
    center: Location,
    considerCornersAdjacent: Bool
) -> [Location] {
    var result: [Location] = []
    result.append(Location(x: center.x - 1, y: center.y))
    result.append(Location(x: center.x, y: center.y + 1))
    result.append(Location(x: center.x, y: center.y - 1))
    result.append(Location(x: center.x + 1, y: center.y))
    if considerCornersAdjacent {
        result.append(Location(x: center.x - 1, y: center.y - 1))
        result.append(Location(x: center.x - 1, y: center.y + 1))
        result.append(Location(x: center.x + 1, y: center.y - 1))
        result.append(Location(x: center.x + 1, y: center.y + 1))
    }
    return result
}

// Get all the locations adjacent to any of the ones in `sourceLocs`.
func getPatternLocationsAdjacentToAny(
    sourceLocs: Set<Location>,
    includeSourceLocs: Bool,
    considerCornersAdjacent: Bool
) -> Set<Location> {
    var result = Set<Location>()
    // Sort to ensure deterministic iteration
    let sortedSourceLocs = sourceLocs.sorted { a, b in
        if a.x == b.x { return a.y < b.y }
        return a.x < b.x
    }
    for originalLocation in sortedSourceLocs {
        var adjacents = getPatternAdjacentLocations(
            center: originalLocation,
            considerCornersAdjacent: considerCornersAdjacent
        )
        if includeSourceLocs {
            adjacents.append(originalLocation)
        }
        for adjacentLocation in adjacents {
            if !includeSourceLocs && sourceLocs.contains(adjacentLocation) {
                continue
            }
            result.insert(adjacentLocation)
        }
    }
    return result
}

class Game {
    var units: [Int: Unit]
    var levels: [Level]
    var playerIndex: Int?
    private var nextUnitId: Int = 0

    init(units: [Int: Unit] = [:], levels: [Level] = [], playerIndex: Int? = nil) {
        self.units = units
        self.levels = levels
        self.playerIndex = playerIndex
    }

    func getCurrentLevel() -> Level {
        return levels[getPlayer().levelIndex]
    }

    func setCurrentLevel(_ level: Level) {
        levels[getPlayer().levelIndex] = level
    }

    func getPlayerIndex() -> Int {
        guard let index = playerIndex else {
            fatalError("No player yet!")
        }
        return index
    }

    func getPlayer() -> Unit {
        return units[getPlayerIndex()]!
    }

    func addUnitToLevel(
        levelIndex: Int,
        loc: Location,
        hp: Int32,
        maxHp: Int32,
        allegiance: Allegiance,
        displayClass: String
    ) -> Int {
        let unitId = nextUnitId
        nextUnitId += 1

        let unit = Unit(
            index: unitId,
            hp: hp,
            maxHp: maxHp,
            levelIndex: levelIndex,
            loc: loc,
            allegiance: allegiance,
            displayClass: displayClass,
            components: []
        )
        units[unitId] = unit
        levels[levelIndex].unitByLocation[loc] = unitId
        return unitId
    }

    func damageUnit(rand: LCGRand, unitIndex: Int, damage: Int32) {
        guard var unit = units[unitIndex] else { return }
        let wasAlive = unit.hp > 0
        unit.hp -= damage
        units[unitIndex] = unit
        let isAlive = unit.hp > 0
        let died = wasAlive && !isAlive

        if died {
            killUnit(rand: rand, unitIndex: unitIndex)
        }
    }

    func killUnit(rand: LCGRand, unitIndex: Int) {
        guard let unit = units[unitIndex] else { return }

        for component in unit.components {
            let mutator = component.onUnitDeath(
                rand: rand,
                game: self,
                selfUnitIndex: unitIndex,
                attacker: unitIndex
            )
            mutator(rand, self)
        }
        removeUnit(unitIndex: unitIndex)
    }

    func removeUnit(unitIndex: Int) {
        guard let unit = units[unitIndex] else { return }
        let loc = unit.loc
        let levelIndex = unit.levelIndex
        levels[levelIndex].forgetUnit(unitIndex: unitIndex, loc: loc)
        units.removeValue(forKey: unitIndex)
    }
}
