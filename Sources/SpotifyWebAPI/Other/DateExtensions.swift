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
    
    /**
     A formatter for [timestamps][1] used by the Spotify web API.
     
     Timestamps are  in ISO 8601 format as Coordinated Universal Time (UTC)
     with a zero offset:
     ```
     "YYYY-MM-DD'T'HH:mm:SSZ"
     ```

     [1]: https://developer.spotify.com/documentation/web-api/#timestamps
     */
    static let spotifyTimeStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
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
