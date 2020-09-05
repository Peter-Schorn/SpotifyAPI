import Foundation
import XCTest
@testable import SpotifyWebAPI

final class CodingAuthInfoTests: XCTestCase {
    
    // static var allTests = [
    //
    // ]
    
    func testCodingAuthInfo() {
        
        for _ in 1...100 {
            let authInfo = AuthInfo.withMockedValues()
            encodeDecode(authInfo)
        }
        
    }
    
    
}
