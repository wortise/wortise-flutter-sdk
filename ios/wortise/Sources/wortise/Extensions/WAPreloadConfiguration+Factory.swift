import WortiseSDK

extension WAPreloadConfiguration {

    static func from(_ args: [String: Any]?) -> WAPreloadConfiguration {
        WAPreloadConfiguration(
            bufferSize: args?["bufferSize"] as? Int ?? 1,
            parameters: WARequestParameters.from(args)
        )
    }
}
