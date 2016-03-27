
// Tested on xcode, but not on ubuntu yet. Make sure swift doesn't complain about it

#if os(Linux)
import PackageDescription

let package = Package(
    name: "Riffle",
    dependencies: [
        .Package(url: "../../../mantle", majorVersion: 1)
    ]
)
#endif