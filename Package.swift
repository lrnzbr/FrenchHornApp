// swift-tools-version: 5.7
import PackageDescription

// Compile the same musical source files as the app, without starting its audio session.
let package = Package(
    name: "HornMusicCore",
    platforms: [.macOS(.v12), .iOS("15.5")],
    targets: [
        .target(
            name: "HornMusicCore",
            path: "FrenchHornApp",
            exclude: [
                "Assets.xcassets", "ContentView.swift", "Controllers", "Extensions.swift",
                "FrenchHornAppApp.swift", "Info.plist", "Preview Content", "Sounds",
                "Theme", "ViewModel", "Views", "Model/TrebleClefNoteVisualizations.swift",
                "Model/MusicTheory/PitchColor.swift"
            ],
            sources: ["Model"]
        ),
        .testTarget(name: "HornMusicCoreTests", dependencies: ["HornMusicCore"], path: "Tests/HornMusicCoreTests")
    ]
)
