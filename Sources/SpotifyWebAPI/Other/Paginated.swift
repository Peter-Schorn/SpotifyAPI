import Foundation

/**
 A type that contains paginated results.

 The only requirement is
 ```
 var next: URL? { get }
 ```
  a link (href) to the next page of results.

 ``PagingObject`` and ``CursorPagingObject`` are conforming types.

 Conforming types can be used in ``SpotifyAPI/extendPages(_:maxExtraPages:)``,
 ``SpotifyAPI/extendPagesConcurrently(_:maxExtraPages:)``, and the combine
 operators of the same names to retrieve additional pages of results.
 */
public protocol Paginated: Codable {

    /// A link (href) to the next page of results.
    var next: URL? { get }
    
}
