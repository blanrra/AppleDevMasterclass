// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HabitTracker",
    platforms: [.iOS(.v26), .watchOS(.v26)],
    products: [
        .library(name: "HabitCore", targets: ["HabitCore"]),
    ],
    targets: [
        .target(name: "HabitCore"),
        .testTarget(name: "HabitCoreTests", dependencies: ["HabitCore"]),
    ]
)
