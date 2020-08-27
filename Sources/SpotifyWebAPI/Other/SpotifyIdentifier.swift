import Foundation
import RegularExpressions
import Logger

/**
 Encapsulates the various formats that Spotify
 uses to uniquely identify content. See [spotify uris and ids][1].

 You can pass an instance of this struct into any method
 that accepts a `SpotifyURIConvertible` type.

 This struct provides a convientent way to convert between
 the different formats, which include the id, the uri, and the url.

 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 */
public struct SpotifyIdentifier: Codable, Hashable, SpotifyURIConvertible {

    /// Creates a comma separated string (with no spaces) of ids from a
    /// sequence of uris. Throws an error if any of the ids could not
    /// be parsed from the uris (used in the query parameter of some
    /// requests).
    ///
    /// - Parameter uris: A sequence of Spotify URIs.
    static func commaSeparatedIdsString<S: Sequence>(
        _ uris: S
    ) throws -> String where S.Element == SpotifyURIConvertible {
        
        return try uris.map { uri in
            return try Self(uri: uri.uri).id
        }
        .joined(separator: ",")
    }
    
    
    /// The id for the Spotify content.
    public var id: String

    /// The id category for the Spotify content.
    public var idCategory: IDCategory

    /// The unique resource identifier for the
    /// Spotify content.
    @inlinable
    public var uri: String {
        "spotify:\(idCategory.rawValue):\(id.strip())"
    }

    /// Use this URL to open the content in the web player.
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
    /// See [spotify uris and ids][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public init(id: String, idCategory: IDCategory) {
        self.id = id.strip()
        self.idCategory = idCategory
    }

    /// Creates an instance from a URI. See [spotify uris and ids][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public init(
        uri: SpotifyURIConvertible
    ) throws {
        
        guard
            let captureGroups = try! uri.uri
                    .regexMatch("spotify:(.*):(.*)")?.groups,
            captureGroups.count == 2,
            let categoryString = captureGroups[0]?.match,
            let category = IDCategory(rawValue: categoryString),
            let id = captureGroups[1]?.match
        else {
            throw SpotifyLocalError.identifierParsingError(
                "could not parse spotify id and/or " +
                "id category from string: '\(uri)'"
            )
        }

        self.id = id.strip()
        self.idCategory = category

    }
    
    /// Creates an instance from a Spotify url to the content.
    public init(url: URL) throws {
        
        let paths = url.pathComponents
        
        guard
            paths.count >= 2,
            let category = IDCategory(rawValue: paths[2])
        else {
            throw SpotifyLocalError.identifierParsingError(
                "could not parse spotify id from url: '\(url)'"
            )
        }
        
        self.id = paths[1]
        self.idCategory = category
        
    }

}

