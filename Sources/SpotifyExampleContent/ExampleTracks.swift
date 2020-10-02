import Foundation
import SpotifyWebAPI

public extension Track {
    
    /// Sample data for testing purposes.
    static let because = Bundle.module.decodeJson(
        forResource: "Because - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let comeTogether = Bundle.module.decodeJson(
        forResource: "Come Together - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let faces = Bundle.module.decodeJson(
        forResource: "Faces - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let illWind = Bundle.module.decodeJson(
        forResource: "Ill Wind - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let odeToViceroy = Bundle.module.decodeJson(
        forResource: "Ode To Viceroy - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let reckoner = Bundle.module.decodeJson(
        forResource: "Reckoner - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let theEnd = Bundle.module.decodeJson(
        forResource: "The End - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let time = Bundle.module.decodeJson(
        forResource: "Time - Track", type: Self.self
    )!
    
}

public extension PagingObject where Item == Track {
    
    /// Sample data for testing purposes.
    /// All of the tracks from the album "Jinx" by Crumb.
    static let jinxTracks = Bundle.module.decodeJson(
        forResource: "Jinx - PagingObject<Track>", type: Self.self
    )!

}

