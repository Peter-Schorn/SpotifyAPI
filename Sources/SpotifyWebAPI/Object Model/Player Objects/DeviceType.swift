import Foundation

/// The [types of devices][1] that Spotify content can be played on.
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/player/get-a-users-available-devices/#device-types
public enum DeviceType: String, Codable, Hashable, CaseIterable {
    
    /// A computer.
    case computer = "Computer"
    
    /// A tablet.
    case tablet = "Tablet"
    
    /// A smartphone.
    case smartphone = "Smartphone"
    
    /// A speaker.
    case speaker = "Speaker"
    
    /// A TV.
    case tv = "TV"
    
    /// An AVR.
    case avr = "AVR"
    
    /// An STB.
    case stb = "STB"
    
    /// An audio dongle.
    case audioDongle = "AudioDongle"
    
    /// A game console.
    case gameConsole = "GameConsole"
    
    /// A video cast.
    case castVideo = "CastVideo"
    
    /// An audio cast.
    case castAudio = "CastAudio"
    
    /// An automobile.
    case automobile = "Automobile"
    
    /// Unknown.
    case unknown = "Unknown"
    
}
