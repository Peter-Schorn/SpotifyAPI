import Foundation
import SpotifyWebAPI

public extension Track {
    
    /// Sample data for testing purposes.
    static let because = Bundle.module.decodeJSON(
        forResource: "Because - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let comeTogether = Bundle.module.decodeJSON(
        forResource: "Come Together - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let faces = Bundle.module.decodeJSON(
        forResource: "Faces - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let illWind = Bundle.module.decodeJSON(
        forResource: "Ill Wind - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let odeToViceroy = Bundle.module.decodeJSON(
        forResource: "Ode To Viceroy - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let reckoner = Bundle.module.decodeJSON(
        forResource: "Reckoner - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let theEnd = Bundle.module.decodeJSON(
        forResource: "The End - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let time = Bundle.module.decodeJSON(
        forResource: "Time - Track", type: Self.self
    )!
    
}

public extension PagingObject where Item == Track {
    
    /// Sample data for testing purposes.
    /// All of the tracks from the album "Jinx" by Crumb.
    static let jinxTracks = Bundle.module.decodeJSON(
        forResource: "Jinx - PagingObject<Track>", type: Self.self
    )!

}

