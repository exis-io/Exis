import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .Package(url: "../swiftRiffle/Pod/Classes/", majorVersion: 1)
    ]
)
