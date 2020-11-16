import Foundation

/**
 An album type.
 
 One of the following:
 
 * `album`
 * `single`
 * `appearsOn`
 * `compilation`
 
 */
public enum AlbumType: String, CaseIterable, Codable, Hashable {
    
    /// An album.
    case album
    
    /// A single.
    case single
    
    /// Appears on.
    case appearsOn = "appears_on"
    
    /// A compilation.
    case compilation
    
    /**
     Creates a new instance with the specified raw value.
     
     - Parameter rawValue: The raw value for an album type.
           **It is case-insensitive**.
     */
    @inlinable
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
            case "album":
                self = .album
            case "single":
                self = .single
            case "appears_on":
                self = .appearsOn
            case "compilation":
                self = .compilation
            default:
                return nil
        }
    }
    
}

/// This type has ben renamed to `AlbumType`.
/// :nodoc:
@available(*, deprecated, renamed: "AlbumType")
public typealias AlbumGroup = AlbumType
