import WortiseSDK

extension WAAdError {

    func toMap() -> [String: Any?] {
        return [
            "error": name
        ]
    }
}
