import Foundation
import Combine
import XCTest
import SpotifyWebAPI
import _SpotifyAPITestUtilities
import SpotifyURIs

final class SpotifyIdentifierTests: XCTestCase {

    static var cancellables: Set<AnyCancellable> = []
    
    static var allTests = [
        ("testURIs", testURIs)
    ]
    
    func testURIs() throws {
        
        let honey = URIs.Tracks.honey
        
        let spotifyIdentifier = try SpotifyIdentifier(uri: honey)
        XCTAssertEqual(spotifyIdentifier.uri, honey.uri)
        XCTAssertEqual(spotifyIdentifier.idCategory, .track)
        XCTAssertEqual(spotifyIdentifier.id, "01IuTsgAlgKlgrvPhZ2c95")
        XCTAssertEqual(
            spotifyIdentifier.url,
            URL(string: "https://open.spotify.com/track/01IuTsgAlgKlgrvPhZ2c95")!
        )

        if let url = spotifyIdentifier.url {
            
            let expectation = XCTestExpectation(description: "url existence")
            
            URLSession.shared.dataTaskPublisher(for: url)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: { data, response in
                        let httpURLResponse = response as! HTTPURLResponse
                        XCTAssertEqual(httpURLResponse.statusCode, 200)
                    }
                )
                .store(in: &Self.cancellables)
            
            wait(for: [expectation], timeout: 30)
        }
        
    }
    
    
}
