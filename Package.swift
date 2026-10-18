// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DreameHub",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "DreameHub", targets: ["DreameHub"])],
    targets: [
        .target(name: "DreameCore", linkerSettings: [.linkedLibrary("z")]),
        .executableTarget(name: "DreameHub", dependencies: ["DreameCore"], resources: [.copy("Resources")]),
        .testTarget(name: "DreameCoreTests", dependencies: ["DreameCore"]),
        .testTarget(name: "DreameHubTests", dependencies: ["DreameHub"])
    ]
)
