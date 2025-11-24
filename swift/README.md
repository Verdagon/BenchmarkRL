# BenchmarkRL - Swift Implementation

A roguelike benchmark implementation in Swift, similar to the Rust version.

## Building

```bash
swift build -c release
```

## Running

```bash
swift run -c release BenchmarkRL --display 0 --num_levels 10
```

Or after building:

```bash
.build/release/BenchmarkRL --display 0 --num_levels 10
```

## Command Line Options

- `--width N` - Sets level width (default: 80)
- `--height N` - Sets level height (default: 22)
- `--num_levels N` - Sets number of levels until game end (default: 2)
- `--seed N` - Uses given seed for level generation (default: random)
- `--display N` - 0 to not display, 1 to display (default: 1)
- `--turn_delay N` - Sleeps for N ms between each turn (default: 100)

## TODO

Implement the following modules (similar to Rust version):
- [ ] Location.swift - Position/coordinate types
- [ ] Tile.swift - Map tiles
- [ ] Level.swift - Level/map management
- [ ] Unit.swift - Player and enemy entities
- [ ] Items.swift - Game items
- [ ] AStar.swift - A* pathfinding algorithm
- [ ] Chase.swift - Enemy chase AI
- [ ] Seek.swift - Seeking behavior
- [ ] Wander.swift - Wandering AI
- [ ] Attack.swift - Combat system
- [ ] Fire.swift - Fire mechanics
- [ ] Explodey.swift - Explosion mechanics
- [ ] MakeLevel.swift - Procedural level generation
- [ ] Screen.swift - Display/rendering
