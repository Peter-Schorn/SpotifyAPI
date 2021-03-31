import Foundation
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities

final class CodingAuthInfoTests: SpotifyAPITestCase {
    
    static var allTests = [
        ("testCodingAuthInfo", testCodingAuthInfo)
    ]
    
    func testCodingAuthInfo() {
        
        for _ in 1...100 {
            let authInfo = AuthInfo.withRandomValues()
            encodeDecode(authInfo)
        }
        
    }
    
    
}
