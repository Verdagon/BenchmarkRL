import Foundation

// Moves the player to the next level.
// Returns true to continue with the game, false to exit the game.
func descendToNextLevel(rand: LCGRand, game: Game) -> Bool {
    let playerIndex = game.getPlayerIndex()
    guard var player = game.units[playerIndex] else { return false }
    let oldPlayerLoc = player.loc

    // Remove the player from the old level's unit-by-location index.
    game.levels[player.levelIndex].unitByLocation.removeValue(forKey: oldPlayerLoc)

    // Figure out the new level index.
    let playerNewLevelIndex = player.levelIndex + 1
    // If we're descending past the last level, end the game.
    if playerNewLevelIndex >= game.levels.count {
        return false
    }

    // Move the player to the new level.
    player.levelIndex = playerNewLevelIndex
    // Update the player's location
    let newPlayerLoc = game.levels[playerNewLevelIndex].findRandomWalkableUnoccupiedLocation(rand: rand)
    player.loc = newPlayerLoc
    game.units[playerIndex] = player

    // Add the player to the new level's unit-by-location index.
    game.levels[playerNewLevelIndex].unitByLocation[newPlayerLoc] = playerIndex

    return true
}

func setup(rand: LCGRand, maxWidth: Int32, maxHeight: Int32, numLevels: Int32) -> Game {
    let game = Game(units: [:], levels: [], playerIndex: nil)

    for _ in 0..<Int(numLevels) {
        let levelIndex = game.levels.count
        game.levels.append(makeLevel(maxWidth: maxWidth, maxHeight: maxHeight, rand: rand))

        // Add one goblin for every 10 walkable spaces in the level.
        let numWalkableLocations = game.levels[levelIndex].getWalkableLocations().count
        for _ in 0..<(numWalkableLocations / 10) {
            let newUnitLoc = game.levels[levelIndex].findRandomWalkableUnoccupiedLocation(rand: rand)

            let newUnitIndex = game.addUnitToLevel(
                levelIndex: levelIndex,
                loc: newUnitLoc,
                hp: 10,
                maxHp: 10,
                allegiance: .evil,
                displayClass: "goblin"
            )
            if var newUnit = game.units[newUnitIndex] {
                newUnit.components.append(WanderUnitCapability())
                newUnit.components.append(AttackUnitCapability())
                newUnit.components.append(ChaseUnitCapability())
                newUnit.components.append(GoblinClaws())
                if rand.next() % 10 == 0 {
                    newUnit.components.append(ExplodeyUnitComponent())
                }
                game.units[newUnitIndex] = newUnit
            }
        }
    }

    let playerLoc = game.levels[0].findRandomWalkableUnoccupiedLocation(rand: rand)
    let playerIndex = game.addUnitToLevel(
        levelIndex: 0,
        loc: playerLoc,
        hp: 1000000,
        maxHp: 1000000,
        allegiance: .good,
        displayClass: "chronomancer"
    )
    game.playerIndex = playerIndex

    if var player = game.units[playerIndex] {
        player.components.append(WanderUnitCapability())
        player.components.append(AttackUnitCapability())
        player.components.append(ChaseUnitCapability())
        player.components.append(SeekUnitCapability())
        player.components.append(IncendiumShortSword())
        game.units[playerIndex] = player
    }

    return game
}

// Advance the game by 1 turn for all units.
func turn(rand: LCGRand, game: Game) {
    // First, let all the tiles act.
    let actingTileLocs = Array(game.getCurrentLevel().actingTileLocations.keys)
    for actingTileLoc in actingTileLocs {
        guard let tile = game.getCurrentLevel().tiles[actingTileLoc] else { continue }
        for (componentIndex, component) in tile.components.enumerated() {
            let gameMutator = component.onTurn(
                rand: rand,
                game: game,
                selfTileLoc: actingTileLoc,
                selfTileComponentIndex: componentIndex
            )
            gameMutator(rand, game)
        }
    }

    // Get a list of units to iterate over
    let units = Array(game.getCurrentLevel().unitByLocation.values)
    // Now iterate over them, only considering ones that are still alive.
    for unitIndex in units {
        if game.units[unitIndex] != nil {
            Unit.act(selfIndex: unitIndex, rand: rand, game: game)
        }
    }
}

func benchmarkRL(
    seed: Int32,
    levelWidth: Int32,
    levelHeight: Int32,
    numLevels: Int32,
    shouldDisplay: Bool,
    turnDelay: Int32,
    onlyLevel: Bool
) {
    let rand = LCGRand(seed: UInt32(seed))
    let game = setup(rand: rand, maxWidth: levelWidth, maxHeight: levelHeight, numLevels: numLevels)

    if onlyLevel {
        print("Level generated with seed \(seed):")
        print("")
        fflush(stdout)

        // Display the level as ASCII
        for y in 0..<Int(levelHeight) {
            var line = ""
            for x in 0..<Int(levelWidth) {
                let loc = Location(x: Int32(x), y: Int32(y))

                var char = " "
                if let tile = game.getCurrentLevel().tiles[loc] {
                    switch tile.displayClass {
                    case "dirt", "grass":
                        char = "."
                    case "wall":
                        char = "#"
                    default:
                        char = "?"
                    }
                }

                if let unitIndex = game.getCurrentLevel().unitByLocation[loc] {
                    if let unit = game.units[unitIndex] {
                        switch unit.displayClass {
                        case "goblin":
                            char = "g"
                        case "chronomancer":
                            char = "@"
                        default:
                            char = "?"
                        }
                    }
                }

                line += char
            }
            print(line)
        }
        print("")
        print("Legend: # = wall, . = floor, g = goblin, @ = player")
        print("Press Ctrl+C to exit.")
        fflush(stdout)
        Thread.sleep(forTimeInterval: 3600) // Wait an hour so user can see it
        return
    }

    print("Starting benchmark with seed \(seed), \(levelWidth)x\(levelHeight), \(numLevels) levels")

    var turnCount = 0
    while true {
        turn(rand: rand, game: game)
        turnCount += 1

        guard let player = game.units[game.getPlayerIndex()] else {
            print("Player died after \(turnCount) turns")
            break
        }

        let playerLevelIndex = player.levelIndex
        let numUnits = game.levels[playerLevelIndex].unitByLocation.count
        if numUnits == 1 {
            let keepRunning = descendToNextLevel(rand: rand, game: game)
            if !keepRunning {
                print("Completed all \(numLevels) levels in \(turnCount) turns!")
                return
            }
        }

        if turnDelay > 0 {
            Thread.sleep(forTimeInterval: Double(turnDelay) / 1000.0)
        }
    }
}
