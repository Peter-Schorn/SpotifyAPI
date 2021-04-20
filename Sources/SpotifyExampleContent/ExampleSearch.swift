import Foundation
import SpotifyWebAPI

public extension SearchResult {
    
    /// Sample data for testing purposes.
    static let queryCrumb = Bundle.module.decodeJSON(
        forResource: "Search for 'Crumb' - SearchResult",
        type: Self.self
    )!

}
