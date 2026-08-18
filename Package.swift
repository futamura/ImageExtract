// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ImageExtract",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "ImageExtract", targets: ["ImageExtract"])
    ],
    targets: [
        .target(
            name: "ImageExtract",
            path: "Source",
            exclude: ["Info.plist", "ImageExtract.h"]
        ),
        .testTarget(
            name: "ImageExtractTests",
            dependencies: ["ImageExtract"],
            path: "Tests",
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources/TestImage.json")
            ]
        )
    ]
)
