import Foundation
import SpotifyWebAPI
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

private extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    /**
     Makes a call to `availableDevices()` and plays the content on the
     active device if one exists. Else, plays content on the first available
     device.
     
     - Parameter playbackRequest: A request to play content.
     */
    func getAvailableDeviceThenPlay(
        _ playbackRequest: PlaybackRequest
    ) -> AnyPublisher<Void, Error> {
        
        return self.availableDevices().flatMap {
            devices -> AnyPublisher<Void, Error> in
    
            // A device must have an id and must not be restricted
            // in order to accept web API commands.
            let usableDevices = devices.filter { device in
                !device.isRestricted && device.id != nil
            }

            // If there is an active device, then it's usually a good idea
            // to use that one. For example, if content is already playing,
            // then it will be playing on the active device. If not, then
            // just use the first available device.
            let device = usableDevices.first(where: \.isActive)
                    ?? usableDevices.first
            
            if let deviceId = device?.id {
                return self.play(playbackRequest, deviceId: deviceId)
            }
            else {
                return SpotifyGeneralError.other(
                    "no active or available devices",
                    localizedDescription:
                    "There are no devices available to play content on. " +
                    "Try opening the Spotify app on one of your devices."
                )
                .anyFailingPublisher()
            }
            
        }
        .eraseToAnyPublisher()
        
    }

}
