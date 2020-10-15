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
    
    case album
    case single
    case appearsOn = "appears_on"
    case compilation
    
}

/// This type has ben renamed to `AlbumType`.
@available(*, deprecated, renamed: "AlbumType")
public typealias AlbumGroup = AlbumType
