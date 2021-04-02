import Foundation
import SpotifyWebAPI

// Workaround for https://developer.apple.com/forums/thread/664295
private class SpotifyExampleContentCurrentBundleFinder {}

extension Bundle {

    func decodeJson<T: Decodable>(
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

    static var spotifyExampleContentModule: Bundle = {
        /* The name of your local package, prepended by "LocalPackages_" for iOS and "PackageName_" for macOS. You may have same PackageName and TargetName*/
        let bundleNameIOS = "LocalPackages_SpotifyExampleContent"
        let bundleNameMacOs = "PackageName_SpotifyExampleContent"
        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,
            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: SpotifyExampleContentCurrentBundleFinder.self).resourceURL,
            /* For command-line tools. */
            Bundle.main.bundleURL,
            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: SpotifyExampleContentCurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
            Bundle(for: SpotifyExampleContentCurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
        ]
        
        for candidate in candidates {
            let bundlePathiOS = candidate?.appendingPathComponent(bundleNameIOS + ".bundle")
            let bundlePathMacOS = candidate?.appendingPathComponent(bundleNameMacOs + ".bundle")
            if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
                return bundle
            } else if let bundle = bundlePathMacOS.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle")
    }()

}


/*
 
 Templates:
 
 static let <#name#> = Bundle.spotifyExampleContentModule.decodeJson(
     forResource: "<#name#>", type: Self.self
 )!
 
 static let <#name#> = Bundle.spotifyExampleContentModule.decodeJson(
     forResource: "<#name#>",
     type: Self.self
 )!
 
 */
