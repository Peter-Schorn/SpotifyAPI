import Foundation

/**
 An album group.
 
 One of the following:
 
 * `album`
 * `single`
 * `appearsOn`
 * `compilation`
 
 */
public enum AlbumGroup: String, CaseIterable, Codable, Hashable {
    
    case album
    case single
    case appearsOn = "appears_on"
    case compilation
    
}
