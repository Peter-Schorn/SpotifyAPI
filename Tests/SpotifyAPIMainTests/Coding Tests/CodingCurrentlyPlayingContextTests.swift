import Foundation
import XCTest
import RegularExpressions
import SpotifyWebAPI
import SpotifyAPITestUtilities


final class CodingCurrentlyPlayingContextTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testCodingCurrentlyPlayingContext", testCodingCurrentlyPlayingContext),
    ]
    
    /// Ensures that `CurrentlyPlayingContext` can be decoded, encoded,
    /// and re-decoded without losing information.
    func testCodingCurrentlyPlayingContext() throws {
        
        let dataString = decodeEncodeDecode(
            Self.currentlyPlayingContextData,
            type: CurrentlyPlayingContext.self
        )
        XCTAssertNotNil(dataString)
        XCTAssertNotNil(dataString?.data(using: .utf8))
        
        let context = try JSONDecoder().decode(
            CurrentlyPlayingContext.self,
            from: Self.currentlyPlayingContextData
        )
        
        try checkContext(context)
        
        let reencodedData = try JSONEncoder().encode(context)
        let redecodedContext = try JSONDecoder().decode(
            CurrentlyPlayingContext.self,
            from: reencodedData
        )
        
        try checkContext(redecodedContext)
        
        
    }
    
    func checkContext(_ context: CurrentlyPlayingContext) throws {
        
        XCTAssertEqual(context.device.id, "ced8d42d0a3830065dfbf4800352d23a96b76fd4")
        XCTAssertTrue(context.device.isActive)
        XCTAssertFalse(context.device.isPrivateSession)
        XCTAssertFalse(context.device.isRestricted)
        XCTAssertEqual(context.device.name, "Peter’s MacBook Pro")
        XCTAssertEqual(context.device.type, .computer)
        XCTAssertEqual(context.device.volumePercent, 100)
        XCTAssertFalse(context.shuffleIsOn)
        XCTAssertEqual(context.repeatState, .context)
        let expectedTimestamp = Date.init(millisecondsSince1970: 1598344731322)
        let difference = abs(
            context.timestamp.timeIntervalSince1970 -
            expectedTimestamp.timeIntervalSince1970
        )
        XCTAssert(
            difference <= 2,
            "expected: \(expectedTimestamp.description(with: .current)); " +
            "received: \(context.timestamp.description(with: .current))"
        )
        XCTAssertEqual(
            context.context?.externalURLs,
            [
                "spotify": URL(string: "https://open.spotify.com/playlist/2EgZjzog2eSfApWQHZVn6t")!
            ]
        )
        XCTAssertEqual(
            context.context?.href,
            URL(string: "https://api.spotify.com/v1/playlists/2EgZjzog2eSfApWQHZVn6t")!
        )
        XCTAssertEqual(context.context?.type, .playlist)
        XCTAssertEqual(
            context.context?.uri,
            "spotify:user:petervschorn:playlist:2EgZjzog2eSfApWQHZVn6t"
        )
        XCTAssertEqual(context.progressMS, 11467)
        XCTAssertEqual(context.itemType, .track)
        let expectedAllowedActions: Set<PlaybackActions> = [
            .interruptPlayback,
            .pause,
            .seek,
            .skipToNext,
            .skipToPrevious,
            .toggleRepeatContext,
            .toggleRepeatTrack,
            .toggleShuffle,
            .transferPlayback
        ]
        // disallows: resuming
        XCTAssertEqual(context.allowedActions, expectedAllowedActions)
        XCTAssertTrue(context.isPlaying)
        
        // MARK: Check Track
        
        guard let playlistItem = context.item else {
            XCTFail("currentlyPlayingItem should not be nil")
            return
        }
        XCTAssertEqual(playlistItem.name, "Found Me")
        XCTAssertEqual(playlistItem.uri, "spotify:track:4m0dj1HxXzFlnIqPkomXQB")
        XCTAssertEqual(playlistItem.id, "4m0dj1HxXzFlnIqPkomXQB")
        XCTAssertEqual(playlistItem.type, .track)
        XCTAssertEqual(playlistItem.durationMS, 211961)
        XCTAssertNil(playlistItem.isPlayable)
        guard case .track(let track) = playlistItem else {
            XCTFail("PlaylistItem should be .track")
            return
        }
        
        XCTAssertEqual(track.name, "Found Me")
        XCTAssertEqual(track.uri, "spotify:track:4m0dj1HxXzFlnIqPkomXQB")
        XCTAssertEqual(track.durationMS, 211961)
        XCTAssertNil(track.isPlayable)
        XCTAssertEqual(track.popularity, 47)
        
        XCTAssertEqual(track.album?.name, "Oncle Jazz")
        XCTAssertEqual(
            track.album?.uri, "spotify:album:4W4gNYa4tt3t8V6FmONWEK"
        )
        XCTAssertEqual(
            track.previewURL,
            URL(string: "https://p.scdn.co/mp3-preview/b87069f9d4bdf4273d9178ff86d97af05e2adbb7?cid=774b29d4f13844c495f206cafdad9c86")!
        )
        
        // MARK: Check Album
        
        let album = try XCTUnwrap(track.album)
        XCTAssertEqual(album.type, .album)
        XCTAssertEqual(album.availableMarkets, ["AD", "AE", "ZA"])
        XCTAssertEqual(
            album.externalURLs,
            [
                "spotify": URL(string: "https://open.spotify.com/album/4W4gNYa4tt3t8V6FmONWEK")!
            ]
        )
        XCTAssertEqual(
            album.href,
            URL(string: "https://api.spotify.com/v1/albums/4W4gNYa4tt3t8V6FmONWEK")!
        )
        XCTAssertEqual(album.id, "4W4gNYa4tt3t8V6FmONWEK")
        
        XCTAssertEqual(album.releaseDatePrecision, "day")
        XCTAssertEqual(album.uri, "spotify:album:4W4gNYa4tt3t8V6FmONWEK")
        
        if let releaseDate = album.releaseDate {
            XCTAssertEqual(
                releaseDate.timeIntervalSince1970,
                1568332800,
                accuracy: 43_200  // 12 hours
            )
        }
        else {
            XCTFail("release date should not be nil")
        }
        
        let albumImages = try XCTUnwrap(album.images)
        XCTAssertEqual(albumImages[0].height, 640)
        XCTAssertEqual(albumImages[0].width, 641)
        XCTAssertEqual(
            albumImages[0].url,
            URL(string: "https://i.scdn.co/image/ab67616d0000b273412e18ab5452ac84eafe5c9d")!
        )
        
        XCTAssertEqual(albumImages[1].height, 300)
        XCTAssertEqual(albumImages[1].width, 301)
        XCTAssertEqual(
            albumImages[1].url,
            URL(string: "https://i.scdn.co/image/ab67616d00001e02412e18ab5452ac84eafe5c9d")!
        )
        
        XCTAssertEqual(albumImages[2].height, 64)
        XCTAssertEqual(albumImages[2].width, 65)
        XCTAssertEqual(
            albumImages[2].url,
            URL(string: "https://i.scdn.co/image/ab67616d00004851412e18ab5452ac84eafe5c9d")!
        )
        
        // MARK: Check Artist
        
        let artist = try XCTUnwrap(track.artists?.first)

        XCTAssertEqual(artist.name, "Men I Trust")
        XCTAssertEqual(
            artist.uri, "spotify:artist:3zmfs9cQwzJl575W1ZYXeT"
        )
        
    }
    
    static let currentlyPlayingContextData = """
        {
            "device": {
                "id": "ced8d42d0a3830065dfbf4800352d23a96b76fd4",
                "is_active": true,
                "is_private_session": false,
                "is_restricted": false,
                "name": "Peter’s MacBook Pro",
                "type": "Computer",
                "volume_percent": 100
            },
            "shuffle_state": false,
            "repeat_state": "context",
            "timestamp": 1598344731322,
            "context": {
                "external_urls": {
                    "spotify": "https://open.spotify.com/playlist/2EgZjzog2eSfApWQHZVn6t"
                },
                "href": "https://api.spotify.com/v1/playlists/2EgZjzog2eSfApWQHZVn6t",
                "type": "playlist",
                "uri": "spotify:user:petervschorn:playlist:2EgZjzog2eSfApWQHZVn6t"
            },
            "progress_ms": 11467,
            "item": {
                "album": {
                    "album_type": "album",
                    "artists": [
                        {
                            "external_urls": {
                                "spotify": "https://open.spotify.com/artist/3zmfs9cQwzJl575W1ZYXeT"
                            },
                            "href": "https://api.spotify.com/v1/artists/3zmfs9cQwzJl575W1ZYXeT",
                            "id": "3zmfs9cQwzJl575W1ZYXeT",
                            "name": "Men I Trust",
                            "type": "artist",
                            "uri": "spotify:artist:3zmfs9cQwzJl575W1ZYXeT"
                        }
                    ],
                    "available_markets": [
                        "AD",
                        "AE",
                        "ZA"
                    ],
                    "external_urls": {
                        "spotify": "https://open.spotify.com/album/4W4gNYa4tt3t8V6FmONWEK"
                    },
                    "href": "https://api.spotify.com/v1/albums/4W4gNYa4tt3t8V6FmONWEK",
                    "id": "4W4gNYa4tt3t8V6FmONWEK",
                    "images": [
                        {
                            "height": 640,
                            "url": "https://i.scdn.co/image/ab67616d0000b273412e18ab5452ac84eafe5c9d",
                            "width": 641
                        },
                        {
                            "height": 300,
                            "url": "https://i.scdn.co/image/ab67616d00001e02412e18ab5452ac84eafe5c9d",
                            "width": 301
                        },
                        {
                            "height": 64,
                            "url": "https://i.scdn.co/image/ab67616d00004851412e18ab5452ac84eafe5c9d",
                            "width": 65
                        }
                    ],
                    "name": "Oncle Jazz",
                    "release_date": "2019-09-13",
                    "release_date_precision": "day",
                    "total_tracks": 24,
                    "type": "album",
                    "uri": "spotify:album:4W4gNYa4tt3t8V6FmONWEK"
                },
                "artists": [
                    {
                        "external_urls": {
                            "spotify": "https://open.spotify.com/artist/3zmfs9cQwzJl575W1ZYXeT"
                        },
                        "href": "https://api.spotify.com/v1/artists/3zmfs9cQwzJl575W1ZYXeT",
                        "id": "3zmfs9cQwzJl575W1ZYXeT",
                        "name": "Men I Trust",
                        "type": "artist",
                        "uri": "spotify:artist:3zmfs9cQwzJl575W1ZYXeT"
                    }
                ],
                "available_markets": [
                    "AD",
                    "AE"
                ],
                "disc_number": 1,
                "duration_ms": 211961,
                "explicit": false,
                "external_ids": {
                    "isrc": "QZFZ31973923"
                },
                "external_urls": {
                    "spotify": "https://open.spotify.com/track/4m0dj1HxXzFlnIqPkomXQB"
                },
                "href": "https://api.spotify.com/v1/tracks/4m0dj1HxXzFlnIqPkomXQB",
                "id": "4m0dj1HxXzFlnIqPkomXQB",
                "is_local": false,
                "name": "Found Me",
                "popularity": 47,
                "preview_url": "https://p.scdn.co/mp3-preview/b87069f9d4bdf4273d9178ff86d97af05e2adbb7?cid=774b29d4f13844c495f206cafdad9c86",
                "track_number": 5,
                "type": "track",
                "uri": "spotify:track:4m0dj1HxXzFlnIqPkomXQB"
            },
            "currently_playing_type": "track",
            "actions": {
                "disallows": {
                    "resuming": true
                }
            },
            "is_playing": true
        }
        """.data(using: .utf8)!
    
}
