import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIFollowTests: SpotifyAPITests { }

extension SpotifyAPIFollowTests {

    func usersFollowPlaylist() {

        let userURIs = URIs.Users.array(.april, .peter)

        let expectation = XCTestExpectation(
            description: "testUsersFollowPlaylist"
        )

        Self.spotify.usersFollowPlaylist(
            URIs.Playlists.index,
            userURIs: userURIs
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { results in
                XCTAssertEqual(results, [false, true])
            }
        )
        .store(in: &Self.cancellables)

        let emptyExpectation = XCTestExpectation(
            description: "testUsersFollowPlaylist empty"
        )

        var receivedValueFromEmpty = false

        Self.spotify.usersFollowPlaylist(
            URIs.Playlists.crumb,
            userURIs: []
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in emptyExpectation.fulfill() },
            receiveValue: { results in
                XCTAssertEqual(results, [])
                receivedValueFromEmpty = true
            }
        )
        .store(in: &Self.cancellables)

        self.wait(for: [expectation, emptyExpectation], timeout: 120)
        XCTAssertTrue(receivedValueFromEmpty)

    }

}

extension SpotifyAPIFollowTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{

    func followedArtists() {
        
        DistributedLock.follow.lock()
        defer {
            DistributedLock.follow.unlock()
        }
        
        let expectation = XCTestExpectation(
            description: "followedArtists"
        )
        
        // Will contain at most 50 artists. The user may actually
        // be following more artists.
        var allFollowedArtists: [Artist] = []

        Self.spotify.currentUserFollowedArtists(
            limit: 50
        )
        .XCTAssertNoFailure()
        .flatMap { arists -> AnyPublisher<CursorPagingObject<Artist>, Error> in
            allFollowedArtists = arists.items
            guard allFollowedArtists.count >= 3 else {
                return XCTSkip(
                    "test requires the user to follow at least 3 artists"
                )
                .anyFailingPublisher()
            }
            let artistURIs = allFollowedArtists.map(\.uri)
            let thirdFromLastArtist = artistURIs[
                allFollowedArtists.count - 3
            ]
            XCTAssertNotNil(thirdFromLastArtist)
            return Self.spotify.currentUserFollowedArtists(
                after: thirdFromLastArtist
            )
        }
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { artistsPagingObject in
                let artists = artistsPagingObject.items
                guard artists.count >= 2 else {
                    XCTFail(
                        "should receive at least two artists: \(artists.count)"
                    )
                    return
                }
                let count = allFollowedArtists.count
                XCTAssertEqual(
                    artists[0].uri,
                    allFollowedArtists[count - 2].uri
                )
                XCTAssertEqual(
                    artists[1].uri,
                    allFollowedArtists[count - 1].uri
                )
                
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func followedArtistsPages() {
        
        DistributedLock.follow.lock()
        defer {
            DistributedLock.follow.unlock()
        }
        
        let expectation = XCTestExpectation(
            description: "followedArtistsPages"
        )

        Self.spotify.currentUserFollowedArtists(
            limit: 5
        )
        .XCTAssertNoFailure()
        .extendPages(Self.spotify)
        .XCTAssertNoFailure()
        .map { page -> CursorPagingObject<Artist> in
            print("received page: \(page)")
            return page
        }
        .collect()
        .sink(
            receiveCompletion: { completion in
                print("followedArtistsPages completion: \(completion)")
                expectation.fulfill()
            },
            receiveValue: { artists in
                for artist in artists {
                    print(artist)
                }
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func followArtists() {

        DistributedLock.follow.lock()
        defer {
            DistributedLock.follow.unlock()
        }

        let expectation = XCTestExpectation(
            description: "testFollowArtists"
        )

        let fullArtists = URIs.Artists.array(
            .mildHighClub, .aTribeCalledQuest, .skinshape, .stevieRayVaughan
        )

        let partialArtists = URIs.Artists.array(
            .mildHighClub, .aTribeCalledQuest
        )

        Self.spotify.unfollowArtistsForCurrentUser(fullArtists)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.followArtistsForCurrentUser(partialArtists)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserFollowsArtists(fullArtists)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [true, true, false, false])
                return Self.spotify.unfollowArtistsForCurrentUser(fullArtists)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserFollowsArtists(fullArtists)
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { results in
                    XCTAssertEqual(results, [false, false, false, false])
                }
            )
            .store(in: &Self.cancellables)

        let emptyExpectationUnfollow = XCTestExpectation(
            description: "testUnfollowFollowArtists empty"
        )

        var receivedValueFromEmptyUnfollow = false

        Self.spotify.unfollowArtistsForCurrentUser([])
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in emptyExpectationUnfollow.fulfill() },
                receiveValue: { _ in
                    receivedValueFromEmptyUnfollow = true
                }
            )
            .store(in: &Self.cancellables)

        let emptyExpectationCheck = XCTestExpectation(
            description: "testCheckFollowArtists empty"
        )

        var receivedValueFromEmptyCheck = false

        Self.spotify.currentUserFollowsArtists([])
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in emptyExpectationCheck.fulfill() },
                receiveValue: { results in
                    XCTAssertEqual(results, [])
                    receivedValueFromEmptyCheck = true
                }
            )
            .store(in: &Self.cancellables)

        self.wait(
            for: [
                expectation,
                emptyExpectationUnfollow,
                emptyExpectationCheck
            ],
            timeout: 300
        )

