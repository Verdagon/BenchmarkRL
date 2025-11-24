import Foundation

func makeLevel(maxWidth: Int32, maxHeight: Int32, rand: LCGRand) -> Level {
    var level = Level(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        tiles: [:],
        actingTileLocations: [:],
        unitByLocation: [:]
    )

    // This is a 2D array of booleans which represent our walkable and
    // non-walkable locations.
    var walkabilities: [[Bool]] = []
    for x in 0..<Int(maxWidth) {
        var column: [Bool] = []
        for y in 0..<Int(maxHeight) {
            let halfMaxWidth = maxWidth / 2
            let halfMaxHeight = maxHeight / 2
            let xDist = Int32(x) - halfMaxWidth
            let yDist = Int32(y) - halfMaxHeight
            let insideEllipse = xDist * xDist * (halfMaxHeight * halfMaxHeight) +
                yDist * yDist * (halfMaxWidth * halfMaxWidth) <
                (halfMaxWidth * halfMaxWidth) * (halfMaxHeight * halfMaxHeight)

            let walkable = rand.next() % 2 == 0
            column.append(insideEllipse && walkable)
        }
        walkabilities.append(column)
    }

    // Do cellular automata to smooth out the noisiness
    smoothLevel(maxWidth: maxWidth, maxHeight: maxHeight, walkabilities: &walkabilities)
    smoothLevel(maxWidth: maxWidth, maxHeight: maxHeight, walkabilities: &walkabilities)

    // Connect all rooms
    connectAllRooms(rand: rand, walkabilities: &walkabilities, considerCornersAdjacent: false)

    // Now, assemble the walkabilities array into tiles
    for x in 0..<Int(maxWidth) {
        for y in 0..<Int(maxHeight) {
            let loc = Location(x: Int32(x), y: Int32(y))
            let walkable = walkabilities[x][y]
            let onEdge = x == 0 || y == 0 || x == Int(maxWidth) - 1 || y == Int(maxHeight) - 1

            if walkable && !onEdge {
                let displayClass = rand.next() % 2 == 0 ? "dirt" : "grass"
                level.tiles[loc] = Tile(walkable: true, displayClass: displayClass, components: [])
            } else {
                var nextToWalkable = false
                let minX = max(0, x - 1)
                let maxX = min(Int(maxWidth) - 1, x + 1)
                let minY = max(0, y - 1)
                let maxY = min(Int(maxHeight) - 1, y + 1)

                for neighborX in minX...maxX {
                    for neighborY in minY...maxY {
                        if walkabilities[neighborX][neighborY] {
                            nextToWalkable = true
                            break
                        }
                    }
                    if nextToWalkable { break }
                }

                if nextToWalkable {
                    level.tiles[loc] = Tile(walkable: false, displayClass: "wall", components: [])
                }
            }
        }
    }

    return level
}

func smoothLevel(maxWidth: Int32, maxHeight: Int32, walkabilities: inout [[Bool]]) {
    var newWalkabilities: [[Bool]] = []

    for x in 0..<Int(maxWidth) {
        var column: [Bool] = []
        for y in 0..<Int(maxHeight) {
            var numWalkableNeighbors = 0

            let minX = max(0, x - 1)
            let maxX = min(Int(maxWidth) - 1, x + 1)
            let minY = max(0, y - 1)
            let maxY = min(Int(maxHeight) - 1, y + 1)

            for neighborX in minX...maxX {
                for neighborY in minY...maxY {
                    if walkabilities[neighborX][neighborY] {
                        numWalkableNeighbors += 1
                    }
                }
            }

            column.append(numWalkableNeighbors >= 5)
        }
        newWalkabilities.append(column)
    }

    walkabilities = newWalkabilities
}

func connectAllRooms(rand: LCGRand, walkabilities: inout [[Bool]], considerCornersAdjacent: Bool) {
    var rooms = identifyRooms(walkabilities: &walkabilities, considerCornersAdjacent: considerCornersAdjacent)
    connectRooms(rand: rand, rooms: &rooms)
    for room in rooms {
        // Sort to ensure deterministic iteration
        let sortedLocs = room.sorted { a, b in
            if a.x == b.x { return a.y < b.y }
            return a.x < b.x
        }
        for loc in sortedLocs {
            walkabilities[Int(loc.x)][Int(loc.y)] = true
        }
    }
}

