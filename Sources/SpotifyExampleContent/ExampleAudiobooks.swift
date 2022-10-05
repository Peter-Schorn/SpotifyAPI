import Foundation
import SpotifyWebAPI

public extension Audiobook {
    
    /// Sample data for testing purposes.
    static let harryPotterAndTheSorcerersStone = Bundle.module.decodeJSON(
        forResource: "Harry Potter and the Sorcerer's Stone - Audiobook",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let enlightenmentNow = Bundle.module.decodeJSON(
        forResource: "Enlightenment Now - Audiobook",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let freeWill = Bundle.module.decodeJSON(
        forResource: "Free Will - Audiobook",
        type: Self.self
    )!

}

public extension AudiobookChapter {
    
    /// Sample data for testing purposes.
    static let freeWillChapter1 = Bundle.module.decodeJSON(
        forResource: "Free Will Chapter 1 - AudiobookChapter",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let steveJobsChapter1 = Bundle.module.decodeJSON(
        forResource: "Steve Jobs Chapter 1 - AudiobookChapter",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let enlightenmentNowChapter3 = Bundle.module.decodeJSON(
        forResource: "Enlightenment Now Chapter 3 - AudiobookChapter",
        type: Self.self
    )!

}
