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
    dependencies: [],
    targets: [
        .target(
            name: "LivenessDetection"
        ),
//        // May enable this when VerIDCore is published as Swift package
//        .testTarget(
//            name: "LivenessDetectionTests",
//            dependencies: ["LivenessDetection"],
//            exclude: [
//                "test_input.json", "test_output.json", "Ver-ID identity.p12"
//            ],
//            resources: [
//                .copy("test_input.json"),
//                .copy("test_output.json"),
//                .copy("Ver-ID identity.p12")
//            ]
//        )
    ]
)
