import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities

final class CodingTimeReferenceTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testCodingTimeReference", testCodingTimeReference)
    ]
    
    func testCodingTimeReference() {
        
        let timeReference1 = TimeReference.before(Date())
        encodeDecode(timeReference1)
        
        let timeReference2 = TimeReference.after(Date())
        encodeDecode(timeReference2)
        
        for _ in 1...1_000 {
            let randomInterval = Double.random(in: -1_000_000_000...1_000_000_000)
            let date = Date().addingTimeInterval(randomInterval)
            let timeReference3 = TimeReference.before(date)
            
            encodeDecode(timeReference3)
            
        }
        
        for _ in 1...1_000 {
            let randomInterval = Double.random(in: -1_000_000_000...1_000_000_000)
            let date = Date().addingTimeInterval(randomInterval)
            let timeReference3 = TimeReference.after(date)
            
            encodeDecode(timeReference3)
            
        }
        
    }
    
    
}
