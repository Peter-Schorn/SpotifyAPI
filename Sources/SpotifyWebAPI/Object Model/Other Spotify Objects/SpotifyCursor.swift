import Foundation

/// Used to find the next or previous set of items
/// in a `CursorPagingObject`.
///
/// [1]:  https://developer.spotify.com/documentation/web-api/reference/object-model/#cursor-object
public struct SpotifyCursor: Codable, Hashable {
    
    /// The key to the item before the current item.
    public let before: String?
    
    /// The key to the item after the current item.
    public let after: String?
}
