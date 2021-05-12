import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI

// These methods exist to ensure that they compile.
// They are not meant to be called.

private func testCodeVerifierCodeChallenge() {

    let codeVerifier = String.randomURLSafe(length: 128)
    let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
    
    // suppress warnings.
    _ = codeVerifier
    _ = codeChallenge

}


#if canImport(UIKit)
import UIKit

private func uploadPlaylistImageDocsTest(
    uiImage: UIImage, spotify: SpotifyAPI<AuthorizationCodeFlowManager>
) {
    
    let jpegData = uiImage.jpegData(
        compressionQuality: 0.5
    )!
    let base64EncodedData = jpegData.base64EncodedData()
    
    _ = spotify.uploadPlaylistImage("", imageData: base64EncodedData)

}

#endif
