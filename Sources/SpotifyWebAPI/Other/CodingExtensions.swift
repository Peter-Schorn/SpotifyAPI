import Foundation

private extension KeyedDecodingContainer {
    
    func decodeSpotifyDateFromString(
        _ dateString: String,
        key: Key
    ) throws -> Date {
        
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
                Could not decode Spotify album date: '\(dateString)'.
                It must be in one of the following formats:
                "YYYY-MM-DD"
                "YYYY-MM"
                "YYYY"
                """
            
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: errorMessage
            )
        }
        
    }
    
    func decodeSpotifyTimestampFromString(
        _ dateString: String,
        key: Key
    ) throws -> Date {
        
        if let date = SpotifyTimestampFormatter.shared.date(
            from: dateString
        ) {
            return date
        }
        else {
            
            let errorMessage = """
                Could not decode Spotify timestamp from '\(dateString)'
                for key \(key). It must be in ISO 8601 format.
                """
            
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: errorMessage
            )
            
        }
        
    }
    
}

public extension KeyedDecodingContainer {
    
    
    // MARK: - Spotify Dates -
    
    /**
     Decodes a Date from a date-string with one of
     the following formats:
    
     - "YYYY-MM-DD"
     - "YYYY-MM"
     - "YYYY"
    
     - Parameter key: The key that is associated with a date string in one of
           the above formats.
     - Throws: If the value cannot be decoded into a string, or if the format of
           the string does not match any of the above formats.
     - Returns: The decoded Date.
     */
    func decodeSpotifyDate(forKey key: Key) throws -> Date {
        
        let dateString = try self.decode(String.self, forKey: key)
        return try self.decodeSpotifyDateFromString(
            dateString, key: key
        )
        
    }
    
    /**
     Decodes a Date from a date-string with one of
     the following formats:
    
     - "YYYY-MM-DD"
     - "YYYY-MM"
     - "YYYY"
    
     - Parameter key: The key that is associated with a date string in one of
           the above formats.
     - Throws: If the value cannot be decoded into a string.
     - Returns: The decoded Date, or `nil` if no date-string is present for the
           given key, **or if the format of the date-string is invalid**.
     */
    func decodeSpotifyDateIfPresent(
        forKey key: Key
    ) throws -> Date? {
    
        guard let dateString = try self.decodeIfPresent(
            String.self, forKey: key
        )
        else {
            return nil
        }
        
        return try? self.decodeSpotifyDateFromString(
            dateString, key: key
        )

    }
    
    // MARK: - Spotify Timestamp -
    
    func decodeSpotifyTimestamp(forKey key: Key) throws -> Date {
        
        let dateString = try self.decode(String.self, forKey: key)
        return try self.decodeSpotifyTimestampFromString(
            dateString, key: key
        )
        
    }
    
    func decodeSpotifyTimestampIfPresent(
        forKey key: Key
    ) throws -> Date? {
        
        guard let dateString = try self.decodeIfPresent(
            String.self, forKey: key
        )
        else {
            return nil
        }
        
        return try self.decodeSpotifyTimestampFromString(
            dateString, key: key
        )
        
    }
    
    // MARK: - Milliseconds Since 1970 -
    
    func decodeMillisecondsSince1970(
        forKey key: Key
    ) throws -> Date {
        
        let milliseconds = try self.decode(Int64.self, forKey: key)
        return Date(millisecondsSince1970: TimeInterval(milliseconds))
        
    }
    
    func decodeMillisecondsSince1970IfPresent(
        forKey key: Key
    ) throws -> Date? {
        
        guard let milliseconds = try self.decodeIfPresent(
            Int64.self, forKey: key
        ) else {
            return nil
        }
        return Date(millisecondsSince1970: TimeInterval(milliseconds))
        
    }
    
    // MARK: - Spotify Scopes -
    
    func decodeSpotifyScopesIfPresent(
        forKey key: Key
    ) throws -> Set<Scope>? {
        
        if let scopeString = try self.decodeIfPresent(
            String.self, forKey: key
        ) {
            return Scope.makeSet(scopeString)
        }
        else {
            return nil
        }
    }
    
    // MARK: - Expires in Seconds -
 
    func decodeDateFromExpiresInSeconds(
        forKey key: Key
    ) throws -> Date {
        
        let expiresInSeconds = try self.decode(Int.self, forKey: key)
        return Date(timeInterval: Double(expiresInSeconds), since: Date())
        
    }
    
    func decodeDateFromExpiresInSecondsIfPresent(
        forKey key: Key
    ) throws -> Date? {
        
        guard
            let expiresInSeconds = try self.decodeIfPresent(
                Int.self, forKey: key
            )
        else {
            return nil
        }
        return Date(timeInterval: Double(expiresInSeconds), since: Date())
        
    }
    
    
}

public extension KeyedEncodingContainer {
    
    // MARK: - Spotify Dates -
    
    /**
     Encodes a Date to a date-string in one of the following formats, depending
     on the `datePrecision`.

     The date will be encoded into a date-string using a format based on the
     value of `datePrecision`:

     * "YYYY-MM-DD" if `datePrecision` == "day"
     * "YYYY-MM" if `datePrecision` == "month"
     * "YYYY" if `datePrecision` == "year" or == `nil`.
     
     - Parameters:
       - date: A Date.
       - datePrecision: One of the above-mentioned values.
       - key: A key to associate the Date with.
     - Throws: If the date string could not be encoded into the container for
           the given key.
     */
    mutating func encodeSpotifyDate(
        _ date: Date,
        datePrecision: String?,
        forKey key: Key
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
        
        try self.encode(dateString, forKey: key)
        
    }
    
    /**
     Encodes a Date to a date-string in one of the following formats, depending
     on the `datePrecision`.

     If `date` is `nil`, then doesn't encode anything.

     The date will be encoded into a date-string using a format based on the
     value of `datePrecision`:

     * "YYYY-MM-DD" if `datePrecision` == "day"
     * "YYYY-MM" if `datePrecision` == "month"
     * "YYYY" if `datePrecision` == "year" or == `nil`.
     
     - Parameters:
       - date: A Date.
       - datePrecision: One of the above-mentioned values.
       - key: A key to associate the Date with.
     - Throws: If the date string could not be encoded into the container for
           the given key.
     */
    mutating func encodeSpotifyDateIfPresent(
        _ date: Date?,
        datePrecision: String?,
        forKey key: Key
    ) throws {
        
        guard let date = date else { return }
        try self.encodeSpotifyDate(
            date, datePrecision: datePrecision, forKey: key
        )
    }
    
    // MARK: - Spotify Timestamp -
    
    mutating func encodeSpotifyTimestamp(
        _ date: Date,
        forKey key: Key
    ) throws {
        
        let dateString = SpotifyTimestampFormatter.shared.string(
            from: date
        )
        try self.encode(dateString, forKey: key)
        
    }
    
    mutating func encodeSpotifyTimestampIfPresent(
        _ date: Date?,
        forKey key: Key
    ) throws {
        
        guard let date = date else { return }
        try self.encodeSpotifyTimestamp(date, forKey: key)
        
    }
    
    // MARK: - Milliseconds Since 1970 -
    
    mutating func encodeMillisecondsSince1970(
        _ date: Date,
        forKey key: Key
    ) throws {
        
        let milliseconds = Int64(date.millisecondsSince1970)
        try self.encode(milliseconds, forKey: key)
        
    }
    
    mutating func encodeMillisecondsSince1970IfPresent(
        _ date: Date?,
        forKey key: Key
    ) throws {
        
        
        guard let date = date else { return }
        try self.encodeMillisecondsSince1970(date, forKey: key)
        
    }
    
    
    // MARK: - Spotify Scopes -
    
    mutating func encodeSpotifyScopesIfPresent(
        _ scopes: Set<Scope>?, forKey key: Key
    ) throws {
        
        guard let scopes = scopes else { return }
        let scopeString = Scope.makeString(scopes)
        try self.encode(scopeString, forKey: key)
        
    }

    
}
