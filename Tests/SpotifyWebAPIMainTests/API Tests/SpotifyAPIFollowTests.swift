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
            URIs.Playlists.crumb,
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
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    func followArtists() {

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

        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        var authChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .sink(receiveValue: {
                authChangeCount += 1
            })
            .store(in: &Self.cancellables)

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

        self.wait(for: [expectation, emptyExpectation], timeout: 300)
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )
        XCTAssertTrue(receivedValueFromEmpty)

    }

    func followPlaylist() {

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
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { () -> AnyPublisher<[Bool], Error> in
                guard let user = currentUserURI else {
                    return SpotifyLocalError.other("user URI was nil")
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
                    return SpotifyLocalError.other("user URI was nil")
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
        ("testFollowArtists", testFollowArtists),
        ("testFollowUsers", testFollowUsers),
        ("testFollowPlaylist", testFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }
    func testFollowArtists() { followArtists() }
    func testFollowUsers() { followUsers() }
    func testFollowPlaylist() { followPlaylist() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEFollowTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIFollowTests
{

    static let allTests = [
        ("testUsersFollowPlaylist", testUsersFollowPlaylist),
        ("testFollowArtists", testFollowArtists),
        ("testFollowUsers", testFollowUsers),
        ("testFollowPlaylist", testFollowPlaylist)
    ]

    func testUsersFollowPlaylist() { usersFollowPlaylist() }
    func testFollowArtists() { followArtists() }
    func testFollowUsers() { followUsers() }
    func testFollowPlaylist() { followPlaylist() }

}