func identifyRooms(walkabilities: inout [[Bool]], considerCornersAdjacent: Bool) -> [Set<Location>] {
    var roomIndexByLocation: [Location: Int] = [:]
    var rooms: [Set<Location>] = []

    for x in 0..<walkabilities.count {
        for y in 0..<walkabilities[x].count {
            if walkabilities[x][y] {
                let sparkLocation = Location(x: Int32(x), y: Int32(y))
                if roomIndexByLocation[sparkLocation] != nil {
                    continue
                }
                let connectedLocations = findAllConnectedLocations(
                    walkabilities: walkabilities,
                    considerCornersAdjacent: considerCornersAdjacent,
                    startLocation: sparkLocation
                )
                let newRoomIndex = rooms.count
                rooms.append(connectedLocations)
                for connectedLocation in connectedLocations {
                    roomIndexByLocation[connectedLocation] = newRoomIndex
                }
            }
        }
    }
    return rooms
}

func findAllConnectedLocations(
    walkabilities: [[Bool]],
    considerCornersAdjacent: Bool,
    startLocation: Location
) -> Set<Location> {
    var connectedWithUnexploredNeighbors = Set<Location>()
    var connectedWithExploredNeighbors = Set<Location>()

    connectedWithUnexploredNeighbors.insert(startLocation)

    while !connectedWithUnexploredNeighbors.isEmpty {
        // Sort to ensure deterministic selection
        let neighborsSorted = connectedWithUnexploredNeighbors.sorted { a, b in
            if a.x == b.x { return a.y < b.y }
            return a.x < b.x
        }
        let current = neighborsSorted[0]
        connectedWithUnexploredNeighbors.remove(current)
        connectedWithExploredNeighbors.insert(current)

        for neighbor in getAdjacentWalkableLocationsForGen(
            walkabilities: walkabilities,
            center: current,
            considerCornersAdjacent: considerCornersAdjacent
        ) {
            if connectedWithExploredNeighbors.contains(neighbor) {
                continue
            }
            if connectedWithUnexploredNeighbors.contains(neighbor) {
                continue
            }
            connectedWithUnexploredNeighbors.insert(neighbor)
        }
    }

    return connectedWithExploredNeighbors
}

