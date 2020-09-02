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
    
    /// Used for debugging purposes.
    ///
    /// ```
    /// "hh-mm-ss"
    /// ```
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh-mm-ss"
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    
}

/// A formatter that converts between dates and Spotify timestamp strings.
public struct SpotifyTimestampFormatter  {
    
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
