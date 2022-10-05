import Foundation

/// A device that Spotify Content can be played on.
public struct Device: Hashable {
    
    /// The device id. May be `nil`.
    public let id: String?
    
    /// Whether the device is currently active.
    public let isActive: Bool
    
    /// Whether the device is currently in a private session.
    public let isPrivateSession: Bool
    
    /// Whether controlling this device is restricted. If `true`, then no web
    /// API commands will be accepted by this device.
    public let isRestricted: Bool
    
    /// The name of the device.
    public let name: String
    
    /// The type of the device.
    public let type: DeviceType
    
    /// The current volume in percent (0 to 100).
    public let volumePercent: Int?

    /**
     A device that Spotify Content can be played on.
     
     - Parameters:
       - id: The device id. May be `nil`.
       - isActive: Whether the device is currently active.
       - isPrivateSession: Whether the device is currently in a private session.
       - isRestricted: Whether controlling this device is restricted. If `true`,
             then no web API commands will be accepted by this device.
       - name: The name of the device.
       - type: The type of the device.
       - volumePercent: The current volume in percent (0 to 100).
     */
    public init(
        id: String?,
        isActive: Bool,
        isPrivateSession: Bool,
        isRestricted: Bool,
        name: String,
        type: DeviceType,
        volumePercent: Int?
    ) {
        self.id = id
        self.isActive = isActive
        self.isPrivateSession = isPrivateSession
        self.isRestricted = isRestricted
        self.name = name
        self.type = type
        self.volumePercent = volumePercent
    }

}

extension Device: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case name
        case type
        case volumePercent = "volume_percent"
    }
    
}
