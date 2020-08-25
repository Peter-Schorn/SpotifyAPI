import XCTest
import SpotifyWebAPI
import RegularExpressions


final class CodingCurrentlyPlayingContextTests: XCTestCase {
    
    static var allTests = [
        ("testCodingCurrentlyPlayingContext", testCodingCurrentlyPlayingContext),
    ]
    
    /// Ensures that `CurrentlyPlayingContext` can be decoded, encoded,
    /// and re-decoded without losing information.
    func testCodingCurrentlyPlayingContext() throws {
        
        decodeEncodeDecode(
            Self.currentlyPlayingData,
            type: CurrentlyPlayingContext.self
        )
        
    }
    
    static var currentlyPlayingData: Data {
        """
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
                            "width": 640
                        },
                        {
                            "height": 300,
                            "url": "https://i.scdn.co/image/ab67616d00001e02412e18ab5452ac84eafe5c9d",
                            "width": 300
                        },
                        {
                            "height": 64,
                            "url": "https://i.scdn.co/image/ab67616d00004851412e18ab5452ac84eafe5c9d",
                            "width": 64
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
    
}
