import Foundation
import SpotifyWebAPI

extension Bundle {
   
    func decodeJSON<T: Decodable>(
        forResource name: String,
        extension: String = "json",
        type: T.Type
    ) -> T? {
       
        guard let url = self.url(
            forResource: name, withExtension: `extension`
        ) else {
            print("couldn't find resource '\(name)'")
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            print("couldn't get data for '\(name)'")
            return nil
        }
        do {
            return try JSONDecoder().decode(type.self, from: data)
        
        } catch {
            
            let error = SpotifyDecodingError(
                url: nil,
                rawData: data,
                responseType: type.self,
                statusCode: nil,
                underlyingError: error
            )

            print("couldn't decode '\(name)' into '\(type)':\n\(error)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("raw data:\n" + dataString)
            }
            else {
                print("couldn't convert data to string")
            }
            return nil
        }
        
    }

}


/*
 
 Templates:
 
 /// Sample data for testing purposes.
 static let <#name#> = Bundle.module.decodeJSON(
     forResource: "<#name#>", type: Self.self
 )!
 
 /// Sample data for testing purposes.
 static let <#name#> = Bundle.module.decodeJSON(
     forResource: "<#name#>",
     type: Self.self
 )!
 
 */
