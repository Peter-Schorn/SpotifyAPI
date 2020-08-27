import Foundation

/// Used in a request to transfer the user's playback
/// to a different device.
struct TransferPlaybackRequest: Codable, Hashable {
    
    let deviceIds: [String]
    let play: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case deviceIds = "device_ids"
        case play
    }
}
