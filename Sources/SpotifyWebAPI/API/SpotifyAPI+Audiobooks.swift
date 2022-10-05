import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {
    
    // MARK: Audiobooks
    
    /**
     Get an audiobook.
     
     - Note: Audiobooks are only available for the US market.
     
     See also:
     
     * ``audiobooks(_:market:)`` - gets multiple audiobooks

     Reading the user’s resume points on audiobook chapter objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - uri: The URI of an audiobook.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, the audiobook will
             only be returned if it is available in that market. If the access
             token was granted on behalf of a user (i.e., if you authorized your
             application using the authorization code flow or the authorization
             code flow with proof key for code exchange), the country associated
             with the user account will take priority over this parameter. Users
             can view the country that is associated with their account in the
             [account settings][3].
     - Returns: The full version of an audiobook object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-audiobook
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func audiobook(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Audiobook, Error> {
        
        do {
            
            let id = try SpotifyIdentifier(
                uri: uri,
                ensureCategoryMatches: [.audiobook, .show]
            ).id
            
            return self.getRequest(
                path: "/audiobooks/\(id)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(Audiobook.self)
            

        } catch {
            return error.anyFailingPublisher()
        }

    }

    /**
     Get multiple audiobooks.
     
     - Note: Audiobooks are only available for the US market.
     
     See also:
     
     * ``audiobook(_:market:)`` - gets a single audiobook

     Reading the user’s resume points on audiobook chapter objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - uris: An array of audiobook URIs. Maximum: 50. Passing in an empty
             array will immediately cause an empty array of results to be
             returned without a network request being made.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, the audiobook will
             only be returned if it is available in that market. If the access
             token was granted on behalf of a user (i.e., if you authorized your
             application using the authorization code flow or the authorization
             code flow with proof key for code exchange), the country associated
             with the user account will take priority over this parameter. Users
             can view the country that is associated with their account in the
             [account settings][3].
     - Returns: Up to 50 audiobook objects. Audiobooks are returned in the order
           requested. Duplicate URIs in the request will result in duplicate
           audiobooks in the response. If a URI is invalid, the corresponding
           audiobook will be *omitted* from the response, thereby shifting the
           positions of all of the other audiobooks.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-multiple-audiobooks
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func audiobooks(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Audiobook?], Error> {
        
        do {
            
            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris,
                    ensureCategoryMatches: [.audiobook, .show]
                )
            
            return self.getRequest(
                path: "/audiobooks",
                queryItems: [
                    "ids": idsString,
                    "market": market
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Audiobook?]].self)
            .tryMap { dict -> [Audiobook?] in
                if let audiobooks = dict["audiobooks"] {
                    return audiobooks
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "audiobooks", dict: dict
                )
            }
            .eraseToAnyPublisher()
            

        } catch {
            return error.anyFailingPublisher()
        }

    }
    
    /**
     Get an audiobook chapter.

     - Warning: Currently, there is a bug in the web API in which the market
            parameter must be provided, or a 500 server error will be returned.
            It must be set to "US".
     
     - Note: Audiobooks are only available for the US market.
     
     See also:
     
     ``chapters(_:market:)`` - gets multiple audiobook chapters
     
     Reading the user’s resume points on audiobook chapter objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI of an audiobook chapter.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, the audiobook chapter
             will only be returned if it is available in that market. If the
             access token was granted on behalf of a user (i.e., if you
             authorized your application using the authorization code flow or
             the authorization code flow with proof key for code exchange), the
             country associated with the user account will take priority over
             this parameter. Users can view the country that is associated with
             their account in the [account settings][3].
     - Returns: The full version of an audiobook chapter object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-a-chapter
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func chapter(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<AudiobookChapter, Error> {
        
        do {
            
            let id = try SpotifyIdentifier(
                uri: uri,
                ensureCategoryMatches: [.chapter, .episode]
            ).id
            
            return self.getRequest(
                path: "/chapters/\(id)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(AudiobookChapter.self)
            

        } catch {
            return error.anyFailingPublisher()
        }

    }
    
    /**
     Get multiple audiobook chapters.
     
     - Warning: Currently, there is a bug in the web API in which the market
           parameter must be provided, or a 500 server error will be returned.
           It must be set to "US".
     
     - Note: Audiobooks are only available for the US market.
     
     See also:
     
     ``chapter(_:market:)`` - gets a single chapter
     
     Reading the user’s resume points on audiobook chapter objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uris: An array of audiobook chapter URIs. Maximum: 50. Passing in an
             empty array will immediately cause an empty array of results to be
             returned without a network request being made.
        - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, the audiobook chapter
             will only be returned if it is available in that market. If the
             access token was granted on behalf of a user (i.e., if you
             authorized your application using the authorization code flow or
             the authorization code flow with proof key for code exchange), the
             country associated with the user account will take priority over
             this parameter. Users can view the country that is associated with
             their account in the [account settings][3].
     - Returns:  Up to 50 audiobook chapter objects. Chapters are returned in
           the order requested. Duplicate URIs in the request will result in
           duplicate chapters in the response. If a URI is invalid, the
           corresponding chapter will be *omitted* from the response, thereby
           shifting the positions of all of the other chapters.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-several-chapters
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func chapters(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[AudiobookChapter?], Error> {
        
        do {
            
            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris,
                    ensureCategoryMatches: [.chapter, .episode]
                )
            
            return self.getRequest(
                path: "/chapters",
                queryItems: [
                    "ids": idsString,
                    "market": market
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [AudiobookChapter?]].self)
            .tryMap { dict -> [AudiobookChapter?] in
                if let chapters = dict["chapters"] {
                    return chapters
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "chapters", dict: dict
                )
            }
            .eraseToAnyPublisher()
            

        } catch {
            return error.anyFailingPublisher()
        }

    }

}
