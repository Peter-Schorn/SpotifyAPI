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

protocol SpotifyAPIBrowseTests: SpotifyAPITests { }

extension SpotifyAPIBrowseTests {
    
    func category() {

        let expectation = XCTestExpectation(description: "testCategory")
        
        Self.spotify.category(
            "0JQ5DAqbMKFA6SOHvT3gck",
            country: "US",
            locale: "es_MX"  // Spanish Mexico
        )
        .XCTAssertNoFailure()
        .receiveOnMain()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { category in
                encodeDecode(category, areEqual: ==)
                XCTAssertEqual(category.name, "Fiesta")
                XCTAssertEqual(category.id, "0JQ5DAqbMKFA6SOHvT3gck")
                XCTAssertEqual(
                    category.href,
                    URL(string: "https://api.spotify.com/v1/browse/categories/0JQ5DAqbMKFA6SOHvT3gck")!
                )
                XCTAssertImagesExist(
                    category.icons, assertSizeNotNil: false
                )
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        

    }

    func categories() {
        
        func receiveCategories(_ categories: PagingObject<SpotifyCategory>) {
            encodeDecode(categories, areEqual: ==)
            XCTAssertEqual(categories.limit, 10)
            XCTAssertEqual(categories.offset, 5)
            XCTAssertLessThanOrEqual(categories.items.count, 10)
            XCTAssertNotNil(categories.previous)
            if categories.total > categories.items.count + categories.offset {
                XCTAssertNotNil(categories.next)
            }
            print("categories:")
            dump(categories)
        }
        
        let expectation = XCTestExpectation(
            description: "testCategories"
        )

        Self.spotify.categories(
            country: "US",
            locale: "es_MX",
            limit: 10,
            offset: 5
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveCategories(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
        

    }
    
    func categoriesPages() {
        
        func receiveCategories(_ categories: PagingObject<SpotifyCategory>) {
            encodeDecode(categories, areEqual: ==)
            let page = categories.offset / categories.limit
            print("\n\(page). categories:")
            dump(categories)
        }
        
        let expectation = XCTestExpectation(
            description: "testCategoriesPages"
        )

        Self.spotify.categories(
            country: "US",
            locale: "es_US",
            limit: 5
        )
        .XCTAssertNoFailure()
        .extendPages(Self.spotify)
        .XCTAssertNoFailure("after `extendPages`:")
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveCategories(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func categoryPlaylists() {
        
        func receiveCategoryPlaylists(
            _ playlists: PagingObject<Playlist<PlaylistItemsReference>?>
        ) {
            encodeDecode(playlists, areEqual: ==)
            XCTAssertEqual(playlists.limit, 20)
            XCTAssertLessThanOrEqual(playlists.items.count, 20)
            XCTAssertNotNil(playlists.previous)
            if playlists.total > playlists.items.count + playlists.offset {
                XCTAssertNotNil(playlists.next)
            }
            else {
                XCTAssertNil(playlists.next)
            }
            print("category playlists:")
            dump(playlists)
        }
        
        print("-----------------------------------\n")

        let expectation = XCTestExpectation(
            description: "testCategoryPlaylists"
        )
        
        Self.spotify.categoryPlaylists(
            "0JQ5DAqbMKFDXXwE9BDJAr", country: "US", limit: 20, offset: 2
        )
        .XCTAssertNoFailure()
        .extendPages(Self.spotify)
        .XCTAssertNoFailure("after `extendPages`:")
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveCategoryPlaylists(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }

    func featuredPlaylists() {
        
        func receivePlaylists(_ featuredPlaylists: FeaturedPlaylists) {
            encodeDecode(featuredPlaylists, areEqual: ==)
            let playlists = featuredPlaylists.playlists
            XCTAssertEqual(playlists.limit, 10)
            XCTAssertEqual(playlists.offset, 5)
            XCTAssertLessThanOrEqual(playlists.items.count, 10)
            XCTAssertNotNil(playlists.previous)
            if playlists.total > playlists.items.count + playlists.offset {
                XCTAssertNotNil(playlists.next)
            }
        }
        
        let expectation = XCTestExpectation(
            description: "testFeaturedPlaylists"
        )
        
        // 24 hours ago
        let yesterday = Date().addingTimeInterval(-86_400)
        
        Self.spotify.featuredPlaylists(
            locale: "en_US",
            country: "US",
            timestamp: yesterday,
            limit: 10,
            offset: 5
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receivePlaylists(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func newAlbumReleases() {
        
        func receiveNewAlbumReleases(_ albumReleases: NewAlbumReleases) {
            encodeDecode(albumReleases)
            let albums = albumReleases.albums
            XCTAssertEqual(albums.limit, 5)
            XCTAssertEqual(albums.offset, 4)
            XCTAssertNotNil(albums.previous)
            if albums.total > albums.items.count + albums.offset {
                XCTAssertNotNil(albums.next)
            }
        }
        
        let expectation = XCTestExpectation(
            description: "testNewAlbumReleases"
        )

        Self.spotify.newAlbumReleases(country: "GB", limit: 5, offset: 4)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveNewAlbumReleases(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }
    
    func recommendations() {
        
        func createTrackAttributesFromGenres(
            _ genres: [String]
        ) -> TrackAttributes {
        
            receivedGenres = Array((genres).prefix(2))
            
            let trackAttributes = TrackAttributes(
                seedArtists: URIs.Artists.array(.theBeatles, .crumb),
                seedTracks: URIs.Tracks.array(.fearless),
                seedGenres: receivedGenres!,
                energy: .init(min: 0.5, target: 0.67, max: 0.78),
                instrumentalness: .init(min: 0.3, target: 0.5, max: 1),
                popularity: .init(min: 60),
                valence: .init(target: 0.8)
            )
        
            encodeDecode(trackAttributes)
        
            return trackAttributes
        }
        
        func receiveRecommentations(_ recommentations: RecommendationsResponse) {
            
            encodeDecode(recommentations)

            
            // MARK: Seed Artists
            
            let seedArtists = recommentations.seedArtists
            for artist in seedArtists {
                XCTAssertEqual(artist.type, .artist)
            }
            
            if let theBeatles = seedArtists.first(where: { seedArtist in
                seedArtist.id == "3WrFJ7ztbogyGnTHbHJFl2"
            }) {
                XCTAssertEqual(
                    theBeatles.href,
                    URL(string: "https://api.spotify.com/v1/artists/3WrFJ7ztbogyGnTHbHJFl2")!
                )
            }
            else {
                XCTFail("should've found The Beatles in seed artists")
            }
            
            if let crumb = seedArtists.first(where: { seedArtist in
                seedArtist.id == "4kSGbjWGxTchKpIxXPJv0B"
            }) {
                XCTAssertEqual(
                    crumb.href,
                    URL(string: "https://api.spotify.com/v1/artists/4kSGbjWGxTchKpIxXPJv0B")!
                )
            }
            else {
                XCTFail("should've found Crumb in seed artists")
            }
            
            // MARK: Seed Tracks
            
            let seedTracks = recommentations.seedTracks
            for track in seedTracks {
                XCTAssertEqual(track.type, .track)
            }
            
            if let fearless = seedTracks.first(where: { seedTrack in
                seedTrack.id == "7AalBKBoLDR4UmRYRJpdbj"
            }) {
                XCTAssertEqual(
                    fearless.href,
                    URL(string: "https://api.spotify.com/v1/tracks/7AalBKBoLDR4UmRYRJpdbj")!
                )
            }
            else {
                XCTFail("should've found Fearless in seed tracks")
            }
            
            // MARK: Seed Genres
            guard let receivedGenres = receivedGenres else {
                XCTFail("receivedGenres should not be nil")
                return
            }
            
            let seedGenres = recommentations.seedGenres
            for genre in seedGenres {
                XCTAssertEqual(genre.type, .genre)
                XCTAssertNil(genre.href)
            }
            
            let seedGenresIds = seedGenres.map(\.id)
            for genre in receivedGenres {
                XCTAssert(
                    seedGenresIds.contains(genre),
                    "\(seedGenres) != \(receivedGenres)"
                )
            }
            
        }
        
        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        let internalQueue = DispatchQueue(label: "internal")
        var cancellables: Set<AnyCancellable> = []

        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        let expectation = XCTestExpectation(description: "testRecommendations")
        
        var receivedGenres: [String]? = nil
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())

        Self.spotify.recommendationGenres()
            .XCTAssertNoFailure()
            .map(createTrackAttributesFromGenres(_:))
            .flatMap { trackAttributes in
                Self.spotify.recommendations(
                    trackAttributes,
                    limit: 6,
                    market: "US"
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveRecommentations(_:)
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

final class SpotifyAPIClientCredentialsFlowBrowseTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIBrowseTests
{

    static let allTests = [
        ("testCategory", testCategory),
        ("testCategories", testCategories),
        ("testCategoryPlaylists", testCategoryPlaylists),
        ("testFeaturedPlaylists", testFeaturedPlaylists),
        ("testNewAlbumReleases", testNewAlbumReleases),
        ("testRecommendations", testRecommendations)
    ]
    
    func testCategory() { category() }
    func testCategories() { categories() }
    func testCategoriesPages() { categoriesPages() }
    func testCategoryPlaylists() { categoryPlaylists() }
    func testFeaturedPlaylists() { featuredPlaylists() }
    func testNewAlbumReleases() { newAlbumReleases() }
    func testRecommendations() { recommendations() }
    
}

final class SpotifyAPIAuthorizationCodeFlowBrowseTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIBrowseTests
{
    
    static let allTests = [
        ("testCategory", testCategory),
        ("testCategories", testCategories),
        ("testCategoryPlaylists", testCategoryPlaylists),
        ("testFeaturedPlaylists", testFeaturedPlaylists),
        ("testNewAlbumReleases", testNewAlbumReleases),
        ("testRecommendations", testRecommendations)
    ]
    
    func testCategory() { category() }
    func testCategories() { categories() }
    func testCategoriesPages() { categoriesPages() }
    func testCategoryPlaylists() { categoryPlaylists() }
    func testFeaturedPlaylists() { featuredPlaylists() }
    func testNewAlbumReleases() { newAlbumReleases() }
    func testRecommendations() { recommendations() }

}


final class SpotifyAPIAuthorizationCodeFlowPKCEBrowseTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIBrowseTests
{
    
    static let allTests = [
        ("testCategory", testCategory),
        ("testCategories", testCategories),
        ("testCategoryPlaylists", testCategoryPlaylists),
        ("testFeaturedPlaylists", testFeaturedPlaylists),
        ("testNewAlbumReleases", testNewAlbumReleases),
        ("testRecommendations", testRecommendations)
    ]
    
    func testCategory() { category() }
    func testCategories() { categories() }
    func testCategoriesPages() { categoriesPages() }
    func testCategoryPlaylists() { categoryPlaylists() }
    func testFeaturedPlaylists() { featuredPlaylists() }
    func testNewAlbumReleases() { newAlbumReleases() }
    func testRecommendations() { recommendations() }
    
}
