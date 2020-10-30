import Foundation
import Logging

/**
 The [context][1] of the currently playing track/episode.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/player/get-information-about-the-users-current-playback/#Currently-Playing-Context
 */
public struct CurrentlyPlayingContext: Hashable {
    
    /// Logs messages for this struct, especially those involving
    /// the decoding of data into this type.
    static var logger = Logger(
        label: "CurrentlyPlayingContext", level: .critical
    )
    
    /// This property has been renamed to `device`.
    @available(*, deprecated, renamed: "device")
    public var activeDevice: Device { device }
    
    /**
     The device that the content is or was playing on.
     
     The information returned by `SpotifyAPI.currentPlayback(market:)`
     is for the last known state, which means an inactive device could be
     returned if it was the last one to execute playback.
     
     Use `SpotifyAPI.availableDevices()` to get the current user's available
     and active devices.
     */
    public let device: Device
    
    /// The repeat mode of the player.
    /// Either `off`, `track`, or `context`.
    public let repeatState: RepeatMode
    
    /// `true` if shuffle mode is on; else, `false`.
    public let shuffleIsOn: Bool
    
    /**
     The context of the user's playback.
     
     Can be `nil`. For example, If the user has a private
     session enabled, then this will be `nil`.
     
     - Note: Testing suggets that if the user is playing an episode,
           then this will be `nil`.
     */
    public let context: SpotifyContext?
    
    /// The date the data was fetched (converted from a Unix
    /// millisecond-precision timestamp).
    public let timestamp: Date
    
    /// Progress into the currently playing track/episode in
    /// milliseconds.
    ///
    /// Can be `nil`. For example, If the user has a private
    /// session enabled, then this will be `nil`.
    public let progressMS: Int?
    
    /// `true` if content is currently playing. Else, `false`.
    public let isPlaying: Bool
    
    /**
     The full version of a track or episode. Represents the content
     that is, or was most recently, playing.
     
     Use `isPlaying` to check if the content is currently playing.
     
     Although the type is `PlaylistItem`, this does not necessarily
     mean that the item is playing in the context of a playlist.
    
     Can be `nil`. For example, If the user has a private
     session enabled, then this will be `nil`.
     
     */
    public let item: PlaylistItem?
    
    /// This property has been renamed to `item`.
    @available(*, deprecated, renamed: "item")
    public var currentlyPlayingItem: PlaylistItem? { item }
    
    /// The object type of `item`—the content that is, or was most
    /// recently, playing.
    ///
    /// Can be `track`, `episode`, or `unknown`.
    public let itemType: IDCategory
    
    /// This property has been renamed to `itemType`.
    @available(*, deprecated, renamed: "itemType")
    public var currentlyPlayingType: IDCategory { itemType }
    
    /**
     The playback actions that are allowed within the given context.
    
     Attemping to perform actions that are not contained within this set
     will result in an error from the Spotify web API.
     
     For example, you cannot skip to the previous or next track/episode
     or seek to a position in a track/episode while an ad is playing.
    
     You could use this property to disable UI elements that perform
     actions that are not contained within this set.
     */
    public let allowedActions: Set<PlaybackActions>
    
}

extension CurrentlyPlayingContext: Codable {
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case device
        case repeatState = "repeat_state"
        case shuffleIsOn = "shuffle_state"
        case context
        case timestamp
        case progressMS = "progress_ms"
        case isPlaying = "is_playing"
        case item
        case itemType = "currently_playing_type"
        case allowedActions = "actions"
    }
    
    // the keys for the dictionary must be `String` or `Int`, or `JSONDecoder`
    // will try and fail to decode the dictionary into an array
    // see https://forums.swift.org/t/rfc-can-this-codable-bug-still-be-fixed/18501/2
    private typealias DisallowsObject = [String: [String: Bool?]]
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.device = try container.decode(
            Device.self, forKey: .device
        )
        self.repeatState = try container.decode(
            RepeatMode.self, forKey: .repeatState
        )
        self.shuffleIsOn = try container.decode(
            Bool.self, forKey: .shuffleIsOn
        )
        self.context = try container.decodeIfPresent(
            SpotifyContext.self, forKey: .context
        )
        self.timestamp = try container.decodeMillisecondsSince1970(
            forKey: .timestamp
        )
        self.progressMS = try container.decodeIfPresent(
            Int.self, forKey: .progressMS
        )
        self.isPlaying = try container.decode(
            Bool.self, forKey: .isPlaying
        )
        self.item = try container.decodeIfPresent(
            PlaylistItem.self, forKey: .item
        )
        self.itemType = try container.decode(
            IDCategory.self, forKey: .itemType
        )
        
        // allowedActions = "actions"
        let disallowsObject = try container.decode(
            DisallowsObject.self, forKey: .allowedActions
        )
        
        guard let disallowsDictionary = disallowsObject["disallows"] else {
            let debugDescription = """
                expected to find top-level key "disallows" in the following \
                dictionary:
                \(disallowsObject)
                """
            throw DecodingError.dataCorruptedError(
                forKey: .allowedActions,
                in: container,
                debugDescription: debugDescription
            )
        }
        
        /*
         "If an action is included in the disallows object and set to true,
         that action is DISALLOWED.
         see https://developer.spotify.com/documentation/web-api/reference/object-model/#disallows-object
         */
        
        let disallowedActions: [PlaybackActions] = disallowsDictionary
            .compactMap { item -> PlaybackActions? in
                if item.value == true {
                    if let action = PlaybackActions(rawValue: item.key) {
                        return action
                    }
                    Self.logger.error(
                        """
                        unexpected PlaybackAction: '\(item.key)'; \
                        must be one of the following: \
                        \(PlaybackActions.allCases.map(\.rawValue))
                        """
                    )
                    return nil
                }
                return nil
            }
        
        self.allowedActions = PlaybackActions.allCases.subtracting(
            disallowedActions
        )
        
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.device, forKey: .device
        )
        try container.encode(
            self.repeatState, forKey: .repeatState
        )
        try container.encode(
            self.shuffleIsOn, forKey: .shuffleIsOn
        )
        try container.encodeIfPresent(
            self.context, forKey: .context
        )
        try container.encodeMillisecondsSince1970(
            self.timestamp, forKey: .timestamp
        )
        try container.encodeIfPresent(
            self.progressMS, forKey: .progressMS
        )
        try container.encode(
            self.isPlaying, forKey: .isPlaying
        )
        try container.encodeIfPresent(
            self.item, forKey: .item
        )
        try container.encode(
            self.itemType, forKey: .itemType
        )
        
        // Encode `allowedActions` by working backwards from how
        // it is decoded so that it can always be decoded the same way.
        let disallowedActions = PlaybackActions.allCases.subtracting(
            self.allowedActions
        )
     
        let disallowsDictionary: [String: Bool?] = disallowedActions
            .reduce(into: [:]) { dict, disallowedAction in
                dict[disallowedAction.rawValue] = true
            }
        
        // wrap it in a dictionary with the same top-level key
        // that Spotify returns
        let disallowsObject: DisallowsObject = [
            "disallows": disallowsDictionary
        ]
        
        try container.encode(
            disallowsObject, forKey: .allowedActions
        )
        
    }
    
}




