import Foundation

struct Location: Hashable, Equatable, CustomStringConvertible {
    let x: Int32
    let y: Int32

    func distSquared(_ other: Location) -> Int32 {
        let dx = self.x - other.x
        let dy = self.y - other.y
        return dx * dx + dy * dy
    }

    func nextTo(
        _ other: Location,
        considerCornersAdjacent: Bool,
        includeSelf: Bool
    ) -> Bool {
        let distSquared = self.distSquared(other)
        let minSquaredDistance: Int32 = includeSelf ? 0 : 1
        let maxSquaredDistance: Int32 = considerCornersAdjacent ? 2 : 1
        return distSquared >= minSquaredDistance && distSquared <= maxSquaredDistance
    }

    // This is different than the normal manhattan distance.
    // Normal manhattan distance will give you the difference in x plus the difference
    // in y.
    // This allows us to go diagonal as well.
    //
    // Normal manhattan distance     Diagonal manhattan distance
    //
    //     ..................            ..................
    //     ...............g..            ...............g..
    //     ...............|..            ............../...
    //     ...............|..            ............./....
    //     ...............|..            ............/.....
    //     .@--------------..            .@----------......
    //     ..................            ..................
    //
    // The 100 means times 100, for better precision.
    //
    func diagonalManhattanDistance100(_ other: Location) -> Int32 {
        let xDist = abs(self.x - other.x)
        let yDist = abs(self.y - other.y)
        let diagonalDist = min(xDist, yDist)
        let remainingXDist = xDist - diagonalDist
        let remainingYDist = yDist - diagonalDist
        return diagonalDist * 144 + remainingXDist * 100 + remainingYDist * 100
    }

    var description: String {
        return "(\(x), \(y))"
    }
}
