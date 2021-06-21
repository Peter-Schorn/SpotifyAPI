import Foundation

/// An album type.
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
     
     - Parameter rawValue: The raw value for an album type. **It is**
           **case-insensitive**.
     */
    @inlinable
    public init?(rawValue: String) {
        
        let lowercasedRawValue = rawValue.lowercased()
        for category in Self.allCases {
            if category.rawValue == lowercasedRawValue {
                self = category
                return
            }
        }
        return nil
       
    }
    
}
