// import Foundation
// import XCTest
// import Combine
// @testable import SpotifyWebAPI
//
// class SpotifyAPIRefreshAsyncTests: SpotifyAPIAuthorizationCodeFlowTests {
//
//     func testAsyncTokensRefresh() {
//
//         // AuthorizationCodeFlowManager.logger.level = .warning
//
//         var cancellables: Set<AnyCancellable> = []
//
//         let past = Date().addingTimeInterval(-10)
//
//         Self.spotify.authorizationManager.setExpirationDate(to: past)
//
//         let range = 0...10
//
//         let expectations = range.map { i in
//             XCTestExpectation(
//                 description: "testAsyncTokensRefresh \(i)"
//             )
//         }
//
//         for i in range {
//             DispatchQueue.global().async {
//                 print(i)
//                 let cancellable = Self.spotify.authorizationManager.refreshTokens(
//                     onlyIfExpired: true
//                 )
//                 .XCTAssertNoFailure()
//                 .sink(
//                     receiveCompletion: { _ in
//                         print("fulfilling expectation \(i)")
//                         expectations[i].fulfill()
//                     },
//                     receiveValue: {
//                         print("finished refreshing tokens \(i)")
//                     }
//                 )
//
//                 print("after \(i)")
//
//                 DispatchQueue.main.async {
//                     cancellables.insert(cancellable)
//                 }
//
//
//             }
//
//         }
//
//         print("waiting for expectations")
//         wait(for: expectations, timeout: 30)
//         print("done waiting")
//
//     }
//
// }
//
//
