import Foundation

/// A namespace of images that can be used for testing. They are stored in jpeg
/// format.
public enum SpotifyExampleImages {
    
    /// A picture of Annabelle. 600 x 800; 121 KB of JPEG data.
    public static let annabelle = Bundle.module.decodeJPEGImage(
        forResource: "Annabelle Compressed"
    )!

    /**
     A picture of Annabelle. 4032 x 3024; 2.4 MB of JPEG data.
     
     Exceeds the size limit (256 KB) of the endpoint for uploading an image to a
     playlist.
     */
    public static let annabelleTooLarge = Bundle.module.decodeJPEGImage(
        forResource: "Annabelle Large"
    )!
    
}


private extension Bundle {
    
    func decodeJPEGImage(forResource name: String) -> Data? {
        guard let url = Bundle.module.url(
            forResource: name, withExtension: "jpeg"
        ) else {
            return nil
        }
        let data = try? Data(contentsOf: url)
        return data
    }

}
