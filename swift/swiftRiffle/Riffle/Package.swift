import PackageDescription

let package = Package(
    name: "Riffle",
    dependencies: [
        .Package(url: "../../mantle", majorVersion: 1)
    ]
)
