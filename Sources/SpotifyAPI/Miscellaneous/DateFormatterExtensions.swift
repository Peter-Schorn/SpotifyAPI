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
}

private enum SpotifyDateCodingKeys: String, CodingKey {
    case releaseDate = "release_date"
}


/// Decodes a Date from a date-string with one of
/// the following formats:
///
/// - "YYYY-MM-DD"
/// - "YYYY-MM"
/// - "YYYY"
public func decodeSpotifyAlbumReleaseDate(decoder: Decoder) throws -> Date {
    
    let container = try decoder.container(
        keyedBy: SpotifyDateCodingKeys.self
    )
    let dateString = try container.decode(
        String.self, forKey: .releaseDate
    )
    
    if let longDate = DateFormatter.spotifyAlbumLong
            .date(from: dateString) {
        return longDate
    }
    else if let mediumDate = DateFormatter.spotifyAlbumMedium
            .date(from: dateString) {
        return mediumDate
    }
    else if let shortDate = DateFormatter.spotifyAlbumShort
            .date(from: dateString) {
        return shortDate
    }
    else {
        
        let errorMessage = """
            Could not decode the release date. \
            It must be in one of the following formats:
            "YYYY-MM-DD"
            "YYYY-MM"
            "YYYY"
            """
        
        throw DecodingError.typeMismatch(
            Date.self,
            DecodingError.Context(
                codingPath: [SpotifyDateCodingKeys.releaseDate],
                debugDescription: errorMessage
            )
        )
    }
    
}

/// Encodes date to a date-string in one of
/// the following formats, depending on the `datePrecision`:
///
/// - "YYYY-MM-DD" if `datePrecision` == "day"
/// - "YYYY-MM" if `datePrecision` == "month"
/// - "YYYY" (default)
public func encodeSpotifyAlbumReleaseDate(
    _ date: Date, to encoder: Encoder, datePrecision: String?
) throws {
    

    let formatter: DateFormatter
    
    switch datePrecision {
        case "day":
            formatter = .spotifyAlbumLong
        case "month":
            formatter = .spotifyAlbumMedium
        default:
            formatter = .spotifyAlbumShort
    }
    
    let dateString = formatter.string(from: date)
    
    var container = encoder.container(
        keyedBy: SpotifyDateCodingKeys.self
    )
    
    try container.encode(dateString, forKey: .releaseDate)
    
}

