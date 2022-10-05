import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent


protocol SpotifyAPIEpisodeTests: SpotifyAPITests { }

extension SpotifyAPIEpisodeTests {

    func receiveSamHarris212(_ episode: Episode) {
        encodeDecode(episode)
        XCTAssertEqual(
            episode.description,
            """
            In this episode of the podcast, Sam Harris speaks with Kathryn \
            Paige Harden about public controversy over group differences \
            in traits like intelligence and ongoing research in behavioral \
            genetics. They discuss Harden’s criticism of the Making Sense \
            episode featuring Charles Murray, the mingling of scientific \
            thinking with politics and social activism, cancel culture, \
            environmental and genetic contributions to individual and group \
            differences, intellectual honesty, and other topics. SUBSCRIBE \
            to gain access to all full-length episodes at \
            samharris.org/subscribe.
            """
        )
        XCTAssertEqual(episode.durationMS, 2923102)
        XCTAssertFalse(episode.isExplicit)
        XCTAssertEqual(
            episode.href,
            URL(string: "https://api.spotify.com/v1/episodes/3OEdPEYB69pfXoBrhvQYeC")!
        )
        XCTAssertEqual(episode.id, "3OEdPEYB69pfXoBrhvQYeC")
        XCTAssertFalse(episode.isExternallyHosted)
        XCTAssertTrue(episode.isPlayable)
        XCTAssert(episode.languages.contains("en"), "\(episode.languages)")
        XCTAssertEqual(episode.name, "#212 — A Conversation with Kathryn Paige Harden")
        XCTAssertEqual(episode.type, .episode)
        XCTAssertEqual(episode.uri, "spotify:episode:3OEdPEYB69pfXoBrhvQYeC")
        
        if let externalURLs = episode.externalURLs {
            XCTAssertEqual(
                externalURLs["spotify"],
                URL(string: "https://open.spotify.com/episode/3OEdPEYB69pfXoBrhvQYeC")!,
                "\(externalURLs)"
            )
        }
        else {
            XCTFail("externalURLs should not be nil")
        }
        
        if let releaseDate = episode.releaseDate {
            XCTAssertEqual(
                releaseDate.timeIntervalSince1970,
                1595980800,
                accuracy: 43_200  // 12 hours
            )
        }
        else {
            XCTFail("release date should not be nil")
        }
        XCTAssertEqual(episode.releaseDatePrecision, "day")

        XCTAssertImagesExist(episode.images, assertSizeNotNil: true)

        if Self.spotify.authorizationManager.isAuthorized(
            for: [.userReadPlaybackPosition]
        ) {
            XCTAssertNotNil(
                episode.resumePoint,
                "episode resume point was nil: " +
                "\(type(of: Self.spotify.authorizationManager))"
            )
        }
        
        // MARK: Check Show
        guard let show = episode.show else {
            XCTFail("full episode object should contain show")
            return
        }
        
        XCTAssert(show.availableMarkets.contains("US"))
        XCTAssertEqual(
            show.description,
            """
            Join neuroscientist, philosopher, and best-selling author Sam \
            Harris as he explores important and controversial questions about \
            the human mind, society, and current events.  Sam Harris is the \
            author of The End of Faith, Letter to a Christian Nation, The \
            Moral Landscape, Free Will, Lying, Waking Up, and Islam and the \
            Future of Tolerance (with Maajid Nawaz). The End of Faith won the \
            2005 PEN Award for Nonfiction. His writing has been published in \
            more than 20 languages. Mr. Harris and his work have been discussed \
            in The New York Times, Time, Scientific American, Nature, Newsweek, \
            Rolling Stone, and many other journals. His writing has appeared in \
            The New York Times, The Los Angeles Times, The Economist, Newsweek, \
            The Times (London), The Boston Globe, The Atlantic, The Annals of \
            Neurology, and elsewhere.  Mr. Harris received a degree in \
            philosophy from Stanford University and a Ph.D. in neuroscience \
            from UCLA.
            """
        )
        XCTAssertFalse(show.isExplicit)
        XCTAssertEqual(
            show.href,
            URL(string: "https://api.spotify.com/v1/shows/5rgumWEx4FsqIY8e1wJNAk")!
        )
        XCTAssertEqual(show.id, "5rgumWEx4FsqIY8e1wJNAk")
        XCTAssertFalse(show.isExternallyHosted)
        XCTAssertEqual(show.mediaType, "audio")
        XCTAssertEqual(show.name, "Making Sense with Sam Harris")
        XCTAssertEqual(show.publisher, "Sam Harris")
        if let totalEpisodes = show.totalEpisodes {
            XCTAssert(totalEpisodes >= 226, "\(totalEpisodes)")
        }
        else {
            XCTFail("totalEpisodes should not be nil")
        }
        XCTAssertEqual(show.type, .show)
        XCTAssertEqual(show.uri, "spotify:show:5rgumWEx4FsqIY8e1wJNAk")
     
        guard let images = show.images else {
            XCTFail("images should not be nil")
            return
        }
        XCTAssertImagesExist(
            images, assertSizeNotNil: true
        )
        
    }
    
