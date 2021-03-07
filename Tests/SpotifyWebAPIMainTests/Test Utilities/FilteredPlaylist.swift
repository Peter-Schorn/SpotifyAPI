import Foundation
import SpotifyWebAPI

struct FilteredPlaylist: Equatable {

    /**
     The filters that must be used to retrieve the appropriate data
     for this type.
     
     ```
     "name,uri,owner.display_name,tracks.items(track.artists(name,uri,type))"
     ```
     */
    static let filters =
            "name,uri,owner.display_name,tracks.items(track.artists(name,uri,type))"
    
    let name: String
    let uri: String
    let ownerDisplayName: String
    let tracks: [FilteredTrack]
    
}

extension FilteredPlaylist: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.uri = try container.decode(String.self, forKey: .uri)
        
        let ownerContainer = try container.nestedContainer(
            keyedBy: CodingKeys.OwnerCodingKeys.self, forKey: .owner
        )
        self.ownerDisplayName = try ownerContainer.decode(
            String.self, forKey: .displayName
        )
        
        let trackPagingObjectContainer = try container.nestedContainer(
            keyedBy: CodingKeys.TrackPagingObjectKeys.self, forKey: .tracks
        )
        
        let trackItems = try trackPagingObjectContainer.decode(
            [[String: FilteredTrack]].self, forKey: .items
        )
        self.tracks = trackItems.flatMap(\.values)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.uri, forKey: .uri)
        
        var ownerContainer = container.nestedContainer(
            keyedBy: CodingKeys.OwnerCodingKeys.self, forKey: .owner
        )
        try ownerContainer.encode(
            self.ownerDisplayName, forKey: .displayName
        )
        
        var trackPagingObjectContainer = container.nestedContainer(
            keyedBy: CodingKeys.TrackPagingObjectKeys.self, forKey: .tracks
        )
        let tracksDict = self.tracks.map { track in
            ["tracks": track]
            
        }
        try trackPagingObjectContainer.encode(
            tracksDict, forKey: .items
        )
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case owner
        case tracks
        case uri
        
        enum OwnerCodingKeys: String, CodingKey {
            case displayName = "display_name"
        }
        
        enum TrackPagingObjectKeys: String, CodingKey {
            case items
        }
        
    }

}


struct FilteredTrack: Codable, Equatable {
    
    let artists: [FilteredArtist]

}

struct FilteredArtist: Codable, Equatable {
    
    let name: String
    let type: IDCategory
    let uri: String

}
