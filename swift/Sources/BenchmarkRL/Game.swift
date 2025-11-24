import Foundation

struct Game {
    let seed: Int
    let width: Int
    let height: Int
    let numLevels: Int
    let display: Bool
    let turnDelay: Int

    mutating func run() {
        print("Game running with \(numLevels) levels...")
        // TODO: Implement game logic here
        // This is a placeholder for the actual roguelike implementation

        for levelNum in 1...numLevels {
            if display {
                print("Level \(levelNum)/\(numLevels)")
            }

            // Simulate some game work
            Thread.sleep(forTimeInterval: Double(turnDelay) / 1000.0)
        }

        print("Game complete!")
    }
}
