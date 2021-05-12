import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent
import SpotifyAPITestUtilities

final class CodingSpotifyUserTests: SpotifyAPITestCase {

    static let allTests = [
        ("testCodingCurrentSpotifyUser", testCodingCurrentSpotifyUser),
        ("testCodingOtherUserProfile", testCodingOtherUserProfile)
    ]

    func testCodingCurrentSpotifyUser() {
        
        let user = SpotifyUser.sampleCurrentUserProfile
        encodeDecode(user, areEqual: ==)
        
        XCTAssertEqual(user.country, "US")
        XCTAssertEqual(user.displayName, "petervschorn")
        XCTAssertEqual(user.email, "youalmostgotme@gmail.com")
        XCTAssertEqual(user.allowsExplicitContent, true)
        XCTAssertEqual(user.explicitContentSettingIsLocked, false)
        XCTAssertEqual(
            user.externalURLs,
            [
                "spotify": URL(string: "https://open.spotify.com/user/petervschorn")!
            ]
        )
        XCTAssertEqual(user.followers?.total, 2)
        XCTAssertNil(user.followers?.href)
        XCTAssertEqual(
            user.href,
            URL(string: "https://api.spotify.com/v1/users/petervschorn")!
        )
        XCTAssertEqual(user.id, "petervschorn")
        XCTAssertEqual(user.uri, "spotify:user:petervschorn")
        XCTAssertEqual(user.type, .user)
        XCTAssertEqual(user.images, [])
        XCTAssertEqual(user.product, "premium")


    }
    
    func testCodingOtherUserProfile() throws {
        
        let user = try JSONDecoder().decode(
            SpotifyUser.self,
            from: Self.aprilUserProfileData
        )
        encodeDecode(user, areEqual: ==)
        
        XCTAssertNil(user.allowsExplicitContent)
        XCTAssertNil(user.explicitContentSettingIsLocked)
        XCTAssertEqual(user.displayName, "April")
        XCTAssertEqual(
            user.externalURLs,
            [
                "spotify": URL(string: "https://open.spotify.com/user/p8gjjfbirm8ucyt82ycfi9zuu")!
            ]
        )
        XCTAssertEqual(user.followers?.total, 14)
        XCTAssertNil(user.followers?.href)
        XCTAssertEqual(
            user.href,
            URL(string: "https://api.spotify.com/v1/users/p8gjjfbirm8ucyt82ycfi9zuu")!
        )
        XCTAssertEqual(user.id, "p8gjjfbirm8ucyt82ycfi9zuu")
        XCTAssertEqual(user.uri, "spotify:user:p8gjjfbirm8ucyt82ycfi9zuu")
        XCTAssertEqual(user.type, .user)
        XCTAssertEqual(user.images?.count, 1)
        let image = try XCTUnwrap(user.images?.first)
        XCTAssertNil(image.height)
        XCTAssertNil(image.width)
        XCTAssertEqual(
            image.url,
            URL(string: "https://i.scdn.co/image/ab6775700000ee853b4c739f38aae7aef8620d89")!
        )

    }
    
    static let aprilUserProfileData = """
        {
            "display_name": "April",
            "external_urls": {
                "spotify": "https://open.spotify.com/user/p8gjjfbirm8ucyt82ycfi9zuu"
            },
            "followers": {
                "href": null,
                "total": 14
            },
            "href": "https://api.spotify.com/v1/users/p8gjjfbirm8ucyt82ycfi9zuu",
            "id": "p8gjjfbirm8ucyt82ycfi9zuu",
            "images": [
                {
                    "height": null,
                    "url": "https://i.scdn.co/image/ab6775700000ee853b4c739f38aae7aef8620d89",
                    "width": null
                }
            ],
            "type": "user",
            "uri": "spotify:user:p8gjjfbirm8ucyt82ycfi9zuu"
        }
        """.data(using: .utf8)!

}
