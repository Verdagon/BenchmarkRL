// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchmarkRL",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "BenchmarkRL",
            targets: ["BenchmarkRL"]
        )
    ],
    targets: [
        .executableTarget(
            name: "BenchmarkRL",
            path: "Sources/BenchmarkRL"
        )
    ]
)
