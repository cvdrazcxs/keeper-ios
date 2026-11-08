// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TKLocalize",
    defaultLocalization: "EN",
    products: [
        .library(
            name: "TKLocalize",
            targets: ["TKLocalize"]
        ),
    ],
    targets: [
        .target(
            name: "TKLocalize",
            resources: [.process("Resources/Locales")],

            swiftSettings: [
            ]
        ),
        .testTarget(
            name: "TKLocalizeTests",
            dependencies: [
                "TKLocalize",
            ],

            swiftSettings: [
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
