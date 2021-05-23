#if canImport(Combine)
import Foundation
import Combine
import SpotifyWebAPI

 /// A stub for compilation tests.
private class Keychain {

    subscript(data key: String) -> Data? {
        get {
            fatalError("not implemented")
        }
        set {
            fatalError("not implemented")
        }
    }

    func remove(_ key: String) throws {
        throw SpotifyGeneralError.other("unreachable")
    }

    init(service: String) {
        fatalError("not implemented")
    }

}

/**
 A helper class that wraps around an instance of `SpotifyAPI` and provides
 convenience methods for authorizing your application.

 Its most important role is to handle changes to the authorization information
 and save them to persistent storage in the keychain.
 */
final class Spotify: ObservableObject {
    
    private static let clientId: String = {
        if let clientId = ProcessInfo.processInfo
            .environment["CLIENT_ID"] {
            return clientId
        }
        fatalError("Could not find 'CLIENT_ID' in environment variables")
    }()
    
    private static let clientSecret: String = {
        if let clientSecret = ProcessInfo.processInfo
            .environment["CLIENT_SECRET"] {
            return clientSecret
        }
        fatalError("Could not find 'CLIENT_SECRET' in environment variables")
    }()
    
    /// The key in the keychain that is used to store the authorization
    /// information: "authorizationManager".
    static let authorizationManagerKey = "authorizationManager"
    
    /// The URL that Spotify will redirect to after the user either authorizes
    /// or denies authorization for your application.
    static let loginCallbackURL = URL(
        string: "spotify-api-example-app://login-callback"
    )!
    
    /// A cryptographically-secure random string used to ensure than an incoming
    /// redirect from Spotify was the result of a request made by this app, and
    /// not an attacker. **This value should be regenerated** **after each
    /// authorization process completes.**
    var authorizationState = String.randomURLSafe(length: 128)
    
    /**
     Whether or not the application has been authorized. If `true`, then you can
     begin making requests to the Spotify web API using the `api` property of
     this class, which contains an instance of `SpotifyAPI`.

     This property provides a convenient way for the user interface to be
     updated based on whether the user has logged in with their Spotify account
     yet. For example, you could use this property disable UI elements that
     require the user to be logged in.

     This property is updated by `authorizationManagerDidChange()`, which is
     called every time the authorization information changes, and
     `authorizationManagerDidDeauthorize()`, which is called every time
     `SpotifyAPI.authorizationManager.deauthorize()` is called.
     */
    @Published var isAuthorized = false
    
    /// The keychain to store the authorization information in.
    private let keychain = Keychain(service: "com.Peter-Schorn.SpotifyAPIApp")
    
    /// An instance of `SpotifyAPI` that you use to make requests to the Spotify
    /// web API.
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: Spotify.clientId, clientSecret: Spotify.clientSecret
        )
    )
    
    var cancellables: [AnyCancellable] = []
    
    init() {
        
        // MARK: Important: Subscribe to `authorizationManagerDidChange` BEFORE
        // MARK: retrieving `authorizationManager` from persistent storage
        self.api.authorizationManagerDidChange
            // We must receive on the main thread because we are updating the
            // @Published `isAuthorized` property.
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        self.api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
        
        // Check to see if the authorization information is saved in the
        // keychain.
        if let authManagerData = keychain[data: Self.authorizationManagerKey] {
            do {
                // Try to decode the data.
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                
                /*
                 This assignment causes `authorizationManagerDidChange` to emit
                 a signal, meaning that `authorizationManagerDidChange()` will
                 be called.

                 Note that if you had subscribed to
                 `authorizationManagerDidChange` after this line, then
                 `authorizationManagerDidChange()` would not have been called
                 and the @Published `isAuthorized` property would not have been
                 properly updated.

                 We do not need to update `self.isAuthorized` here because that
                 is already handled in `authorizationManagerDidChange()`.
                 */
                self.api.authorizationManager = authorizationManager
                
            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        }
        else {
            print("did not find authorization information in keychain")
        }
        
    }
    
    /**
     A convenience method that creates the authorization URL and opens it in the
     browser.

     You could also configure it to accept parameters for the authorization
     scopes
     */
    func authorize() {
        
        let authorizationURL = api.authorizationManager.makeAuthorizationURL(
            redirectURI: Self.loginCallbackURL,
            showDialog: true,
            // This same value **MUST** be provided for the state parameter of
            // `authorizationManager.requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
            // Otherwise, an error will be thrown.
            state: self.authorizationState,
            scopes: [
                .userReadPlaybackState, .userReadEmail, .userLibraryModify
            ]
        )!
        
        // You can open the URL however you like. For example, you could open it
        // in a web view instead of the browser.
        // See https://developer.apple.com/documentation/webkit/wkwebview
        _ = authorizationURL
        // UIApplication.shared.open(authorizationURL)
        
    }
    
    /**
     Saves changes to `api.authorizationManager` to the keychain.

     This method is called every time the authorization information changes. For
     example, when the access token gets automatically refreshed, (it expires
     after an hour) this method will be called.

     It will also be called after the access and refresh tokens are retrieved
     using `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
     */
    func authorizationManagerDidChange() {
        
        // Update the @Published `isAuthorized` property.
        self.isAuthorized = self.api.authorizationManager.isAuthorized()
        
        do {
            // Encode the authorization information to data.
            let authManagerData = try JSONEncoder().encode(self.api.authorizationManager)
            
            // Save the data to the keychain.
            self.keychain[data: Self.authorizationManagerKey] = authManagerData
            
        } catch {
            print(
                "couldn't encode authorizationManager for storage in the " +
                "keychain:\n\(error)"
            )
        }
        
    }
    
    /**
     Removes `api.authorizationManager` from the keychain.
     
     This method is called every time `api.authorizationManager.deauthorize` is
     called.
     */
    func authorizationManagerDidDeauthorize() {
        
        self.isAuthorized = false
        
        do {
            /*
             Remove the authorization information from the keychain.

             If you don't do this, then the authorization information that you
             just removed from memory by calling `deauthorize()` will be
             retrieved again from persistent storage after this app is quit and
             relaunched.
             */
            try self.keychain.remove(Self.authorizationManagerKey)
            print("did remove authorization manager from keychain")
            
        } catch {
            print(
                "couldn't remove authorization manager from keychain: \(error)"
            )
        }
    }
    
}

#endif
