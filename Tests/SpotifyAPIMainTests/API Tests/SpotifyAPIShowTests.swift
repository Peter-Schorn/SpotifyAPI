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

protocol SpotifyAPIShowTests: SpotifyAPITests { }

extension SpotifyAPIShowTests {
    
    func receiveSeanCarroll(_ show: Show, isFullVersion: Bool) {
        encodeDecode(show)
        XCTAssert(show.availableMarkets.contains("US"))
        XCTAssertEqual(
            show.name,
            "Sean Carroll's Mindscape: Science, Society, Philosophy, Culture, Arts, and Ideas"
        )
        XCTAssertEqual(show.publisher, "Sean Carroll | Wondery")
        XCTAssertFalse(show.isExplicit)
        XCTAssertEqual(show.uri, "spotify:show:622lvLwp8CVu6dvCsYAJhN")
        XCTAssertEqual(show.id, "622lvLwp8CVu6dvCsYAJhN")
        XCTAssertEqual(show.type, .show)
        XCTAssertFalse(show.isExternallyHosted)
        XCTAssertEqual(show.mediaType, "audio")
        XCTAssertEqual(
            show.href,
            URL(string: "https://api.spotify.com/v1/shows/622lvLwp8CVu6dvCsYAJhN")!
        )
        if let totalEpisodes = show.totalEpisodes {
            XCTAssert(totalEpisodes >= 122, "total: \(totalEpisodes)")
        }
        else {
            XCTFail("total episodes should not be nil")
        }
        
        if let externalURLs = show.externalURLs {
            XCTAssertEqual(
                externalURLs["spotify"],
                URL(string: "https://open.spotify.com/show/622lvLwp8CVu6dvCsYAJhN")!,
                "\(externalURLs)"
            )
        }
        else {
            XCTFail("externalURLs should not be nil")
        }
        XCTAssertEqual(show.languages, ["en"])
        
        XCTAssertEqual(
            show.description.strip(),
            """
            Ever wanted to know how music affects your brain, what quantum \
            mechanics really is, or how black holes work? Do you wonder why \
            you get emotional each time you see a certain movie, or how on \
            earth video games are designed? Then you’ve come to the right place. \
            Each week, Sean Carroll will host conversations with some of the \
            most interesting thinkers in the world. From neuroscientists and \
            engineers to authors and television producers, Sean and his guests \
            talk about the biggest ideas in science, philosophy, culture and \
            much more.
            """.strip()
        )
        
        XCTAssertImagesExist(show.images, assertSizeNotNil: true)
        
        // MARK: Check Episodes
        guard isFullVersion else {
            return
        }
        guard let episodes = show.episodes else {
            XCTFail("full show object should contain episodes")
            return
        }
        
        XCTAssertEqual(episodes.total, show.totalEpisodes)
        XCTAssertNil(episodes.previous)
        XCTAssertNotNil(episodes.next)
        XCTAssertEqual(episodes.offset, 0)
        
        for episode in episodes.items {
            XCTAssertEqual(episode.type, .episode)
            XCTAssertEqual(episode.languages, ["en"])
            if Self.spotify.authorizationManager.isAuthorized(
                for: [.userReadPlaybackPosition]
            ) {
                XCTAssertNotNil(episode.resumePoint)
            }
        }
        
    }
    
