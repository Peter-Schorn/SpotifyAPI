import Foundation

/**
 A device that Spotify Content can be played on.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/player/get-a-users-available-devices/#device-object
 */
public struct Device: Hashable {
    
    /// The device id.
    public let id: String?
    
    /// Whether the device is currently active
    public let isActive: Bool
    
    /// Whether the device is currently in a private session
    public let isPrivateSession: Bool
    
    /// Whether controlling this device is restricted.
    /// If `true`, then no Web API commands will be accepted by this device.
    public let isRestricted: Bool
    
    /// The name of the device.
    public let name: String
    
    /// The type of the device
    public let type: DeviceType
    
    /// The current volume in percent.
    public let volumePercent: Int?

}

extension Device: Codable {
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case name
        case type
        case volumePercent = "volume_percent"
    }
    
}
