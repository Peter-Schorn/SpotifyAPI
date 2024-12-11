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
                XCTAssertEqual(category.name, "¡Fiesta!")
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
    
}

final class SpotifyAPIClientCredentialsFlowBrowseTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIBrowseTests
{

    static let allTests = [
        ("testCategory", testCategory),
        ("testCategories", testCategories),
        ("testNewAlbumReleases", testNewAlbumReleases)
    ]
    
    func testCategory() { category() }
    func testCategories() { categories() }
    func testCategoriesPages() { categoriesPages() }
    func testNewAlbumReleases() { newAlbumReleases() }

}

final class SpotifyAPIAuthorizationCodeFlowBrowseTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIBrowseTests
{
    
    static let allTests = [
        ("testCategory", testCategory),
        ("testCategories", testCategories),
        ("testNewAlbumReleases", testNewAlbumReleases)
    ]

    func testCategory() { category() }
    func testCategories() { categories() }
    func testCategoriesPages() { categoriesPages() }
    func testNewAlbumReleases() { newAlbumReleases() }

}


final class SpotifyAPIAuthorizationCodeFlowPKCEBrowseTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIBrowseTests
{
    
    static let allTests = [
        ("testCategory", testCategory),
        ("testCategories", testCategories),
        ("testNewAlbumReleases", testNewAlbumReleases)
    ]

    func testCategory() { category() }
    func testCategories() { categories() }
    func testCategoriesPages() { categoriesPages() }
    func testNewAlbumReleases() { newAlbumReleases() }

}
