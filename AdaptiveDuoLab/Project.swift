import ProjectDescription

let project = Project(
    name: "AdaptiveDuoLab",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_STRICT_CONCURRENCY": "complete"
            // Native 27.1 demo symbols are opt-in. Automation adds DUO_SDK to
            // SWIFT_ACTIVE_COMPILATION_CONDITIONS only with DUO_SDK=1.
        ]
    ),
    targets: [
        .target(
            name: "AdaptiveDuoLab",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.example.AdaptiveDuoLab",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
                    "NSCameraUsageDescription": "Show a live rear-camera preview in the Camera API demo.",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ]
                ]
            ),
            sources: ["Sources/**"]
        ),
        .target(
            name: "AdaptiveDuoLabTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.example.AdaptiveDuoLabTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "AdaptiveDuoLab")]
        ),
        .target(
            name: "AdaptiveDuoLabUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "com.example.AdaptiveDuoLabUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["UITests/**"],
            dependencies: [.target(name: "AdaptiveDuoLab")]
        )
    ]
)
