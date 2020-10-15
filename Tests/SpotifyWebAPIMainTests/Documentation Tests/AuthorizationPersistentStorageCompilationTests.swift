// import Foundation
// import Combine
// //import UIKit
// //import KeychainAccess
// import SpotifyWebAPI
//
// // These classes are not meant to be used. They exist to ensure that they compile.
// // For example, if a symbol was renamed, then this file would fail to compile,
// // serving as a warning that the documentation needs to be updated to reflect
// // the changes.
//
// /// A skeleton for compilation tests.
// private class Keychain {
//
//     subscript(data key: String) -> Data? {
//         get {
//             fatalError("not implemented")
//         }
//         set {
//             fatalError("not implemented")
//         }
//     }
//
//     init(service: String) {
//         fatalError("not implemented")
//     }
//
// }
//
//
// /**
//  Manages an instance of `SpotifyAPI` and provides convenience
//  methods for authorizing your application.
//
//  It also handles changes to the authorization manager and saves them to
//  persistent storage.
//
//  Conforms to the `ObservableObject` protocol, so you can use it in a SwiftUI
//  `View` to update the user interface.
//  */
// private class Spotify: ObservableObject {
//
//     private static let clientID: String = {
//         if let clientID = ProcessInfo.processInfo
//                 .environment["client_id"] {
//             return clientID
//         }
//         fatalError("Could not find 'client_id' in environment variables")
//     }()
//
//     private static let clientSecret: String = {
//         if let clientSecret = ProcessInfo.processInfo
//                 .environment["client_secret"] {
//             return clientSecret
//         }
//         fatalError("Could not find 'client_secret' in environment variables")
//     }()
//
//     /// The URL that Spotify will redirect to after the user either
//     /// authorizes or denies authorization for your application.
//     static let authRedirectURL = URL(string: "psspotifyapi://login")!
//
//     /// A cryptographically-secure random string.
//     static let authorizationState: String = {
//         var bytes = NSMutableData(length: 32)!
//         _ = SecRandomCopyBytes(
//             kSecRandomDefault,
//             bytes.length,
//             UnsafeMutableRawPointer(bytes.mutableBytes)
//         )
//         return bytes.base64EncodedString()
//     }()
//
//     /**
//      This property provides a convenient way for the user interface
//      to be updated based on whether the user has logged in with their
//      Spotify account yet.
//
//      For example, you could use this property disable UI elements that require
//      the user to be logged in.
//      */
//     @Published var isAuthorized = false
//
//     /// The keychain to store the authorization information in.
//     let keychain = Keychain(service: "Peter-Schorn.SpotifyAPIApp")
//
//     var cancellables: [AnyCancellable] = []
//
//     init() {
//
//         // MARK: Important: Subscribe to `authorizationManagerDidChange` BEFORE
//         // MARK: retrieving `authorizationManager` from persistent storage
//         self.api.authorizationManagerDidChange
//             // We must receive on the main thread because we are
//             // updating the @Published `isAuthorized` property.
//             .receive(on: RunLoop.main)
//             .sink(receiveValue: handleChangesToAuthorizationManager)
//             .store(in: &cancellables)
//
//         // Check to see if the authorization information is saved in
//         // the keychain.
//         if let authManagerData = keychain[data: "authorizationManager"] {
//             do {
//                 // Try to decode the data.
//                 let authorizationManager = try JSONDecoder().decode(
//                     AuthorizationCodeFlowManager.self,
//                     from: authManagerData
//                 )
//
//                 // This assignment triggers the didSet property observer
//                 // of `SpotifyAPI.authorizationManager`, which causes
//                 // `authorizationManagerDidChange` to emit a signal,
//                 // meaning that `handleChangesToAuthorizationManager will be
//                 // called. Note that if you had subscribed to
//                 // `authorizationManagerDidChange` after this line,
//                 // then `handleChangesToAuthorizationManager` would not
//                 // have been called and the `isAuthorized` publisher property
//                 // would not have been properly updated.
//                 self.api.authorizationManager = authorizationManager
//
//             } catch {
//                 print("could not decode authorizationManager from data:\n\(error)")
//             }
//         }
//
//     }
//
//     /// An instance of `SpotifyAPI` that you use to make requests to
//     /// the Spotify web API.
//     let api = SpotifyAPI(
//         authorizationManager: AuthorizationCodeFlowManager(
//             clientId: Spotify.clientID, clientSecret: Spotify.clientSecret
//         )
//     )
//
//     /// A convenience method that creates the authorization URL
//     /// and opens it in the browser. You could also configure it to accept
//     /// parameters for the authorization scopes.
//     func authorize() {
//
//         let url = api.authorizationManager.makeAuthorizationURL(
//             redirectURI: Self.authRedirectURL,
//             showDialog: true,
//             // This same value **MUST** be provided for the state parameter of
//             // `authorizationManager.requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
//             // Otherwise, an error will be thrown.
//             state: Self.authorizationState,
//             scopes: [
//                 .userReadPlaybackState, .userReadEmail, .userLibraryModify
//             ]
//         )!
//
//         _ = url
//         // You can open the URL however you like. For example, you could open
//         // it in a web view instead of the browser.
//         // See https://developer.apple.com/documentation/webkit/wkwebview
// //        UIApplication.shared.open(url)
//
//     }
//
//     /// Saves changes to `api.authorizationManager` to the keychain.
//     /// This method is called every time the authorization information changes.
//     func handleChangesToAuthorizationManager() {
//
//         // Update the @Published `isAuthorized` property.
//         self.isAuthorized = self.api.authorizationManager.isAuthorized()
//
//         do {
//             // Encode the authorization manager to data.
//             let authManagerData = try JSONEncoder().encode(api.authorizationManager)
//             // Save the data to the keychain.
//             keychain[data: "authorizationManager"] = authManagerData
//
//         } catch {
//             print("couldn't encode authorizationManager for storage:\n\(error)")
//         }
//
//     }
//
// }



