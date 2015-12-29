import PackageDescription

let package = Package(
    name: "riffle",
    dependencies: [
        .Package(url: "../mantle", majorVersion: 1)
    ]
)
