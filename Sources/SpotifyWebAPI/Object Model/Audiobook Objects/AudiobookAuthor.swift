import Foundation

/// An audiobook author or narrator.
public struct AudiobookAuthor: Hashable, Codable {
    
    /// The name of the author or narrator.
    public let name: String
    
    /// Creates an audiobook author or narrator.
    ///
    /// - Parameter name: The name of the author or narrator.
    public init(name: String) {
        self.name = name
    }

}
