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

protocol SpotifyAPIMarketTests: SpotifyAPITests { }

extension SpotifyAPIMarketTests {
    
    func availableMarkets() {
        
        let expectation = XCTestExpectation(
            description: "market"
        )
        
        Self.spotify.availableMarkets()
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { markets in
                    XCTAssert(markets.contains("US"))
                    XCTAssert(markets.contains("GB"))
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

}
    
final class SpotifyAPIClientCredentialsFlowMarketTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIMarketTests
{
    
    static let allTests = [
        ("testAvailableMarkets", testAvailableMarkets)
    ]
    
    func testAvailableMarkets() { availableMarkets() }

}

final class SpotifyAPIAuthorizationCodeFlowMarketTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIMarketTests
{
    
    static let allTests = [
        ("testAvailableMarkets", testAvailableMarkets)
    ]
    
    func testAvailableMarkets() { availableMarkets() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEMarketTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIMarketTests
{
    
    static let allTests = [
        ("testAvailableMarkets", testAvailableMarkets)
    ]
    
    func testAvailableMarkets() { availableMarkets() }

}
