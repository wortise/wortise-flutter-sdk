// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "wortise",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "wortise", targets: ["wortise"])
    ],
    dependencies: [
        // First SPM release of the native SDK is 1.8.0-beta.5; align the exact pin
        // with the podspec dependency once 1.8.0 final ships.
        .package(url: "https://github.com/wortise/wortise-ios-sdk-spm.git", exact: "1.8.0-beta.5"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "13.4.0")
    ],
    targets: [
        .target(
            name: "wortise",
            dependencies: [
                .product(name: "WortiseSDK", package: "wortise-ios-sdk-spm"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ]
        )
    ]
)
