
import PackageDescription

// This is a "stub" package for local development. The makefile swaps these out when building local
let package = Package(
    name: "Riffle",
    dependencies: [
        .Package(url: "../../../mantle", majorVersion: 1)
    ]
)
