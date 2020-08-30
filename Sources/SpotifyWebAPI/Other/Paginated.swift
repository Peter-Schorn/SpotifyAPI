import Foundation

/// A type that contains paginated results.
public protocol Paginated: Codable {

    /// A link to the next page of results.
    var next: String? { get }
    
}
 
