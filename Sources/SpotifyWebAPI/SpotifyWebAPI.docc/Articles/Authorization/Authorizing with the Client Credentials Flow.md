# Authorizing with the Client Credentials Flow

Use this method if you do NOT need to access/modify user data. In other words, you cannot access endpoints that require authorization scopes or an access token that was issued on behalf of a user. The advantage of this method is that it does not require any user interaction.  

## Authorization

Create an instance of ``SpotifyAPI`` and assign an instance of ``ClientCredentialsFlowManager`` to the ``SpotifyAPI/authorizationManager`` property:
```swift
import SpotifyWebAPI

let spotify = SpotifyAPI(
    authorizationManager: ClientCredentialsFlowManager(
        clientId: "Your Client Id", clientSecret: "Your Client Secret"
    )
)
```

To authorize your application, call ``ClientCredentialsFlowBackendManager/authorize()``:
```swift
spotify.authorizationManager.authorize()
    .sink(receiveCompletion: { completion in
        switch completion {
            case .finished:
                print("successfully authorized application")
            case .failure(let error):
                print("could not authorize application: \(error)")
        }
    })
    .store(in: &cancellables)
```

Once this publisher completes successfully, your application is authorized and you may begin making requests to the Spotify web API. The access token will be refreshed automatically when necessary. For example:
```swift
spotify.search(query: "Pink Floyd", categories: [.track])
    .sink(
        receiveCompletion: { completion in
            print(completion)
        },
        receiveValue: { results in
            print(results)
        }
    )
    .store(in: &cancellables)
```

This authorization process is implemented in this [example command-line app][3]. Read more at the [Spotify web API reference][2].

[1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
[2]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
[3]: https://github.com/Peter-Schorn/SpotifyAPIExamples
[4]: https://developer.spotify.com/documentation/web-api/reference/
