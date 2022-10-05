import Foundation

/// A Spotify followers object.
public struct Followers: Hashable {
    
    /**
     A link to the Spotify web API endpoint providing full details of the
     followers; `nil` if not available. **Please note that this will always**
     **be set to** `nil`, as the web API does not support it at the moment.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Followers``
     as the response type to retrieve the results.
     */
    public let href: URL?

    /// The total number of followers.
    public let total: Int
    
    /**
     Creates a Spotify followers object.
     
     - Parameters:
       - href: A link to the Spotify web API endpoint providing full details of
             the followers; `nil` if not available. **Please note that this**
             **will always be set to** `nil`, as the web API does not support it
             at the moment.
       - total: The total number of followers.
     */
    public init(
        href: URL? = nil,
        total: Int
    ) {
        self.href = href
        self.total = total
    }

}

extension Followers: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.href = try container.decodeIfPresent(URL.self, forKey: .href)
        let total = try container.decodeIfPresent(Int.self, forKey: .total)
        self.total = total ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.href, forKey: .href)
        try container.encode(self.total, forKey: .total)
    }
    
    enum CodingKeys: String, CodingKey {
        case href
        case total
    }

}
