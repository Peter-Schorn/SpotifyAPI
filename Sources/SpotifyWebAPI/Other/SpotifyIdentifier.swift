import Foundation
import RegularExpressions
import Logging

/**
 Encapsulates the various formats that Spotify uses to uniquely identify content
 such as artists, tracks, and playlists.
 
 See [Spotify URIs and ids][1].

 You can pass an instance of this struct into any method that accepts a
 ``SpotifyURIConvertible`` type.

 This struct provides a convenient way to convert between the different formats,
 which include the id, the URI, and the URL.

 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 */
public struct SpotifyIdentifier: Codable, Hashable, SpotifyURIConvertible {

    /**
     Creates a comma separated string (with no spaces) of ids from a sequence of
     URIs (used in the query parameter of some requests).
    
     - Parameters:
       - uris: A sequence of Spotify URIs.
       - categories: If not `nil`, ensure the id categories of all the URIs
             match one or more categories. The default is `nil`.
     - Throws: If `categories` is not `nil` and the id category of a URI does
           not match one the required categories or if an id or id category
           could not be parsed from a URI.
     - Returns: A comma-separated string of Ids.
     */
    public static func commaSeparatedIdsString<S: Sequence>(
        _ uris: S,
        ensureCategoryMatches categories: [IDCategory]? = nil
    ) throws -> String where S.Element == SpotifyURIConvertible {
        
        return try Self.idsArray(
            uris,
            ensureCategoryMatches: categories
        )
        .joined(separator: ",")
        
    }
    
    /**
     Creates an array of Spotify ids from a sequence of URIs.
    
     - Parameters:
       - uris: A sequence of Spotify URIs.
       - categories: If not `nil`, ensure the id categories of all the URIs
             match one or more categories. The default is `nil`.
     - Throws: If `categories` is not `nil` and the id category of a URI does
           not match one the required categories or if an id or id category
           could not be parsed from a URI.
     - Returns: An array of Spotify ids.
     */
    public static func idsArray<S: Sequence>(
        _ uris: S,
        ensureCategoryMatches categories: [IDCategory]? = nil
    ) throws -> [String] where S.Element == SpotifyURIConvertible {
        
        let identifiers = try uris.map { uri in
            try Self(uri: uri)
        }
        let allIdCategories = identifiers.map(\.idCategory).removingDuplicates()
        
        if let categories = categories {
            if !allIdCategories.allSatisfy({ category in
                categories.contains(category)
            }) {
                throw SpotifyGeneralError.invalidIdCategory(
                    expected: categories, received: allIdCategories
                )
            }
        }
        
        return identifiers.map(\.id)

    }
    
    /// The id for the Spotify content.
    public let id: String

    /// The id category for the Spotify content.
    public let idCategory: IDCategory

    /**
     The unique resource identifier for the Spotify content.
     
     Equivalent to
     ```
     "spotify:\(idCategory.rawValue):\(id)"
     ```
     
     See [Spotify URIs and ids][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    @inlinable
    public var uri: String {
        "spotify:\(idCategory.rawValue):\(id)"
    }

    /**
     Use this URL to open the content in the web player.
     
     Equivalent to:
     ```
     "https://open.spotify.com/\(idCategory.rawValue)/\(id)"
     ```
     */
    public var url: URL? {
        let idCategory: IDCategory
        switch self.idCategory {
            case .audiobook:
                idCategory = .show
            case .chapter:
                idCategory = .episode
            case let category:
                idCategory = category
        }
        return URL(
            scheme: "https",
            host: "open.spotify.com",
            path: "/\(idCategory.rawValue)/\(id)"
        )
    }

    // MARK: Initializers
    
