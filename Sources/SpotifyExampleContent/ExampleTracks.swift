import Foundation
import SpotifyWebAPI

public extension Track {
    
    /// Sample data for testing purposes.
    static let because = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Because - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let comeTogether = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Come Together - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let faces = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Faces - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let illWind = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Ill Wind - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let odeToViceroy = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Ode To Viceroy - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let reckoner = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Reckoner - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let theEnd = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "The End - Track", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let time = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Time - Track", type: Self.self
    )!
    
}

public extension PagingObject where Item == Track {
    
    /// Sample data for testing purposes.
    /// All of the tracks from the album "Jinx" by Crumb.
    static let jinxTracks = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Jinx - PagingObject<Track>", type: Self.self
    )!

}

