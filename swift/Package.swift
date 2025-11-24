// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BenchmarkRL",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "BenchmarkRL",
            targets: ["BenchmarkRL"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "BenchmarkRL",
            dependencies: []
        )
    ]
)
