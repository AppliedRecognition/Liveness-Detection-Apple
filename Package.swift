// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "LivenessDetection",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "LivenessDetection",
            targets: ["LivenessDetection"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/weichsel/ZIPFoundation",
            from: "0.9.16"
        )
    ],
    targets: [
        .target(
            name: "LivenessDetection"
        ),
        .testTarget(
            name: "LivenessDetectionTests",
            dependencies: ["LivenessDetection", "ZIPFoundation"],
            exclude: [
                "test_input.json", "test_output.json"
            ],
            resources: [
                .copy("test_input.json"),
                .copy("test_output.json")
            ]
        )
    ]
)
