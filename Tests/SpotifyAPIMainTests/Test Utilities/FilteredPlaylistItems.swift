import Foundation
import SpotifyWebAPI

struct FilteredPlaylistItems: Codable, Equatable {
    
    /**
     The filters that must be used to retrieve the appropriate data
     for this type.
     
     ```
     "items(track.name,track.artists(name,uri,type))"
     ```
     */
    static let filters =
            "items(track.name,track.artists(name,uri,type))"
    
    let items: [FilteredItem]
    
}

struct FilteredItem: Equatable {
 
    let name: String
    let artists: [FilteredArtist]
    
}

extension FilteredItem: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let tracksContainer = try container.nestedContainer(
            keyedBy: TrackCodingKeys.self, forKey: .track
        )
        self.name = try tracksContainer.decode(
            String.self, forKey: .name
        )
        self.artists = try tracksContainer.decode(
            [FilteredArtist].self, forKey: .artists
        )
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var tracksContainer = container.nestedContainer(
            keyedBy: TrackCodingKeys.self, forKey: .track
        )
        try tracksContainer.encode(
            self.artists, forKey: .artists
        )
        try tracksContainer.encode(
            self.name, forKey: .name
        )
        
    }
    
    enum CodingKeys: String, CodingKey {
        case track
    }

    enum TrackCodingKeys: String, CodingKey {
        case artists
        case name
    }

}