func connectRooms(rand: LCGRand, rooms: inout [Set<Location>]) {
    var roomIndexByLocation: [Location: Int] = [:]

    for roomIndex in 0..<rooms.count {
        // Sort to ensure deterministic iteration
        let sortedRoomLocs = rooms[roomIndex].sorted { a, b in
            if a.x == b.x { return a.y < b.y }
            return a.x < b.x
        }
        for roomFloorLoc in sortedRoomLocs {
            roomIndexByLocation[roomFloorLoc] = roomIndex
        }
    }

    var regionByRoomIndex: [Int: Int] = [:]
    var roomIndicesByRegionNum: [Int: Set<Int>] = [:]

    for roomIndex in 0..<rooms.count {
        let region = roomIndex
        regionByRoomIndex[roomIndex] = region
        var roomIndicesInRegion = Set<Int>()
        roomIndicesInRegion.insert(roomIndex)
        roomIndicesByRegionNum[region] = roomIndicesInRegion
    }

    while true {
        let distinctRegions = Set(regionByRoomIndex.values)
        if distinctRegions.count < 2 {
            break
        }

        // Sort to ensure deterministic order
        let sortedRegions = distinctRegions.sorted()
        let regionA = sortedRegions[0]
        let regionB = sortedRegions[1]

        // Sort room indices to ensure deterministic selection
        let regionAIndices = roomIndicesByRegionNum[regionA]!.sorted()
        let regionARoomIndex = regionAIndices[Int(rand.next() % UInt32(regionAIndices.count))]
        let regionARoom = rooms[regionARoomIndex]
        let regionALocations = Array(regionARoom).sorted { a, b in
            if a.x == b.x { return a.y < b.y }
            return a.x < b.x
        }
        let regionALocation = regionALocations[Int(rand.next() % UInt32(regionALocations.count))]

        let regionBIndices = roomIndicesByRegionNum[regionB]!.sorted()
        let regionBRoomIndex = regionBIndices[Int(rand.next() % UInt32(regionBIndices.count))]
        let regionBRoom = rooms[regionBRoomIndex]
        let regionBLocations = Array(regionBRoom).sorted { a, b in
            if a.x == b.x { return a.y < b.y }
            return a.x < b.x
        }
        let regionBLocation = regionBLocations[Int(rand.next() % UInt32(regionBLocations.count))]

        var path: [Location] = []
        var currentLocation = regionALocation
        while currentLocation != regionBLocation {
            if currentLocation.x != regionBLocation.x {
                currentLocation = Location(
                    x: currentLocation.x + (regionBLocation.x - currentLocation.x).signum(),
                    y: currentLocation.y
                )
            } else if currentLocation.y != regionBLocation.y {
                currentLocation = Location(
                    x: currentLocation.x,
                    y: currentLocation.y + (regionBLocation.y - currentLocation.y).signum()
                )
            }
            if roomIndexByLocation[currentLocation] == nil {
                path.append(currentLocation)
            } else {
                let currentRoomIndex = roomIndexByLocation[currentLocation]!
                let currentRegion = regionByRoomIndex[currentRoomIndex]!
                if currentRegion == regionA {
                    path = []
                } else if currentRegion != regionA {
                    break
                }
            }
        }

        let combinedRegion = regionByRoomIndex.values.max()! + 1
        let newRoomIndex = rooms.count
        rooms.append(Set(path))
        for pathLocation in path {
            roomIndexByLocation[pathLocation] = newRoomIndex
        }
        regionByRoomIndex[newRoomIndex] = combinedRegion

        let pathAdjacentLocations = getPatternLocationsAdjacentToAny(
            sourceLocs: Set(path),
            includeSourceLocs: true,
            considerCornersAdjacent: false
        )
        var pathAdjacentRegions = Set<Int>()
        for pathAdjacentLocation in pathAdjacentLocations {
            if let roomIndex = roomIndexByLocation[pathAdjacentLocation] {
                if let region = regionByRoomIndex[roomIndex] {
                    pathAdjacentRegions.insert(region)
                }
            }
        }

        var roomIndicesInCombinedRegion = Set<Int>()
        roomIndicesInCombinedRegion.insert(newRoomIndex)
        // Sort to ensure deterministic iteration
        let sortedPathAdjacentRegions = pathAdjacentRegions.sorted()
        for pathAdjacentRegion in sortedPathAdjacentRegions {
            if pathAdjacentRegion == combinedRegion {
                continue
            }
            if let roomIndices = roomIndicesByRegionNum[pathAdjacentRegion] {
                for pathAdjacentRoomIndex in roomIndices {
                    regionByRoomIndex[pathAdjacentRoomIndex] = combinedRegion
                    roomIndicesInCombinedRegion.insert(pathAdjacentRoomIndex)
                }
                roomIndicesByRegionNum.removeValue(forKey: pathAdjacentRegion)
            }
        }
        roomIndicesByRegionNum[combinedRegion] = roomIndicesInCombinedRegion
    }
}

func getAdjacentWalkableLocationsForGen(
    walkabilities: [[Bool]],
    center: Location,
    considerCornersAdjacent: Bool
) -> [Location] {
    var result: [Location] = []
    let width = Int32(walkabilities.count)
    let height = Int32(walkabilities[0].count)

    for adjacent in getPatternAdjacentLocations(center: center, considerCornersAdjacent: considerCornersAdjacent) {
        if adjacent.x >= 0 && adjacent.y >= 0 && adjacent.x < width && adjacent.y < height {
            if walkabilities[Int(adjacent.x)][Int(adjacent.y)] {
                result.append(adjacent)
            }
        }
    }
    return result
}
