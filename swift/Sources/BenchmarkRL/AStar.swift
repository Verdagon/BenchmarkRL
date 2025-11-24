import Foundation

// Stands for Location, G, F, and Came from, it's the basic unit of data
// used in A* pathfinding. We shuffle these around in interesting ways
// and sort them by their f_score to figure out what the best path is.
struct LGFC: Comparable {
    // The location.
    let location: Location

    // The distance we've already walked to get to this location, when
    // coming from `came_from`.
    let gScore: Int32

    // The distance we've already walked to get to this location, when
    // coming from `came_from`, PLUS the estimated distance to the goal.
    let fScore: Int32

    // The adjacent location that we came from, that gave us such a nice
    // f_score.
    let cameFrom: Location

    static func < (lhs: LGFC, rhs: LGFC) -> Bool {
        // Reverse comparison for min-heap behavior
        return lhs.fScore > rhs.fScore
    }

    static func == (lhs: LGFC, rhs: LGFC) -> Bool {
        return lhs.location == rhs.location &&
            lhs.gScore == rhs.gScore &&
            lhs.fScore == rhs.fScore &&
            lhs.cameFrom == rhs.cameFrom
    }
}

// Simple priority queue implementation
struct PriorityQueue<T: Comparable> {
    private var heap: [T] = []

    var count: Int {
        return heap.count
    }

    mutating func push(_ element: T) {
        heap.append(element)
        siftUp(heap.count - 1)
    }

    mutating func pop() -> T? {
        guard !heap.isEmpty else { return nil }
        if heap.count == 1 {
            return heap.removeLast()
        }
        let result = heap[0]
        heap[0] = heap.removeLast()
        siftDown(0)
        return result
    }

    private mutating func siftUp(_ index: Int) {
        var child = index
        var parent = (child - 1) / 2
        while child > 0 && heap[child] < heap[parent] {
            heap.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }

    private mutating func siftDown(_ index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = 2 * parent + 2
            var candidate = parent

            if left < heap.count && heap[left] < heap[candidate] {
                candidate = left
            }
            if right < heap.count && heap[right] < heap[candidate] {
                candidate = right
            }
            if candidate == parent {
                return
            }
            heap.swapAt(parent, candidate)
            parent = candidate
        }
    }
}

// Find a path from start_location to target_location.
// Won't consider any locations further than `max_distance`.
// Returns nil if we couldn't find a path, or a tuple containing
// the path and the total distance traveled on it.
func aStar(
    startLocation: Location,
    targetLocation: Location,
    maxDistance: Int32,
    getDistance: (Location, Location) -> Int32,
    getAdjacentLocations: (Location) -> [Location]
) -> ([Location], Int32)? {
    assert(startLocation != targetLocation)
    if getDistance(startLocation, targetLocation) > maxDistance {
        return nil
    }

    if getAdjacentLocations(startLocation).contains(targetLocation) {
        let distance = getDistance(startLocation, targetLocation)
        if distance <= maxDistance {
            return ([startLocation, targetLocation], distance)
        } else {
            return nil
        }
    }

    // The set of nodes already evaluated
    var closedLocations = Set<Location>()

    // For each node:
    // - came_from: which node it can most efficiently be reached from.
    //   If a node can be reached from many nodes, came_from will eventually contain the
    //   most efficient previous step.
    // - g: the cost of getting from the start node to that node.
    // - f: the total cost of getting from the start node to the goal
    //   by passing by that node. That value is partly known, partly heuristic.
    var lgfcByLocation: [Location: LGFC] = [:]

    // The set of currently discovered nodes that are not evaluated yet.
    // Initially, only the start node is known.
    var openLocationsLowestFFirst = PriorityQueue<LGFC>()
    var openLocations = Set<Location>()

    let startLgfc = LGFC(
        location: startLocation,
        gScore: 0,
        fScore: getDistance(startLocation, targetLocation),
        cameFrom: startLocation
    )
    lgfcByLocation[startLocation] = startLgfc
    openLocationsLowestFFirst.push(startLgfc)
    openLocations.insert(startLocation)

    while openLocationsLowestFFirst.count > 0 {
        guard let thisLgfc = openLocationsLowestFFirst.pop() else { break }
        let thisLocation = thisLgfc.location

        if thisLgfc != lgfcByLocation[thisLocation] {
            continue
        }

        if thisLocation == targetLocation {
            // In this block we're looping backwards from the target to the start,
            // so "previous" means closer to the target, and "next" means closer
            // to the start.
            var path: [Location] = []
            var distance: Int32 = 0
            var currentLocation = targetLocation
            while lgfcByLocation[currentLocation]!.cameFrom != currentLocation {
                path.append(currentLocation)
                let prevLocation = currentLocation
                currentLocation = lgfcByLocation[currentLocation]!.cameFrom
                distance += getDistance(currentLocation, prevLocation)
            }
            path.reverse()
            assert(path[0] != startLocation)
            assert(path[path.count - 1] == targetLocation)
            return (path, distance)
        }

        closedLocations.insert(thisLocation)

        let neighbors = getAdjacentLocations(thisLocation)
        for neighborLoc in neighbors {
            let tentativeGScore = lgfcByLocation[thisLocation]!.gScore
                + getDistance(thisLocation, neighborLoc)
            let tentativeFScore = tentativeGScore + getDistance(neighborLoc, targetLocation)

            if tentativeFScore > maxDistance {
                continue
            }
            if closedLocations.contains(neighborLoc) {
                continue
            }

            if openLocations.contains(neighborLoc) &&
                tentativeGScore >= lgfcByLocation[neighborLoc]!.gScore {
                continue
            }

            lgfcByLocation[neighborLoc] = LGFC(
                location: neighborLoc,
                gScore: tentativeGScore,
                fScore: tentativeFScore,
                cameFrom: thisLocation
            )
            openLocationsLowestFFirst.push(lgfcByLocation[neighborLoc]!)
            openLocations.insert(neighborLoc)
        }
    }
    // There was no path.
    return nil
}
