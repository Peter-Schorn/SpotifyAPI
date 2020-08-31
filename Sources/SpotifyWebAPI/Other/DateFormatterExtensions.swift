import Foundation

public extension DateFormatter {
    
    /// "YYYY-MM-DD" Date format.
    static let spotifyAlbumLong: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        return formatter
    }()
    
    /// "YYYY-MM" Date format.
    static let spotifyAlbumMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM"
        return formatter
    }()
    
    /// "YYYY" Date format.
    static let spotifyAlbumShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
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
        return formatter
    }()
    
}

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
