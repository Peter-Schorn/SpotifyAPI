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
        throw SpotifyLocalError.other("unreachable")
    }

    init(service: String) {
        fatalError("not implemented")
    }

}


 /**
 A helper class that wraps around an instance of `SpotifyAPI`
 and provides convenience methods for authorizing your application.

 Its most important role is to handle changes to the authorzation
 information and save them to persistent storage in the keychain.
 */
final class Spotify: ObservableObject {

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

    /// The key in the keychain that is used to store the authorization
    /// information: "authorizationManager".
    static let authorizationManagerKey = "authorizationManager"

    /// The URL that Spotify will redirect to after the user either
    /// authorizes or denies authorization for your application.
    static let authRedirectURL = URL(string: "psspotifyapi://login")!

    /// A cryptographically-secure random string used to ensure
    /// than an incoming redirect from Spotify was the result of a request
    /// made by this app, and not an attacker. **This value should be regenerated**
    /// **after each authorization process completes.**
    var authorizationState = String.randomURLSafe(length: 32)

    /**
     Whether or not the application has been authorized. If `true`,
     then you can begin making requests to the Spotify web API
     using the `api` property of this class, which contains an instance
     of `SpotifyAPI`.

     This property provides a convenient way for the user interface
     to be updated based on whether the user has logged in with their
     Spotify account yet. For example, you could use this property disable
     UI elements that require the user to be logged in.

     This property is updated by `handleChangesToAuthorizationManager()`,
     which is called every time the authorization information changes,
     and `removeAuthorizationManagerFromKeychain()`, which is called
     every time `SpotifyAPI.authorizationManager.deauthorize()` is called.
     */
    @Published var isAuthorized = false

    /// The keychain to store the authorization information in.
    private let keychain = Keychain(service: "Peter-Schorn.SpotifyAPIApp")

    /// An instance of `SpotifyAPI` that you use to make requests to
    /// the Spotify web API.
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
            // We must receive on the main thread because we are
            // updating the @Published `isAuthorized` property.
            .receive(on: RunLoop.main)
            .sink(receiveValue: handleChangesToAuthorizationManager)
            .store(in: &cancellables)

        self.api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: removeAuthorizationManagerFromKeychain)
            .store(in: &cancellables)

        // Check to see if the authorization information is saved in
        // the keychain.
        if let authManagerData = keychain[data: Self.authorizationManagerKey] {
            do {
                // Try to decode the data.
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )

                /*
                 This assignment causes `authorizationManagerDidChange`
                 to emit a signal, meaning that
                 `handleChangesToAuthorizationManager()` will be called.

                 Note that if you had subscribed to
                 `authorizationManagerDidChange` after this line,
                 then `handleChangesToAuthorizationManager()` would not
                 have been called and the @Published `isAuthorized` property
                 would not have been properly updated.

                 We do not need to update `self.isAuthorized` here because that is
                 already handled in `handleChangesToAuthorizationManager()`.
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
     A convenience method that creates the authorization URL and opens it
     in the browser.

     You could also configure it to accept parameters for the authorization
     scopes
     */
    func authorize() {

        let authorizationURL = api.authorizationManager.makeAuthorizationURL(
            redirectURI: Self.authRedirectURL,
            showDialog: true,
            // This same value **MUST** be provided for the state parameter of
            // `authorizationManager.requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
            // Otherwise, an error will be thrown.
            state: self.authorizationState,
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
     For example, when the access token gets automatically refreshed, (it
     expires after an hour) this method will be called.

     It will also be called after the access and refresh tokens are retrieved
     using `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
     */
    func handleChangesToAuthorizationManager() {

        // Update the @Published `isAuthorized` property.
        self.isAuthorized = self.api.authorizationManager.isAuthorized()

        do {
            // Encode the authorization information to data.
            let authManagerData = try JSONEncoder().encode(api.authorizationManager)

            // Save the data to the keychain.
            keychain[data: Self.authorizationManagerKey] = authManagerData

        } catch {
            print(
                "couldn't encode authorizationManager for storage " +
                "in the keychain:\n\(error)"
            )
        }

    }

    /**
     Removes `api.authorizationManager` from the keychain.

     This method is called every time `api.authorizationManager.deauthorize`
     is called.
     */
    func removeAuthorizationManagerFromKeychain() {

        self.isAuthorized = false

        do {
            /*
             Remove the authorization information from the keychain.

             If you don't do this, then the authorization information
             that you just removed from memory by calling `deauthorize()`
             will be retrieved again from persistent storage after this
             app is quit and relaunched.
             */
            try keychain.remove(Self.authorizationManagerKey)
            print("did remove authorization manager from keychain")

        } catch {
            print(
                "couldn't remove authorization manager " +
                "from keychain: \(error)"
            )
        }
    }

}

#endif
