import Foundation

struct Level {
    let maxWidth: Int32
    let maxHeight: Int32
    var tiles: [Location: Tile]

    // Tiles that want to act every turn.
    // The value is the number of registrations for that, because it might have
    // been registered for multiple reasons, and we want to keep it registered
    // until that number of reasons goes down to zero.
    var actingTileLocations: [Location: UInt32]

    // An index of what units are at what locations, so a unit can easily
    // see whats around it.
    var unitByLocation: [Location: Int]

    init(
        maxWidth: Int32,
        maxHeight: Int32,
        tiles: [Location: Tile] = [:],
        actingTileLocations: [Location: UInt32] = [:],
        unitByLocation: [Location: Int] = [:]
    ) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.tiles = tiles
        self.actingTileLocations = actingTileLocations
        self.unitByLocation = unitByLocation
    }

    func findRandomWalkableUnoccupiedLocation(rand: LCGRand) -> Location {
        let walkableLocations = getWalkableLocations()
        let rngValue = rand.next()
        let locIndex = rngValue % UInt32(walkableLocations.count)
        let loc = walkableLocations[Int(locIndex)]
        return loc
    }

    func getAdjacentLocations(
        center: Location,
        considerCornersAdjacent: Bool
    ) -> [Location] {
        var result: [Location] = []
        for adjacent in getPatternAdjacentLocations(
            center: center,
            considerCornersAdjacent: considerCornersAdjacent
        ) {
            if adjacent.x >= 0 &&
                adjacent.y >= 0 &&
                adjacent.x < maxWidth &&
                adjacent.y < maxHeight {
                result.append(adjacent)
            }
        }
        return result
    }

    // If `considerUnits` is true, and a unit is on that location, this function
    // will return false, because it's considering units in determining walkability,
    // and that unit is in the way.
    // If `considerUnits` is false, it ignores any unit that's there.
    func locIsWalkable(loc: Location, considerUnits: Bool) -> Bool {
        guard let tile = tiles[loc] else { return false }
        if !tile.walkable {
            return false
        }
        if considerUnits {
            if unitByLocation.keys.contains(loc) {
                return false
            }
        }
        return true
    }

    func getAdjacentWalkableLocations(
        center: Location,
        considerUnits: Bool,
        considerCornersAdjacent: Bool
    ) -> [Location] {
        var result: [Location] = []
        let adjacents = getAdjacentLocations(
            center: center,
            considerCornersAdjacent: considerCornersAdjacent
        )
        for neighbor in adjacents {
            if locIsWalkable(loc: neighbor, considerUnits: considerUnits) {
                result.append(neighbor)
            }
        }
        return result
    }

    func findPath(
        fromLoc: Location,
        toLoc: Location,
        maxDistance: Int32,
        considerCornersAdjacent: Bool
    ) -> ([Location], Int32)? {
        return aStar(
            startLocation: fromLoc,
            targetLocation: toLoc,
            maxDistance: maxDistance,
            getDistance: { a, b in a.diagonalManhattanDistance100(b) },
            getAdjacentLocations: { loc in
                self.getAdjacentWalkableLocations(
                    center: loc,
                    considerUnits: false,
                    considerCornersAdjacent: considerCornersAdjacent
                )
            }
        )
    }

    func canSee(fromLoc: Location, toLoc: Location, sightRange: Int32) -> Bool {
        let straightDistance = fromLoc.diagonalManhattanDistance100(toLoc)
        let maximumDistance = min(straightDistance, sightRange)

        guard let (_, pathLength) = findPath(
            fromLoc: fromLoc,
            toLoc: toLoc,
            maxDistance: maximumDistance,
            considerCornersAdjacent: true
        ) else {
            return false
        }
        assert(pathLength <= maximumDistance)
        return true
    }

    // This gets all the locations within sight with a breadth-first search.
    // It follows the same logic as the above `canSee` function.
    func getLocationsWithinSight(
        startLoc: Location,
        includeSelf: Bool,
        sightRange: Int32
    ) -> Set<Location> {
        // This is the result set, which we'll eventually return.
        var visibleLocs = Set<Location>()
        // This is the set of locations we have yet to explore. This is our "to do" list.
        // The keys are the locations we want to consider next, and the value is
        // how far we walked to get to there so far.
        var walkedDistanceByLocToConsider: [Location: Int32] = [:]

        // Adds the start location to our "to do" list.
        walkedDistanceByLocToConsider[startLoc] = 0

        while !walkedDistanceByLocToConsider.isEmpty {
            // Pick an arbitrary location from the to do list to look at.
            let (thisLoc, walkedDistanceFromStartToThis) = walkedDistanceByLocToConsider.first!
            walkedDistanceByLocToConsider.removeValue(forKey: thisLoc)
            visibleLocs.insert(thisLoc)

            // It's not walkable, so it's a wall, so dont check its adjacents.
            if !locIsWalkable(loc: thisLoc, considerUnits: false) {
                continue
            }

            for adjacentLoc in getAdjacentLocations(center: thisLoc, considerCornersAdjacent: true) {
                // This is the ideal distance, if we were to go straight to the location.
                let directDistanceFromStartToAdjacent =
                    startLoc.diagonalManhattanDistance100(adjacentLoc)
                if directDistanceFromStartToAdjacent > sightRange {
                    // This is outside sight range even if there was a clear line of sight,
                    // skip it.
                    continue
                }

                let distanceFromThisToAdjacent =
                    thisLoc.diagonalManhattanDistance100(adjacentLoc)
                let walkedDistanceFromStartToAdjacent =
                    walkedDistanceFromStartToThis + distanceFromThisToAdjacent

                // If these arent equal, then we went out of our way somehow, which means
                // we didnt go very straight, so skip it.
                if walkedDistanceFromStartToAdjacent != directDistanceFromStartToAdjacent {
                    continue
                }

                // If we've already visible_locs it, or we already plan to explore it,
                // then don't add it.
                if visibleLocs.contains(adjacentLoc) ||
                    walkedDistanceByLocToConsider.keys.contains(adjacentLoc) {
                    continue
                }

                // We dont check walkability here because we want to see the walls...
                // we just don't want to see past them, so we dont consider their
                // adjacents. That check is above.

                walkedDistanceByLocToConsider[adjacentLoc] = walkedDistanceFromStartToAdjacent
            }
        }

        if !includeSelf {
            visibleLocs.remove(startLoc)
        }

        return visibleLocs
    }

    mutating func forgetUnit(unitIndex: Int, loc: Location) {
        assert(unitByLocation.keys.contains(loc))
        assert(unitByLocation[loc] == unitIndex)
        unitByLocation.removeValue(forKey: loc)
    }

    func getWalkableLocations() -> [Location] {
        var result: [Location] = []
        for (loc, tile) in tiles {
            if tile.walkable {
                result.append(loc)
            }
        }
        // Sort to ensure deterministic order across implementations
        result.sort { a, b in
            if a.x == b.x {
                return a.y < b.y
            }
            return a.x < b.x
        }
        return result
    }

    mutating func moveUnit(unit: inout Unit, destination: Location) {
        assert(!unitByLocation.keys.contains(destination))
        unitByLocation.removeValue(forKey: unit.loc)
        unit.loc = destination
        unitByLocation[unit.loc] = unit.index
    }

    // Increment the registration count for the given tile.
    mutating func registerActingTile(loc: Location) {
        let previousNumRegistrations = actingTileLocations[loc] ?? 0
        let newNumRegistrations = previousNumRegistrations + 1
        actingTileLocations[loc] = newNumRegistrations
    }

    // Decrement the registration count for the given tile, and if it hits zero,
    // dont consider it an acting tile anymore.
    mutating func unregisterActingTile(loc: Location) {
        guard let previousNumRegistrations = actingTileLocations[loc] else {
            fatalError("Expected registration!")
        }
        let newNumRegistrations = previousNumRegistrations - 1
        if newNumRegistrations == 0 {
            actingTileLocations.removeValue(forKey: loc)
        } else {
            actingTileLocations[loc] = newNumRegistrations
        }
    }
}
