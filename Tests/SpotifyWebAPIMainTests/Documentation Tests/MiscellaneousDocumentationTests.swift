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
    let codeChallenge = codeVerifier.makeCodeChallenge()
    
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

private func testPlayOnNonActiveDeviceDocs(
    spotifyAPI: SpotifyAPI<AuthorizationCodeFlowManager>
) {
    
    var cancellables: Set<AnyCancellable> = []
    
    let track = "spotify:track:6FBPOJLxUZEair6x4kLDhf"
    let playbackRequest = PlaybackRequest(track)

    spotifyAPI.availableDevices()
        .flatMap { devices -> AnyPublisher<Void, Error> in
    
            let deviceId: String
            
            // If there is an actice device, then it's usually a good idea
            // to use that one.
            if let activeDeviceId = devices.first(where: { device in
                device.isActive && !device.isRestricted && device.id != nil
            })?.id {
                deviceId = activeDeviceId
            }
            // Else, just use the first device with a non-`nil` `id` and that
            // is not restricted. A restricted device will not accept any web
            // API commands.
            else if let nonActiveDeviceId = devices.first(where: { device in
                device.id != nil && !device.isRestricted
            })?.id {
                deviceId = nonActiveDeviceId
            }
            else {
                return SpotifyLocalError.other("no devices available")
                    .anyFailingPublisher()
            }
            
            return spotifyAPI.play(playbackRequest, deviceId: deviceId)
            
        }
        .sink(receiveCompletion: { completion in
            print("completion:", completion)
        })
        .store(in: &cancellables)

}
