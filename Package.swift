// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusClock",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "FocusClock",
            path: "Sources/FocusClock"
        )
    ]
)
