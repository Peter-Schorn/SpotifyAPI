import Foundation
import Combine
import Logging

extension SpotifyAPI {

    // MARK: Wrappers
    
    /*
     All requests to endpoints other than those for authorizing
     the app and retrieving/refreshing the tokens call through
     to these methods.
     */
    
    /**
     Refreshes the access token if it is expired and ensures that
     the application is authorized for the specified scopes.
     
     - Parameters:
       - scopes: A set of Spotify authorization scopes.
       - tolerance. The tolerance in seconds to use when determining if the
             access token is expired. The default is 120.
     - Throws: If the access token or refresh token is `nil` or a network
           error occurs.
     - Returns: The access token unwrapped from
           `self.authorizationManager.accessToken`. This is required
           in the header of requests to all endpoints.
     */
    func refreshTokensAndEnsureAuthorized(
        for scopes: Set<Scope>, tolerance: Double = 120
    ) -> AnyPublisher<String, Error> {
        
        self.logger.trace("scopes: \(scopes.map(\.rawValue))")
        
        /*
         It's more informative for the client to notifiy them that
         they haven't retrieved an access token for their application
         before throwing other errors, so that's why this check is
         performed first.

         Additionally, all other errors usually indicate a bug with
         this library.

         If an access token hasn't been retrieved, then a refresh
         token hasn't been retrieved either, and, without this check,
         `authorizationManager.refreshTokens` would throw an error
         indicating that a refresh token hasn't been retrieved,
         instead of an error indicating that an access token hasn't
         been retrieved. This would make it harder for the client to
         understand that they probably haven't authorized their
         application yet.
         */
        if self.authorizationManager.accessToken == nil {
            self.logger.warning("unauthorized: no access token")
            return SpotifyLocalError.unauthorized(
                "unauthorized: no access token"
            )
            .anyFailingPublisher()
        }
        
        return self.authorizationManager.refreshTokens(
            onlyIfExpired: true, tolerance: tolerance
        )
        .tryMap { () -> String in
            
            // Since we already checked to see if the access token was
            // `nil` above, it should never be `nil` at this point.
            guard let acccessToken = self.authorizationManager.accessToken else {
                self.logger.error(
                    "second check for accessToken failed"
                )
                throw SpotifyLocalError.unauthorized(
                    "unauthorized: no access token"
                )
            }
            
            guard self.authorizationManager.isAuthorized(
                for: scopes
            )
            else {
                throw SpotifyLocalError.insufficientScope(
                    requiredScopes: scopes,
                    authorizedScopes: self.authorizationManager.scopes ?? []
                )
            }

            if let expirationDate =
                    self.authorizationManager.expirationDate {
                assert(
                    expirationDate > Date(),
                    "access token was expired after just refreshing it:\n" +
                    "\(self.authorizationManager)"
                )
                    
            }
            else {
                assertionFailure(
                    "expiration date was nil after just refreshing the access token"
                )
            }
            
            return acccessToken
            
        }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Makes a request to the Spotify Web API. You should usually
     not need to call this method youself.
     All requests to endpoints other than those for authorizing
     the app and retrieving/refreshing the tokens call through
     to this method.
     
     **Note: There is an overload that accepts an instance of a**
     **type conforming to Encodable for the body parameter.**
     Only use this method if the body cannot be encoded to `Data`
     using a `JSONEncoder`.
     
     The access token will be refreshed automatically if needed
     before the request is made.
     
     If you are making a get request, use
     `self.getRequest(path:queryItems:requiredScopes:responseType:)`
     instead, which is a thin wrapper that calls though to this method.
     
     The base URL that the path and query items are appended to is
     ```
     "https://api.spotify.com/v1"
     ```
     
     A closure that accepts the access token must be used
     to make the headers because the access token will not
     be accessed until a call to `self.refreshAccessToken(onlyIfExpired: true)`
     is made. This method may return a new access token, which will then
     be used in the headers.
     
     - Parameters:
       - path: The path to the endpoint, which will be appended to the
             base URL above. Do **NOT** forget the leading forward-slash.
       - queryItems: The URL query items. Each value in the the dictionary
             that is NOT `nil` will be added to the query string.
       - httpMethod: The http method.
       - makeHeaders: A function that accepts an access token and
             returns a dictionary of headers. See the `Headers`
             enum, which contains convienence methods for making
             headers.
       - bodyData: The body of the request as `Data`.
       - requiredScopes: The scopes required for this endpoint.
     - Returns: The raw data and the URL response from the server.
     */
    func apiRequest(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        httpMethod: String,
        makeHeaders: @escaping (_ accessToken: String) -> [String: String],
        bodyData: Data?,
        requiredScopes: Set<Scope>
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        
        let endpoint = Endpoints.apiEndpoint(
            path, queryItems: queryItems
        )

        return refreshTokensAndEnsureAuthorized(for: requiredScopes)
            .flatMap { accessToken ->
                        AnyPublisher<(data: Data, response: URLResponse), Error> in
            
                if self.apiRequestLogger.logLevel <= .warning {
                
                    if let bodyData = bodyData {
                        if let bodyString = String(data: bodyData, encoding: .utf8) {
                            self.apiRequestLogger.trace(
                                """
                                \(httpMethod) request to "\(endpoint)"; request body:
                                \(bodyString)
                                """
                            )
                        }
                        else {
                            self.apiRequestLogger.warning(
                                """
                                \(httpMethod) request to "\(endpoint)"; \
                                couldn't convert body data to string
                                """
                            )
                        }
                    }
                    else {
                        self.apiRequestLogger.trace(
                            #"\#(httpMethod) request to "\#(endpoint)""#
                        )
                    }
                
                }
                
                return URLSession.shared.dataTaskPublisher(
                    url: endpoint,
                    httpMethod: httpMethod,
                    headers: makeHeaders(accessToken),
                    body: bodyData
                )
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            
            }
            .eraseToAnyPublisher()

    }
    
    /**
     Makes a request to the Spotify Web API. You should usually
     not need to call this method youself.
     All requests to endpoints other than those for authorizing
     the app and retrieving/refreshing the tokens call through
     to this method.
     
     The access token will be refreshed automatically if needed
     before the request is made.
     
     Use
     `apiRequest(path:queryItems:httpMethod:makeHeaders:bodyData:requiredScopes:)`
     if the body cannot be encoded into `Data` using a `JSONEncoder`.
     
     If you are making a get request, use
     `self.getRequest(path:queryItems:requiredScopes:responseType:)`
     instead, which is a thin wrapper that calls though to this method.
     
     The base URL that the path and query items are appended to is
     ```
     "https://api.spotify.com/v1"
     ```
     
     A closure that accepts the access token must be used to make the headers
     because the access token will not be accessed until a call to
     `self.refreshAccessToken(onlyIfExpired: true)` is made. This method may
     return a new access token, which will then be used in the headers.
    
     - Parameters:
       - path: The path to the endpoint, which will be appended to the
             base URL above. Do **NOT** forget the leading forward-slash.
       - queryItems: The URL query items. Each value in the the dictionary
             that is NOT `nil` will be added to the query string.
       - httpMethod: The http method.
       - makeHeaders: A function that accepts an access token and
             returns a dictionary of headers. See the `Headers`
             enum, which contains convienence methods for making
             headers.
       - body: The body of the request as a type that conforms to `Decodable`.
       - requiredScopes: The scopes required for this endpoint.
     - Returns: The raw data and the URL response from the server.
    */
    func apiRequest<Body: Encodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        httpMethod: String,
        makeHeaders: @escaping (_ accessToken: String) -> [String: String],
        body: Body?,
        requiredScopes: Set<Scope>
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        
        do {
            
            let encodedBody = try body.map {
                try JSONEncoder().encode($0)
            }
            
            return self.apiRequest(
                path: path,
                queryItems: queryItems,
                httpMethod: httpMethod,
                makeHeaders: makeHeaders,
                bodyData: encodedBody,
                requiredScopes: requiredScopes
            )
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    // MARK: - Get Request -
    
    /**
     Makes a get request to the Spotify web API.
     You should not normally need to call this method.
     Automatically refreshes the access token if necessary.
     
     The base URL that the path and query items are appended to is
     ```
     "https://api.spotify.com/v1"
     ```
     - Parameters:
       - path: The path to the endpoint, which will be appended to the
             base URL above.
       - queryItems: The URL query items. Each value in the the dictionary
             that is NOT `nil` will be added to the query string.
       - requiredScopes: The scopes required for this endpoint.
     - Returns: The raw data and the URL response from the server.
     */
    func getRequest(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        requiredScopes: Set<Scope>
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        
        return apiRequest(
            path: path,
            queryItems: queryItems,
            httpMethod: "GET",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil as Data?,
            requiredScopes: requiredScopes
        )
        
    }
    
}