import Foundation
import Combine
// import UIKit
// import KeychainAccess
import SpotifyWebAPI

/// A skeleton for compilation tests.
private class Keychain {

    subscript(data key: String) -> Data? {
        get {
            fatalError("not implemented")
        }
        set {
            fatalError("not implemented")
        }
    }

    init(service: String) {
        fatalError("not implemented")
    }

}

/**
 Manages an instance of `SpotifyAPI` and provides convenience
 methods for authorizing your application.
 
 It also handles changes to the authorization manager and saves them to
 persistent storage.
 
 Conforms to the `ObservableObject` protocol, so you can use it in a SwiftUI
 `View` to update the user interface.
 */
private final class Spotify: ObservableObject {
    
    private static let clientId: String = {
        if let clientId = ProcessInfo.processInfo
                .environment["client_id"] {
            return clientId
        }
        fatalError("Could not find 'client_id' in environment variables")
    }()
    
    private static let clientSecret: String = {
        if let clientSecret = ProcessInfo.processInfo
                .environment["client_secret"] {
            return clientSecret
        }
        fatalError("Could not find 'client_secret' in environment variables")
    }()
    
    /// The URL that Spotify will redirect to after the user either
    /// authorizes or denies authorization for your application.
    static let authRedirectURL = URL(string: "psspotifyapi://login")!
    
    /// A cryptographically-secure random string.
    static let authorizationState: String = {
        var bytes = NSMutableData(length: 32)!
        _ = SecRandomCopyBytes(
            kSecRandomDefault,
            bytes.length,
            UnsafeMutableRawPointer(bytes.mutableBytes)
        )
        return bytes.base64EncodedString()
    }()
    
    /**
     This property provides a convenient way for the user interface
     to be updated based on whether the user has logged in with their
     Spotify account yet.
     
     For example, you could use this property disable UI elements that require
     the user to be logged in.
     */
    @Published var isAuthorized = false

    /// The keychain to store the authorization information in.
    let keychain = Keychain(service: "Peter-Schorn.SpotifyAPIApp")
    
    var cancellables: [AnyCancellable] = []
    
    init() {
        
        // MARK: Important: Subscribe to `authorizationManagerDidChange` BEFORE
        // MARK: retrieving `authorizationManager` from persistent storage
        self.api.authorizationManagerDidChange
            // We must receive on the main thread because we are
            // updating the @Published `isAuthorized` property.
            .receive(on: RunLoop.main)
            .sink(receiveValue: handleChangesToAuthorizationManager)
            .store(in: &cancellables)
        
        // Check to see if the authorization information is saved in
        // the keychain.
        if let authManagerData = keychain[data: "authorizationManager"] {
            do {
                // Try to decode the data.
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                
                /*
                 This assignment causes `authorizationManagerDidChange`
                 to emit a signal, meaning that
                 `handleChangesToAuthorizationManager` will be called.

                 Note that if you had subscribed to
                 `authorizationManagerDidChange` after this line,
                 then `handleChangesToAuthorizationManager` would not
                 have been called and the @Published `isAuthorized` property
                 would not have been properly updated.
                 */
                self.api.authorizationManager = authorizationManager
                
            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        }
        
    }
    
    /// An instance of `SpotifyAPI` that you use to make requests to
    /// the Spotify web API.
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: Spotify.clientId, clientSecret: Spotify.clientSecret
        )
    )
    
    /**
     A convenience method that creates the authorization URL
     and opens it in the browser.
    
     You could also configure it to accept parameters for the
     authorization scopes.
     */
    func authorize() {

        let authorizationURL = api.authorizationManager.makeAuthorizationURL(
            redirectURI: Self.authRedirectURL,
            showDialog: true,
            // This same value **MUST** be provided for the state parameter of
            // `authorizationManager.requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
            // Otherwise, an error will be thrown.
            state: Self.authorizationState,
            scopes: [
                .userReadPlaybackState, .userReadEmail, .userLibraryModify
            ]
        )!
        
        _ = authorizationURL
        
        // You can open the URL however you like. For example, you could open
        // it in a web view instead of the browser.
        // See https://developer.apple.com/documentation/webkit/wkwebview
        // UIApplication.shared.open(authorizationURL)
        
    }
    
    /**
     Saves changes to `api.authorizationManager` to the keychain.
     
     This method is called every time the authorization information changes.
     For example, when the access token gets automatically refreshed,
     (it expires after an hour) this method will be called.
     */
    func handleChangesToAuthorizationManager() {
        
        // Update the @Published `isAuthorized` property.
        self.isAuthorized = self.api.authorizationManager.isAuthorized()
        
        do {
            // Encode the authorization manager to data.
            let authManagerData = try JSONEncoder().encode(api.authorizationManager)
            // Save the data to the keychain.
            keychain[data: "authorizationManager"] = authManagerData
            
        } catch {
            print("couldn't encode authorizationManager for storage:\n\(error)")
        }
        
    }
    
}

