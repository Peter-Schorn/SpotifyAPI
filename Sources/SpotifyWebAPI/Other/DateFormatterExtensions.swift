import Foundation

public extension DateFormatter {
    
    /// "yyyy-MM-dd" Date format.
    static let spotifyAlbumLong: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    
    /// "yyyy-MM" Date format.
    static let spotifyAlbumMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    
    /// "yyyy" Date format.
    static let spotifyAlbumShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    
    /**
     Used for debugging purposes. Safe for use in file/folder names.
    
     ```
     "y-MM-dd h-mm-ss.SSSS a"
     ```
     
     For example:
     ```
     "2020-10-13 4-58-40.0750 PM"
     ```
     */
    static let millisecondsTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd h-mm-ss.SSSS a"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    
    /**
     The format used by the
     ``SpotifyAPI/featuredPlaylists(locale:country:timestamp:limit:offset:)``
     endpoint.
     
     ```
     "yyyy-MM-dd'T'HH:mm:ss"
     ```
     */
    static let featuredPlaylists: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    
}

/**
 A formatter that converts between dates and Spotify timestamp strings.
 
 Use the ``SpotifyTimestampFormatter/shared`` instance whenever possible.
 */
public struct SpotifyTimestampFormatter  {
    
    /// A shared instance of `Self`.
    public static let shared = Self()

    public static let secondsFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    public static let millisecondsFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds
        ]
        return formatter
    }()
    
    public func date(from string: String) -> Date? {
        if let date = Self.secondsFormatter.date(from: string) {
            return date
        }
        if let date = Self.millisecondsFormatter.date(from: string) {
            return date
        }
        return nil
    }
    
    public func string(from date: Date) -> String {
        return Self.secondsFormatter.string(from: date)
    }
    
}