    func show() {
        
        let expectation = XCTestExpectation(description: "testShow")
        
        Self.spotify.show(URIs.Shows.seanCarroll, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { show in
                    self.receiveSeanCarroll(show, isFullVersion: true)
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 120)
        
    }
    
    func shows() {
        
        func receiveShows(_ shows: [Show?]) {
            encodeDecode(shows)
            if let seanCarroll = shows[0] {
                receiveSeanCarroll(seanCarroll, isFullVersion: false)
            }
            else {
                XCTFail("first show should not be nil")
            }
            
            guard let joeRogan = shows[1] else {
                XCTFail("second show should not be nil")
                return
            }
            
            XCTAssertEqual(
                joeRogan.description,
                """
                The official podcast of comedian Joe Rogan. Follow The Joe \
                Rogan Clips show page for some of the best moments from the \
                episodes.
                """
            )
            XCTAssertTrue(joeRogan.isExplicit)
            XCTAssertEqual(joeRogan.name, "The Joe Rogan Experience")
            if let totalEpisodes = joeRogan.totalEpisodes {
                XCTAssert(totalEpisodes >= 1718, "total: \(totalEpisodes)")
            }
            else {
                XCTFail("total episodes should not be nil")
            }
            XCTAssertEqual(joeRogan.publisher, "Joe Rogan")
            XCTAssertEqual(joeRogan.type, .show)
            XCTAssertEqual(joeRogan.uri, "spotify:show:4rOoJ6Egrf8K2IrywzwOMk")
            XCTAssertEqual(joeRogan.id, "4rOoJ6Egrf8K2IrywzwOMk")
            XCTAssertEqual(
                joeRogan.href,
                URL(string: "https://api.spotify.com/v1/shows/4rOoJ6Egrf8K2IrywzwOMk")!
            )
            XCTAssert(joeRogan.languages.contains("en-US"), "\(joeRogan.languages)")
            XCTAssertFalse(joeRogan.isExternallyHosted)
            XCTAssertEqual(joeRogan.mediaType, "mixed")
            XCTAssert(
                joeRogan.availableMarkets.contains("US"),
                "\(joeRogan.availableMarkets)"
            )
            
            if let externalURLs = joeRogan.externalURLs {
                XCTAssertEqual(
                    externalURLs["spotify"],
                    URL(string: "https://open.spotify.com/show/4rOoJ6Egrf8K2IrywzwOMk")!,
                    "\(externalURLs)"
                )
            }
            else {
                XCTFail("externalURLs should not be nil")
            }
            
        }
        
        
        let expectation = XCTestExpectation(description: "testShows")

        let shows: [SpotifyURIConvertible] = [
            URIs.Shows.seanCarroll,
            URIs.Shows.joeRogan
        ]
        
        Self.spotify.shows(shows, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveShows(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }

    func showEpisodes() {
        
        func receiveShowEpisodes(_ show: PagingObject<Episode>) {
            encodeDecode(show)
            XCTAssertEqual(
                show.href,
                URL(string: "https://api.spotify.com/v1/shows/4eDCVvVXJVwKCa0QfNbuXA/episodes?offset=10&limit=30&market=US")!
            )
            XCTAssertEqual(show.limit, 30)
            XCTAssertEqual(show.offset, 10)
            XCTAssert(show.total >= 143, "\(show.total)")
            XCTAssertEqual(
                show.next,
                URL(string: "https://api.spotify.com/v1/shows/4eDCVvVXJVwKCa0QfNbuXA/episodes?offset=40&limit=30&market=US")!
            )
            XCTAssertEqual(
                show.previous,
                URL(string: "https://api.spotify.com/v1/shows/4eDCVvVXJVwKCa0QfNbuXA/episodes?offset=0&limit=30&market=US")!
            )
            

            if let episode1 = show.items.first {
                // MARK: Check Images for First Episode.
                if let images = episode1.images {
                    #if (canImport(AppKit) || canImport(UIKit)) && canImport(SwiftUI) && !targetEnvironment(macCatalyst)
                    var imageExpectations: [XCTestExpectation] = []
                    for (i, image) in images.enumerated() {
                        let expectation = XCTestExpectation(
                            description: "load image \(i)"
                        )
                        imageExpectations.append(expectation)
                        image.load()
                            .XCTAssertNoFailure()
                            .sink(
                                receiveCompletion: { _ in expectation.fulfill() },
                                receiveValue: { _ in }
                            )
                            .store(in: &Self.cancellables)
                    }
                    self.wait(
                        for: imageExpectations,
                        timeout: TimeInterval(60 * images.count)
                    )
                    #endif
                }
                else {
                    XCTFail("images should not be nil")
                }
            }
            else {
                XCTFail("show should have at least one episode")
            }
            
            for episode in show.items {
                XCTAssertEqual(episode.type, .episode)
                XCTAssertEqual(episode.languages, ["en"])
                if Self.spotify.authorizationManager.isAuthorized(
                    for: [.userReadPlaybackPosition]
                ) {
                    XCTAssertNotNil(episode.resumePoint)
                }
            }
            
        }
        
        let expectation = XCTestExpectation(description: "testShowEpisodes")
        
        Self.spotify.showEpisodes(
            URIs.Shows.scienceSalon,
            market: "US",
            offset: 10,
            limit: 30
        )
        .XCTAssertNoFailure()
        .receiveOnMain()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveShowEpisodes(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func showEpisodesExtendPagesConcurrent() {
        
        #if canImport(Combine)

        func receiveShowEpisodes(_ episodes: PagingObject<Episode>) {
            // the index of the last item in the page
//            let lastItemIndex = episodes.offset + episodes.items.count - 1
//            print(
//                """
//                index: \(episodes.estimatedIndex)
//                offset: \(episodes.offset)...\(lastItemIndex)
//                items.count: \(episodes.items.count)
//                total: \(episodes.total)
//                limit: \(episodes.limit)
//
//                """
//            )

            encodeDecode(episodes)

            receivedPageIndices.insert(episodes.estimatedIndex)

            XCTAssertGreaterThanOrEqual(episodes.total, 149)
            XCTAssertEqual(episodes.limit, 34)
            
            if episodes.next != nil {
                XCTAssertEqual(episodes.items.count, 34)
            }
            else {
                XCTAssertLessThanOrEqual(episodes.items.count, 34)
            }

        }

        var receivedPageIndices: Set<Int> = []

        let expectation = XCTestExpectation(
            description: "showEpisodesExtendPagesConcurrent"
        )
        
        let show = URIs.Shows.seanCarroll
        
        Self.spotify.showEpisodes(show, market: "US", offset: 23, limit: 34)
            .XCTAssertNoFailure()
            // request more pages than are available
            .extendPagesConcurrently(Self.spotify, maxExtraPages: 200)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveShowEpisodes(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)

        let expectedIndices = Set(0...3)
        XCTAssert(expectedIndices.isSubset(of: receivedPageIndices))

        #endif

    }

}

final class SpotifyAPIClientCredentialsFlowShowTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIShowTests
{

    static let allTests = [
        ("testShow", testShow),
        ("testShows", testShows),
        ("testShowEpisodes", testShowEpisodes),
        (
            "testShowEpisodesExtendPagesConcurrent",
            testShowEpisodesExtendPagesConcurrent
        )
    ]
    
    func testShow() { show() }
    func testShows() { shows() }
    func testShowEpisodes() { showEpisodes() }
    func testShowEpisodesExtendPagesConcurrent() {
        showEpisodesExtendPagesConcurrent()
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowShowTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIShowTests
{

    static let allTests = [
        ("testShow", testShow),
        ("testShows", testShows),
        ("testShowEpisodes", testShowEpisodes),
        (
            "testShowEpisodesExtendPagesConcurrent",
            testShowEpisodesExtendPagesConcurrent
        )
    ]
    
    func testShow() { show() }
    func testShows() { shows() }
    func testShowEpisodes() { showEpisodes() }
    func testShowEpisodesExtendPagesConcurrent() {
        showEpisodesExtendPagesConcurrent()
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEShowTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIShowTests
{

    static let allTests = [
        ("testShow", testShow),
        ("testShows", testShows),
        ("testShowEpisodes", testShowEpisodes),
        (
            "testShowEpisodesExtendPagesConcurrent",
            testShowEpisodesExtendPagesConcurrent
        )
    ]
    
    func testShow() { show() }
    func testShows() { shows() }
    func testShowEpisodes() { showEpisodes() }
    func testShowEpisodesExtendPagesConcurrent() {
        showEpisodesExtendPagesConcurrent()
    }
    
}
