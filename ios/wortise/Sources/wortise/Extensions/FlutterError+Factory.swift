import Flutter

extension FlutterError {

    static func invalidArgument(_ message: String = "Invalid argument") -> FlutterError {
        return FlutterError(code: "INVALID_ARGUMENT", message: message, details: nil)
    }
}
