
#if os(Linux)
import PackageDescription

let package = Package(
    name: "Riffle",
    dependencies: [
        // For local testing within exis repo
        //.Package(url: "../../../mantle", majorVersion: 1)

        // For production
        .Package(url: "https://github.com/exis-io/swiftRiffleMantle.git", majorVersion: 0, minorVersion: 2)
    ]
)
#endif