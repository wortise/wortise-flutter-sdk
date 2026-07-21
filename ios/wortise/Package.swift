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
        // Keep this exact pin aligned with the podspec's WortiseSDK dependency.
        .package(url: "https://github.com/wortise/wortise-ios-sdk-spm.git", exact: "1.8.0-beta.6"),
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
