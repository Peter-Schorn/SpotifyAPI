import Foundation

/// Used in a request to transfer the user's playback to a different device.
struct TransferPlaybackRequest: Codable, Hashable {
    
    /// Although an array is accepted, only a single device id is currently
    /// supported. Supplying more than one will return 400 Bad Request
    let deviceIds: [String]
    
    /// If `true`, then ensure playback happens on the new device. If `false` or
    /// not provided, then keep the current playback state.
    let play: Bool
    
    enum CodingKeys: String, CodingKey {
        case deviceIds = "device_ids"
        case play
    }
}
