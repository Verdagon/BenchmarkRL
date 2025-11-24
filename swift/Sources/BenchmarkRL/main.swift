import Foundation

func getIntArg(args: [String], paramStr: String, defaultValue: Int32) -> Int32 {
    guard let index = args.firstIndex(of: paramStr) else {
        return defaultValue
    }

    let intIndex = index + 1
    if intIndex >= args.count {
        fatalError("Must have a number after \(paramStr). Use --help for help.")
    }

    guard let value = Int32(args[intIndex]) else {
        fatalError("Must have a number after \(paramStr). Use --help for help.")
    }

    return value
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
--only-level    Only generate and display the level, then exit.
""")
    exit(0)
}

let levelWidth = getIntArg(args: args, paramStr: "--width", defaultValue: 80)
let levelHeight = getIntArg(args: args, paramStr: "--height", defaultValue: 22)
let numLevels = getIntArg(args: args, paramStr: "--num_levels", defaultValue: 2)
let seed = getIntArg(
    args: args,
    paramStr: "--seed",
    defaultValue: Int32(Date().timeIntervalSince1970)
)
let display = getIntArg(args: args, paramStr: "--display", defaultValue: 1) != 0
let turnDelay = getIntArg(args: args, paramStr: "--turn_delay", defaultValue: 100)
let onlyLevel = args.contains("--only-level")

benchmarkRL(
    seed: seed,
    levelWidth: levelWidth,
    levelHeight: levelHeight,
    numLevels: numLevels,
    shouldDisplay: display,
    turnDelay: turnDelay,
    onlyLevel: onlyLevel
)
