import Foundation
import SpotifyWebAPI

private func testCodeVerifierCodeChallenge() {

    let codeVerifier = String.randomURLSafe(length: 128)
    let codeChallenge = codeVerifier.makeCodeChallenge()
    
    // suppress warnings.
    _ = codeVerifier
    _ = codeChallenge

}
