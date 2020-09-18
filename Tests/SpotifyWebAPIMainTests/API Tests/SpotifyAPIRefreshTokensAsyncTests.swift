 import Foundation
 import XCTest
 import Combine
 import SpotifyAPITestUtilities
 @testable import SpotifyWebAPI
 
 // class SpotifyAPIRefreshTokensAsyncTests: SpotifyAPIAuthorizationCodeFlowTests {
 class SpotifyAPIRefreshTokensAsyncTests: SpotifyAPIClientCredentialsFlowTests {
    
    func testAsyncTokensRefresh() {
        
        var cancellables: Set<AnyCancellable> = []
        
        let now = Date()
        Self.spotify.authorizationManager.setExpirationDate(to: now)
        
        let range = 0...5
        
        let expectations = range.map { i in
            XCTestExpectation(
                description: "testAsyncTokensRefresh \(i)"
            )
        }
        
        for i in range {
            usleep(20_000)
            print("iteration", i)
                let cancellable = Self.spotify.authorizationManager.refreshTokens(
                    onlyIfExpired: true
                )
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { _ in
                        print("fulfilling expectation \(i)")
                        expectations[i].fulfill()
                    },
                    receiveValue: {
                        print("finished refreshing tokens \(i)")
                    }
                )
                
                print("after \(i)")
                
                DispatchQueue.main.async {
                    cancellables.insert(cancellable)
                }
                
        }
        
        print("waiting for expectations")
        wait(for: expectations, timeout: 60)
        print("done waiting")
        
    }
    
 }
 
 
