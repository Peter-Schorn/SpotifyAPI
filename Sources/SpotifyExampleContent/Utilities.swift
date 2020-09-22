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
 
 static let <#name#> = Bundle.module.decodeJson(
     forResource: "<#name#>", type: Self.self
 )!
 
 static let <#name#> = Bundle.module.decodeJson(
     forResource: "<#name#>",
     type: Self.self
 )!
 
 */
