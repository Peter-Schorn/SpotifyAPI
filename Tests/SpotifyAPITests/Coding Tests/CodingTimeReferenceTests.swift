import Foundation
import XCTest
import SpotifyWebAPI


final class CodingTimeReferenceTests: XCTestCase {
    
    static var allTests = [
        ("testCodingTimeReference", testCodingTimeReference)
    ]
    
    static func timeReferencesAreApproximatelyEqual(
        lhs: TimeReference, rhs: TimeReference
    ) -> Bool {
        let lhsDate, rhsDate: Date
        switch (lhs, rhs) {
            case (.after(let lhsAfterDate), .after(let rhsAfterDate)):
                (lhsDate, rhsDate) = (lhsAfterDate, rhsAfterDate)
            case (.before(let lhsBeforeDate), .before(let rhsBeforeDate)):
                (lhsDate, rhsDate) = (lhsBeforeDate, rhsBeforeDate)
            default:
                return false
        }
        let areEqual = lhsDate.timeIntervalSince1970.isApproximatelyEqual(
            to: rhsDate.timeIntervalSince1970
        )
        XCTAssert(areEqual)
        return areEqual
    }
    
    
    func testCodingTimeReference() {
        
        let timeReference1 = TimeReference.before(Date())
        encodeDecode(
            timeReference1,
            areEqual: Self.timeReferencesAreApproximatelyEqual(lhs:rhs:)
        )
        
        let timeReference2 = TimeReference.after(Date())
        encodeDecode(
            timeReference2,
            areEqual: Self.timeReferencesAreApproximatelyEqual(lhs:rhs:)
        )
        
        for _ in 1...1_000 {
            let randomInterval = Double.random(in: -1_000_000_000...1_000_000_000)
            let date = Date().addingTimeInterval(randomInterval)
            let timeReference3 = TimeReference.before(date)
            
            encodeDecode(
                timeReference3,
                areEqual: Self.timeReferencesAreApproximatelyEqual(lhs:rhs:)
            )
            
        }
        
        for _ in 1...1_000 {
            let randomInterval = Double.random(in: -1_000_000_000...1_000_000_000)
            let date = Date().addingTimeInterval(randomInterval)
            let timeReference3 = TimeReference.after(date)
            
            encodeDecode(
                timeReference3,
                areEqual: Self.timeReferencesAreApproximatelyEqual(lhs:rhs:)
            )
            
        }
        
    }
    
    
}
