import Foundation


/**
 Used in the ``SpotifyAPI/reorderPlaylistItems(_:body:)`` request to reorder a
 playlist's items.
 
 Read more at the [Spotify web API reference][1].
 
 The body of the request contains the following properties:
 
 * rangeStart: The position of the first item to be reordered.
 * rangeLength: The amount of items to be reordered. Defaults to 1. The range of
   items to be reordered begins from the ``rangeStart`` position (inclusive),
   and includes the ``rangeLength`` subsequent items. For example, if
   ``rangeLength`` is 1, then the item at index ``rangeStart`` will be inserted
   before the item at index ``insertBefore``.
 * insertBefore: The position where the items should be inserted.
 * snapshotId: The version identifier for the current playlist.
 
 **Examples:**
 
 To reorder the first item to the last position in a playlist with 10 items, set
 ``rangeStart`` to 0, set ``rangeLength`` to 1 (default) and ``insertBefore`` to
 10.
 
 To reorder the last item in a playlist with 10 items to the start of the
 playlist, set ``rangeStart`` to 9, set ``rangeLength`` to 1 (default) and set
 ``insertBefore`` to 0.

 To move the items at index 9-10 to the start of the playlist, set
 ``rangeStart`` to 9, set ``rangeLength`` to 2, and set ``insertBefore`` to 0.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/reorder-or-replace-playlists-tracks
 */
public struct ReorderPlaylistItems: Hashable {
    
    /// The position of the first item to be reordered.
    public var rangeStart: Int
    
    /**
     The amount of items to be reordered. Defaults to 1.
     
     The range of items to be reordered begins from the ``rangeStart`` position
     (inclusive), and includes ``rangeLength`` subsequent items.

     For example, if ``rangeLength`` is 1, then the item at index ``rangeStart``
     will be inserted before the item at index ``insertBefore``.

     **Example:**
     
     To move the items at index 9-10 to the start of the playlist, set
     ``rangeStart`` to 9, set ``rangeLength`` to 2, and set ``insertBefore`` to
     0.
     */
    public var rangeLength: Int
    
    /**
     The position where the items should be inserted.

     To reorder the items to the end of the playlist, simply set
     ``insertBefore`` to the position after the last item.

     **Examples:**

     To reorder the first item to the last position in a playlist with 10 items,
     set ``rangeStart`` to 0, set ``rangeLength`` to 1 (default) and
     ``insertBefore`` to 10.

     To reorder the last item in a playlist with 10 items to the start of the
     playlist, set ``rangeStart`` to 9, set ``rangeLength`` to 1 (default) and
     set ``insertBefore`` to 0.
     */
    public var insertBefore: Int
    
    /**
     The version identifier for the current playlist.

     Every time the playlist changes, a new [snapshot id][1] is generated. You
     can use this value to efficiently determine whether a playlist has changed
     since the last time you retrieved it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    public var snapshotId: String?
    
    /**
     Creates an instance that contains details about tracks/episodes in a
     playlist that need to be reordered.

     To reorder the first item to the last position in a playlist with 10 items,
     set ``rangeStart`` to 0, set ``rangeLength`` to 1 (default) and
     ``insertBefore`` to 10.

     To reorder the last item in a playlist with 10 items to the start of the
     playlist, set ``rangeStart`` to 9, set ``rangeLength`` to 1 (default) and
     set ``insertBefore`` to 0.

     To move the items at index 9-10 to the start of the playlist, set
     ``rangeStart`` to 9, set ``rangeLength`` to 2, and set ``insertBefore`` to
     0.
     
     Read more at the [Spotify web API reference][1]
     
     - Parameters:
       - rangeStart: The position of the first item to be reordered.
       - rangeLength: The amount of items to be reordered. Defaults to 1. The
             range of items to be reordered begins from the ``rangeStart``
             position (inclusive), and includes ``rangeLength`` subsequent
             items. For example, if ``rangeLength`` is 1, then the item at index
             ``rangeStart`` will be inserted before the item at index
             ``insertBefore``.
       - insertBefore: The position where the items should be inserted.
       - snapshotId: The version identifier for the current playlist.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/reorder-or-replace-playlists-tracks
     */
    public init(
        rangeStart: Int,
        rangeLength: Int = 1,
        insertBefore: Int,
        snapshotId: String? = nil
    ) {
        self.rangeStart = rangeStart
        self.rangeLength = rangeLength
        self.insertBefore = insertBefore
        self.snapshotId = snapshotId
        
    }

}

extension ReorderPlaylistItems: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case rangeStart = "range_start"
        case rangeLength = "range_length"
        case insertBefore = "insert_before"
        case snapshotId = "snapshot_id"
    }
    
}