        XCTAssertTrue(receivedValueFromEmptyUnfollow)
        XCTAssertTrue(receivedValueFromEmptyCheck)

    }

    func followUsers() {

        DistributedLock.follow.lock()
        defer {
            DistributedLock.follow.unlock()
        }

        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        let internalQueue = DispatchQueue(label: "internal")

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        
        let expectation = XCTestExpectation(
            description: "testFollowUsers"
        )

        let fullUsers = URIs.Users.array(
            .nicholas, .april
        )

        let partialUsers = URIs.Users.array(
            .nicholas
        )

        Self.spotify.unfollowUsersForCurrentUser(fullUsers)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.followUsersForCurrentUser(partialUsers)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserFollowsUsers(fullUsers)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [true, false])
                return Self.spotify.unfollowUsersForCurrentUser(fullUsers)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserFollowsUsers(fullUsers)
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { results in
                    XCTAssertEqual(results, [false, false])
                }
            )
            .store(in: &Self.cancellables)

        let emptyExpectation = XCTestExpectation(
            description: "testFollowUsers empty"
        )

        var receivedValueFromEmpty = false

        Self.spotify.followUsersForCurrentUser([])
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in emptyExpectation.fulfill() },
                receiveValue: { _ in
                    receivedValueFromEmpty = true
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
        self.wait(
            for: [authorizationManagerDidChangeExpectation],
            timeout: 5
        )
       
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should emit exactly once"
            )
        }
        XCTAssertTrue(receivedValueFromEmpty)

    }

    func followPlaylist() {

        DistributedLock.follow.lock()
        defer {
            DistributedLock.follow.unlock()
        }

        let expectation = XCTestExpectation(
            description: "testFollowPlaylist"
        )

        let playlist = URIs.Playlists.thisIsSpoon
        var currentUserURI: String? = nil

        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Void, Error> in
                currentUserURI = user.uri
                return Self.spotify.unfollowPlaylistForCurrentUser(
                    playlist
                )
            }
//            .XCTAssertNoFailure()
            .catch({ error -> AnyPublisher<Void, Error> in
                print(
                    """
                    \(#function):\(#line) caught error unfollowing this is spoon:
                    \(error)
                    """
                )
                return Result<Void, Error>.success(())
                    .publisher
                    .eraseToAnyPublisher()
            })
            .receiveOnMain(delay: 1)
            .flatMap { () -> AnyPublisher<[Bool], Error> in
                guard let user = currentUserURI else {
                    return SpotifyGeneralError.other("user URI was nil")
                        .anyFailingPublisher()
                }
                return Self.spotify.usersFollowPlaylist(
                    playlist,
                    userURIs: [user]
                )
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [false])
                return Self.spotify.followPlaylistForCurrentUser(
                    playlist
                )
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { () -> AnyPublisher<[Bool], Error> in
                guard let user = currentUserURI else {
                    return SpotifyGeneralError.other("user URI was nil")
                        .anyFailingPublisher()
                }
                return Self.spotify.usersFollowPlaylist(
                    playlist,
                    userURIs: [user]
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { results in
                    XCTAssertEqual(results, [true])
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)

    }

}

// MARK: - Client -

final class SpotifyAPIClientCredentialsFlowFollowTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }

}

final class SpotifyAPIAuthorizationCodeFlowFollowTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist),
        ("testFollowedArtists", testFollowedArtists),
        ("testFollowedArtistsPages", testFollowedArtistsPages),
        ("testFollowArtists", testFollowArtists),
        ("testFollowUsers", testFollowUsers),
        ("testFollowPlaylist", testFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }
    func testFollowedArtists() { followedArtists() }
    func testFollowedArtistsPages() { followedArtistsPages() }
    func testFollowArtists() { followArtists() }
    func testFollowUsers() { followUsers() }
    func testFollowPlaylist() { followPlaylist() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEFollowTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist),
        ("testFollowedArtists", testFollowedArtists),
        ("testFollowedArtistsPages", testFollowedArtistsPages),
        ("testFollowArtists", testFollowArtists),
        ("testFollowUsers", testFollowUsers),
        ("testFollowPlaylist", testFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }
    func testFollowedArtists() { followedArtists() }
    func testFollowedArtistsPages() { followedArtistsPages() }
    func testFollowArtists() { followArtists() }
    func testFollowUsers() { followUsers() }
    func testFollowPlaylist() { followPlaylist() }

}

// MARK: - Proxy -

final class SpotifyAPIClientCredentialsFlowProxyFollowTests:
    SpotifyAPIClientCredentialsFlowProxyTests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }

}


final class SpotifyAPIAuthorizationCodeFlowProxyFollowTests:
    SpotifyAPIAuthorizationCodeFlowProxyTests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist),
        ("testFollowedArtists", testFollowedArtists),
        ("testFollowedArtistsPages", testFollowedArtistsPages),
        ("testFollowArtists", testFollowArtists),
        ("testFollowUsers", testFollowUsers),
        ("testFollowPlaylist", testFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }
    func testFollowedArtists() { followedArtists() }
    func testFollowedArtistsPages() { followedArtistsPages() }
    func testFollowArtists() { followArtists() }
    func testFollowUsers() { followUsers() }
    func testFollowPlaylist() { followPlaylist() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyFollowTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist),
        ("testFollowedArtists", testFollowedArtists),
        ("testFollowedArtistsPages", testFollowedArtistsPages),
        ("testFollowArtists", testFollowArtists),
        ("testFollowUsers", testFollowUsers),
        ("testFollowPlaylist", testFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }
    func testFollowedArtists() { followedArtists() }
    func testFollowedArtistsPages() { followedArtistsPages() }
    func testFollowArtists() { followArtists() }
    func testFollowUsers() { followUsers() }
    func testFollowPlaylist() { followPlaylist() }

}
