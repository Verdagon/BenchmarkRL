import Foundation

func benchmarkRL(
    seed: Int,
    levelWidth: Int,
    levelHeight: Int,
    numLevels: Int,
    display: Bool,
    turnDelay: Int
) {
    var game = Game(
        seed: seed,
        width: levelWidth,
        height: levelHeight,
        numLevels: numLevels,
        display: display,
        turnDelay: turnDelay
    )

    game.run()
}
