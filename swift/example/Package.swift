import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .Package(url: "../swiftRiffle", majorVersion: 1)
    ]
)
