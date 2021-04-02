import Foundation

/// A namespace of images that can be used for
/// testing. They are stored in jpeg format.
public enum SpotifyExampleImages {
    
    /// A picture of Annabelle. 600 x 800; 121 KB of jpeg data.
    public static let annabelle: Data = {
        let url = Bundle.spotifyExampleContentModule.url(
            forResource: "Annabelle Compressed", withExtension: "jpeg"
        )!
        let data = try! Data(contentsOf: url)
        return data
    }()

}

