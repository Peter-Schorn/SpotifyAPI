import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities

final class AuthorizationScopesTests: SpotifyAPITestCase {
    
    func testEmptyScopes() {
        
        let scopes: Set<Scope> = []
        let scopeString = Scope.makeString(scopes)
        XCTAssertEqual(scopeString, "")
        let convertedScopes = Scope.makeSet(scopeString)
        XCTAssertEqual(convertedScopes, [])
        
        let scopeString2 = Scope.makeString()
        XCTAssertEqual(scopeString2, "")
        let convertedScopes2 = Scope.makeSet(scopeString2)
        XCTAssertEqual(convertedScopes2, [])
        
        
    }
    
    func testScopes() {
        
        let scopes = Set(Scope.allCases.shuffled().prefix(5))
        let scopeString = Scope.makeString(scopes)
        let convertedScopes = Scope.makeSet(scopeString)
        XCTAssertEqual(convertedScopes, scopes)

    }
    
    func testAllScopes() {
        
        let scopeString = Scope.makeString(Scope.allCases)
        let convertedScopes = Scope.makeSet(scopeString)
        XCTAssertEqual(Scope.allCases, convertedScopes)
        
    }
    
    func testVariadicScopes() {
        
        let expectedScopes: Set<Scope> = [
            .userFollowModify, .userLibraryRead, .playlistReadPrivate
        ]
        let scopeString = Scope.makeString(
            .userFollowModify, .userLibraryRead, .playlistReadPrivate
        )
        let scopes = Scope.makeSet(scopeString)
        XCTAssertEqual(scopes, expectedScopes)

    }

}
