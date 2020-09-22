import Foundation
import SpotifyWebAPI

public extension SearchResult {
    
    /// Sample data for testing purposes.
    static let queryCrumb = Bundle.module.decodeJson(
        forResource: "Search for 'Crumb' - SearchResult",
        type: Self.self
    )!

}
