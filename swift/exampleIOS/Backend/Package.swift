#if os(Linux)
import PackageDescription

let package = Package(
    dependencies: [
        // For local testing within exis repo
        //.Package(url: "../../swiftRiffle/Pod/Classes/", majorVersion: 1)

        // For production
        .Package(url: "https://github.com/exis-io/swiftRiffleUbuntu.git", majorVersion: 0, minor: 2)
    ]
)
#endif