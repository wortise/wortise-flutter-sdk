import WortiseSDK

extension WARequestParameters {

    static func from(_ args: [String: Any]?) -> WARequestParameters {
        let params = args?["requestParameters"] as? [String: Any]

        return WARequestParameters(
            agent:       params?["agent"] as? String,
            collapsible: collapsiblePosition(params)
        )
    }


    private static func collapsiblePosition(_ params: [String: Any]?) -> WACollapsiblePosition? {
        switch params?["collapsible"] as? String {
        case "bottom": return .bottom
        case "top":    return .top
        default:       return nil
        }
    }
}
