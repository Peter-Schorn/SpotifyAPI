import Foundation
import SpotifyWebAPI

extension Bundle {
   
    func decodeJson<T: Decodable>(
        forResource name: String,
        extension: String = "json",
        type: T.Type
    ) -> T? {
       
        guard let url = Bundle.module.url(
            forResource: name, withExtension: `extension`
        ) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(type.self, from: data)

    }

}


public extension Track {
    
    static let illWind = Bundle.module.decodeJson(
        forResource: "Ill Wind_Track", type: Self.self
    )!
    
}

public extension Album {
    
    static let jinx = Bundle.module.decodeJson(
        forResource: "Jinx_Album", type: Self.self
    )!

}
