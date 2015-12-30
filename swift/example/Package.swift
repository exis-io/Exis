import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .Package(url: "../swiftRiffle/Riffle", majorVersion: 1)
    ]
)
