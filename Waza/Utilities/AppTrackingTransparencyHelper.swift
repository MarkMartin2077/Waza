import AppTrackingTransparency
import AdSupport

enum AppTrackingTransparencyHelper {

    @MainActor
    static func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        await ATTrackingManager.requestTrackingAuthorization()
    }
}

extension ATTrackingManager.AuthorizationStatus {

    var eventParameters: [String: Any] {
        var dict: [String: Any] = ["att_status": statusName]
        if self == .authorized {
            dict["att_idfa"] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return dict
    }

    private var statusName: String {
        switch self {
        case .notDetermined: return "not_determined"
        case .restricted:    return "restricted"
        case .denied:        return "denied"
        case .authorized:    return "authorized"
        @unknown default:    return "unknown"
        }
    }
}