    /**
     Creates an instance from an id and an id category.
     
     See [Spotify URIs and ids][1].
    
     The id category must be one of the following:
     
     * ``IDCategory/artist``
     * ``IDCategory/album``
     * ``IDCategory/track``
     * ``IDCategory/playlist``
     * ``IDCategory/show``
     * ``IDCategory/episode``
     * ``IDCategory/local``
     * ``IDCategory/user``
     * ``IDCategory/genre``
     * ``IDCategory/ad``
     * ``IDCategory/unknown``
     * ``IDCategory/collection``
     
     - Parameters:
       - id: A Spotify id.
       - idCategory: An id category.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public init(id: String, idCategory: IDCategory) {
        self.id = id.strip()
        self.idCategory = idCategory
    }

    /**
     Creates an instance from a URI.
     
     See [Spotify URIs and ids][1].
    
     Uses the following [regular expression][2] to parse the id and id
     categories, *in that order*:
     ```
     "spotify:([a-zA-Z]+):([0-9a-zA-Z]+)"
     ```
     
     The id category must be one of the following, or an error will be thrown:
     
     * ``IDCategory/artist``
     * ``IDCategory/album``
     * ``IDCategory/track``
     * ``IDCategory/playlist``
     * ``IDCategory/show``
     * ``IDCategory/episode``
     * ``IDCategory/local``
     * ``IDCategory/user``
     * ``IDCategory/genre``
     * ``IDCategory/ad``
     * ``IDCategory/unknown``
     * ``IDCategory/collection``
     
     - Parameters:
       - uri: A Spotify URI.
       - categories: If not `nil`, throw an error if the id category of the URI
         does not match one of these id categories. See ``IDCategory`` for more
         information. The default is `nil`.
     - Throws: If `categories` is not `nil` and the id category of the URI
           does not match one the required categories or if an id or id category
           could not be parsed from the URI.
    
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [2]: https://regex101.com/r/P8j2R3/1
     */
    public init(
        uri: SpotifyURIConvertible,
        ensureCategoryMatches categories: [IDCategory]? = nil
    ) throws {
        
        let pattern = "spotify:([a-zA-Z]+):([0-9a-zA-Z]+)"
        
        let errorMessage: String
        parseURI: do {
            
            guard uri.uri.starts(with: "spotify:") else {
                errorMessage = ": URI must start with 'spotify:'"
                break parseURI
            }
            
            guard
                let captureGroups = try! uri.uri.regexMatch(pattern)?.groups,
                captureGroups.count >= 2,
                let idCategoryString = captureGroups[0]?.match,
                let id = captureGroups[1]?.match
            else {
                errorMessage = ""
                break parseURI
            }
            
            guard let idCategory = IDCategory(rawValue: idCategoryString) else {
                errorMessage = """
                    : id category must be one of the following: \
                    \(IDCategory.allCases.map(\.rawValue)), \
                    but received '\(idCategoryString)'
                    """
                break parseURI
            }
            
            if let categories = categories,
                    !categories.contains(idCategory) {
                throw SpotifyGeneralError.invalidIdCategory(
                    expected: categories, received: [idCategory]
                )
            }
            
            self.id = id
            self.idCategory = idCategory
            return

        }
       
        throw SpotifyGeneralError.identifierParsingError(
            message: "could not parse Spotify id and/or " +
                     "id category from string: '\(uri)'" + errorMessage
        )

    }
    
    /**
     Creates an instance from a Spotify URL to the content.
     
     See [Spotify URIs and ids][1].
    
     The first path component must be the id category. The second path component
     must be the id of the content. All additional path components and/or query
     parameters, if present, are ignored.
     
     For example:
     ```
     "https://open.spotify.com/playlist/33yLOStnp2emkEA76ew1Dz"
     ```

     The id category must be one of the following:

     * ``IDCategory/artist``
     * ``IDCategory/album``
     * ``IDCategory/track``
     * ``IDCategory/playlist``
     * ``IDCategory/show``
     * ``IDCategory/episode``
     * ``IDCategory/local``
     * ``IDCategory/user``
     * ``IDCategory/genre``
     * ``IDCategory/ad``
     * ``IDCategory/unknown``
     * ``IDCategory/collection``
     
     - Parameter url: A URL that, when opened, displays the content in the web
           player.
     - Throws: If the id and/or id category of the content could not be parsed
           from the URL.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public init(url: URL) throws {

        // If the URL contains at least one "/" after the host component,
        // then the first path component in the array will actually be a
        // single "/", so the id category will actually be at index 1, and
        // the id will be at index 2.
        let pathComponents = url.pathComponents
        
        let errorMessage: String
        parseURL: do {
            
            guard pathComponents.count >= 3 else {
                errorMessage = "expected at least two path components " +
                    "but received \(max(pathComponents.count - 1, 0))"
                break parseURL
            }
            guard let idCategory = IDCategory(rawValue: pathComponents[1]) else {
                errorMessage = """
                    id category must be one of the following: \
                    \(IDCategory.allCases.map(\.rawValue)), \
                    but received '\(pathComponents[1])'
                    """
                break parseURL
            }
            self.idCategory = idCategory
            self.id = pathComponents[2]
            return
            
        }
        
        throw SpotifyGeneralError.identifierParsingError(
            message: "could not parse Spotify id category and/or id " +
                     "from url: '\(url)': \(errorMessage)"
        )
        
    }

}

