import Foundation

/// The [types of devices][1] that Spotify content can be played on.
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/player/get-a-users-available-devices/#device-types
public enum DeviceType: String, Codable, Hashable {
    
    case computer = "Computer"
    case tablet = "Tablet"
    case smartphone = "Smartphone"
    case speaker = "Speaker"
    case tv = "TV"
    case avr = "AVR"
    case stb = "STV"
    case audioDongle = "AudioDongle"
    case gameConsole = "GameConsole"
    case castVideo = "CastVideo"
    case castAudio = "CaseAudio"
    case automobile = "Automobile"
    case unknown = "Unknown"
    
}

