import Foundation

// Command line argument parsing
func getIntArg(_ args: [String], param: String, default defaultValue: Int) -> Int {
    guard let index = args.firstIndex(of: param), index + 1 < args.count else {
        return defaultValue
    }
    return Int(args[index + 1]) ?? defaultValue
}

let args = CommandLine.arguments

if args.contains("--help") {
    print("""

    --width N       Sets level width.
    --height N      Sets level height.
    --num_levels N  Sets number of levels until game end.
    --seed N        Uses given seed for level generation. If absent, random.
    --display N     0 to not display, 1 to display.
    --turn_delay N  Sleeps for N ms between each turn.
    """)
    exit(0)
}

let levelWidth = getIntArg(args, param: "--width", default: 80)
let levelHeight = getIntArg(args, param: "--height", default: 22)
let numLevels = getIntArg(args, param: "--num_levels", default: 2)
let seed = getIntArg(args, param: "--seed", default: Int(Date().timeIntervalSince1970))
let display = getIntArg(args, param: "--display", default: 1) != 0
let turnDelay = getIntArg(args, param: "--turn_delay", default: 100)

print("Starting BenchmarkRL with Swift")
print("Level size: \(levelWidth)x\(levelHeight)")
print("Number of levels: \(numLevels)")
print("Seed: \(seed)")
print("Display: \(display)")
print("Turn delay: \(turnDelay)ms")

// Run the benchmark
benchmarkRL(
    seed: seed,
    levelWidth: levelWidth,
    levelHeight: levelHeight,
    numLevels: numLevels,
    display: display,
    turnDelay: turnDelay
)
