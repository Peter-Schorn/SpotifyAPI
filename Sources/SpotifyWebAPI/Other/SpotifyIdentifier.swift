import Foundation
import RegularExpressions
import Logger

/**
 Encapsulates the various formats that Spotify
 uses to uniquely identify content. See [spotify URIs and ids][1].

 You can pass an instance of this struct into any method
 that accepts a `SpotifyURIConvertible` type.

 This struct provides a convientent way to convert between
 the different formats, which include the id, the URI, and the URL.

 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 */
public struct SpotifyIdentifier: Codable, Hashable, SpotifyURIConvertible {

    /**
     Creates a comma separated string (with no spaces) of ids from a
     sequence of URIs. (used in the query parameter of some requests).
    
     - Parameters:
       - uris: A sequence of Spotify URIs.
       - ensureAllTypesAre: Ensure the id categories of all the URIs
             match one or more categories.
     - Throws: If `ensureTypeMatches` is not `nil` and the type of a URI
           does not match one the required types or if an id could not be
           parsed from a URI.
     - Returns: A comma-separated string of Ids.
     */
    public static func commaSeparatedIdsString<S: Sequence>(
        _ uris: S, ensureTypeMatches types: [IDCategory]? = nil
    ) throws -> String where S.Element == SpotifyURIConvertible {
        
        return try uris.map { uri in
            
            let spotifyIdentifier = try Self(uri: uri)
            
            if let types = types {
                guard types.contains(spotifyIdentifier.idCategory) else {
                    throw SpotifyLocalError.invalidURIType(
                        expected: types, received: spotifyIdentifier.idCategory
                    )
                }
            }
            
            return spotifyIdentifier.id
            
        }
        .joined(separator: ",")
    }
    
    
    /// The id for the Spotify content.
    public var id: String

    /// The id category for the Spotify content.
    public var idCategory: IDCategory

    /**
     The unique resource identifier for the Spotify content.
     
     Eqvuivalent to"
     ```
     "spotify:\(idCategory.rawValue):\(id.strip())"
     ```
     The strip method simply removes leading and trailing whitespace.
     */
    @inlinable
    public var uri: String {
        "spotify:\(idCategory.rawValue):\(id.strip())"
    }

    /**
     Use this URL to open the content in the web player.
     
     Equivalent to:
     ```
     "https://open.spotify.com/\(idCategory.rawValue)/\(id.strip())"
     ```
     
     The strip method simply removes leading and trailing whitespace.
     */
    public var url: URL? {
        guard let url =  URL(
            scheme: "https",
            host: "open.spotify.com",
            path: "/\(idCategory.rawValue)/\(id.strip())"
        )
        else {
            return nil
        }
        return url
    }

    /// Creates an instance from an id and an id category.
    /// See [spotify URIs and ids][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public init(id: String, idCategory: IDCategory) {
        self.id = id.strip()
        self.idCategory = idCategory
    }

    /// Creates an instance from a URI. See [spotify URIs and ids][1].
    ///
    /// - Parameters:
    ///   - uri: A Spotify URI.
    ///   - types: If not `nil`, throw an error if the type of the URI
    ///     does not match one of these id categories. See `IDCategory` for more
    ///     information.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public init(
        uri: SpotifyURIConvertible,
        ensureTypeMatches types: [IDCategory]? = nil
    ) throws {
        
        guard
            let captureGroups = try! uri.uri
                    .regexMatch("spotify:(.*):(.*)")?.groups,
            captureGroups.count >= 2,
            let idCategoryString = captureGroups[0]?.match,
            let idCategory = IDCategory(rawValue: idCategoryString),
            let id = captureGroups[1]?.match
        else {
            throw SpotifyLocalError.identifierParsingError(
                "could not parse spotify id and/or " +
                "id category from string: '\(uri)'"
            )
        }

        self.id = id.strip()
        self.idCategory = idCategory
        
        if let types = types, !types.contains(idCategory) {
            throw SpotifyLocalError.invalidURIType(
                expected: types, received: idCategory
            )
        }

    }
    
    /// Creates an instance from a Spotify URL to the content.
    public init(url: URL) throws {
        
        let paths = url.pathComponents
        
        guard
            paths.count >= 2,
            let category = IDCategory(rawValue: paths[2])
        else {
            throw SpotifyLocalError.identifierParsingError(
                "could not parse spotify id category and/or id " +
                "from url: '\(url)'"
            )
        }
        
        self.id = paths[1]
        self.idCategory = category
        
    }

}