    func episode() {
        
        let expectation = XCTestExpectation(description: "testEpisode")
        
        Self.spotify.episode(URIs.Episodes.samHarris212, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveSamHarris212(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func episodes() {
        
        func receiveEpisodes(_ episodes: [Episode?]) {
            encodeDecode(episodes)
            guard episodes.count == 3 else {
                XCTFail("should've received 3 episodes")
                return
            }
            
            if let samHarris212 = episodes[0] {
                receiveSamHarris212(samHarris212)
            }
            else {
                XCTFail("first episode should not be nil")
            }
            if let samHarris213 =  episodes[1] {
                XCTAssertEqual(
                    samHarris213.description,
                    """
                    In this episode the podcast, Sam Harris speaks with Gabriel \
                    Dance about the global epidemic of child sexual abuse. \
                    They discuss how misleading the concept of “child \
                    pornography” is, the failure of governments and tech \
                    companies to grapple with the problem, the tradeoff between \
                    online privacy and protecting children, the National Center \
                    for Missing and Exploited Children, photo DNA, the roles \
                    played by specific tech companies, the ethics of \
                    encryption, “sextortion,” the culture of pedophiles, and \
                    other topics. SUBSCRIBE to gain access to all full-length \
                    episodes at samharris.org/subscribe.
                    """
                )
                XCTAssertEqual(samHarris213.name, "#213 — The Worst Epidemic")
                XCTAssertEqual(
                    samHarris213.uri,
                    "spotify:episode:7jrEoNMrNicZSxIuKhATHN"
                )
                XCTAssertEqual(samHarris213.id, "7jrEoNMrNicZSxIuKhATHN")
                XCTAssertEqual(samHarris213.durationMS, 8060369)
                XCTAssertFalse(samHarris213.isExplicit)
                XCTAssertEqual(samHarris213.type, .episode)
                if let releaseDate = samHarris213.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        1596499200,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
                XCTAssertEqual(samHarris213.releaseDatePrecision, "day")
            }
            else {
                XCTFail("second episode should not be nil")
            }
            
            if let joeRogan1531 = episodes[2] {
                XCTAssertEqual(
                    joeRogan1531.description,
                    """
                    Miley Cyrus is a singer-songwriter, actress, and record \
                    producer. http://mileyl.ink/midnightsky
                    """
                )
                XCTAssertEqual(joeRogan1531.name, "#1531 - Miley Cyrus")
                XCTAssertEqual(
                    joeRogan1531.uri,
                    "spotify:episode:0ZEDvQuPtAEBnXE37slSoX"
                )
                XCTAssertEqual(joeRogan1531.id, "0ZEDvQuPtAEBnXE37slSoX")
                XCTAssertEqual(joeRogan1531.durationMS, 7591593)
                XCTAssertTrue(joeRogan1531.isExplicit)
                XCTAssertEqual(joeRogan1531.type, .episode)
                if let releaseDate = joeRogan1531.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        1599004800,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
                XCTAssertEqual(joeRogan1531.releaseDatePrecision, "day")
            }
            else {
                XCTFail("third episode should not be nil")
            }
            
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

        let expectation = XCTestExpectation(description: "testEpisode")
        
        let episodes = URIs.Episodes.array(
            .samHarris212, .samHarris213, .joeRogan1531
        )
        
        Self.spotify.episodes(episodes, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveEpisodes(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(
            for: [
                expectation,
                authorizationManagerDidChangeExpectation
            ],
            timeout: 120
        )
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should emit exactly once"
            )
        }

    }
    
}

final class SpotifyAPIClientCredentialsFlowEpisodeTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIEpisodeTests
{

    static let allTests = [
        ("testEpisode", testEpisode),
        ("testEpisodes", testEpisodes)
    ]
    
    func testEpisode() { episode() }
    func testEpisodes() { episodes() }

}

final class SpotifyAPIAuthorizationCodeFlowEpisodeTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIEpisodeTests
{

    static let allTests = [
        ("testEpisode", testEpisode),
        ("testEpisodes", testEpisodes)
    ]
    
    func testEpisode() { episode() }
    func testEpisodes() { episodes() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEEpisodeTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIEpisodeTests
{

    static let allTests = [
        ("testEpisode", testEpisode),
        ("testEpisodes", testEpisodes)
    ]
    
    func testEpisode() { episode() }
    func testEpisodes() { episodes() }
    
    
}
