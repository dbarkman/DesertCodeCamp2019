// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Desert Code Camp",
    products: [],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.8.4"))
    ],
    targets: [
        .target(
            name: "Desert Code Camp",
            dependencies: [
                "PromiseKit"
            ],
            path: "Desert Code Camp"
        ),
    ]
)
