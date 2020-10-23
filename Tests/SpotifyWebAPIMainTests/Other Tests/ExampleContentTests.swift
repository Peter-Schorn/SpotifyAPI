import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent

/// Ensure that the example content is correctly decoded from JSON
/// without errors.
final class ExampleContentTests: XCTestCase {
    
    var sink = ""
    
    static var allTests = [
        ("testAlbums", testAlbums),
        ("testArtists", testArtists),
        ("testAadioAnalysis", testAadioAnalysis),
        ("testAudioFeatures", testAudioFeatures),
        ("testBrowse", testBrowse),
        ("testEpisodes", testEpisodes),
        ("testLibrary", testLibrary),
        ("testPlayer", testPlayer),
        ("testPlaylists", testPlaylists),
        ("testSearch", testSearch),
        ("testShows", testShows),
        ("testTracks", testTracks),
        ("testUserProfile", testUserProfile)
    ]
    
    func testAlbums() {
        print(Album.abbeyRoad, to: &sink)
        print(Album.darkSideOfTheMoon, to: &sink)
        print(Album.inRainbows, to: &sink)
        print(Album.jinx, to: &sink)
        print(Album.meddle, to: &sink)
        print(Album.skiptracing, to: &sink)
    }

    func testArtists() {
        print(Artist.crumb, to: &sink)
        print(Artist.levitationRoom, to: &sink)
        print(Artist.pinkFloyd, to: &sink)
        print(Artist.radiohead, to: &sink)
        print(Artist.skinshape, to: &sink)
        print(Artist.theBeatles, to: &sink)
    }
    
    func testAadioAnalysis() {
        print(AudioAnalysis.anyColourYouLike, to: &sink)
    }
    
    func testAudioFeatures() {
        print(AudioFeatures.fearless, to: &sink)
    }
    
    func testBrowse() {
        print(PagingObject.sampleCategoryPlaylists, to: &sink)
        print(FeaturedPlaylists.sampleFeaturedPlaylists, to: &sink)
        print(SpotifyCategory.sampleCategories, to: &sink)
    }
    
    func testEpisodes() {
        print(Episode.seanCarroll111, to: &sink)
        print(Episode.seanCarroll112, to: &sink)
        print(Episode.samHarris213, to: &sink)
        print(Episode.samHarris214, to: &sink)
        print(Episode.samHarris215, to: &sink)
    }
    
    func testLibrary() {
        print(PagingObject.sampleCurrentUserSavedAlbums, to: &sink)
    }
    
    func testPlayer() {
        print(CursorPagingObject.sampleRecentlyPlayed, to: &sink)
        print(CurrentlyPlayingContext.sampleCurrentPlayback, to: &sink)
    }
    
    func testPlaylists() {
        print(PagingObject.thisIsJimiHendrix, to: &sink)
        print(PagingObject.thisIsPinkFloyd, to: &sink)
        print(PagingObject.thisIsMacDeMarco, to: &sink)
        print(PagingObject.thisIsSpoon, to: &sink)
        print(PagingObject.bluesClassics, to: &sink)
        
        print(PagingObject.thisIsStevieRayVaughan, to: &sink)

        print(Playlist.episodesAndLocalTracks, to: &sink)
        print(Playlist.crumb, to: &sink)
        
        print(Playlist.lucyInTheSkyWithDiamonds, to: &sink)
        print(Playlist.thisIsMFDoom, to: &sink)
        print(Playlist.rockClassics, to: &sink)
        print(Playlist.thisIsSonicYouth, to: &sink)
        print(Playlist.thisIsRadiohead, to: &sink)
        print(Playlist.thisIsSkinshape, to: &sink)
        print(Playlist.modernPsychedelia, to: &sink)
        print(Playlist.thisIsMildHighClub, to: &sink)
        print(Playlist.menITrust, to: &sink)
        
    }
    
    func testPlaylistItems() {
        print(PlaylistItem.samHarris216, to: &sink)
        print(PlaylistItem.samHarris217, to: &sink)
        print(PlaylistItem.joeRogan1536, to: &sink)
        print(PlaylistItem.joeRogan1537, to: &sink)
        print(PlaylistItem.oceanBloom, to: &sink)
        print(PlaylistItem.echoesAcousticVersion, to: &sink)
        print(PlaylistItem.killshot, to: &sink)
    }
    
    func testSearch() {
        print(SearchResult.queryCrumb, to: &sink)
    }
    
    func testShows() {
        print(Show.seanCarroll, to: &sink)
        print(Show.samHarris, to: &sink)
        print(Show.joeRogan, to: &sink)
    }

    func testTracks() {
        print(Track.because, to: &sink)
        print(Track.comeTogether, to: &sink)
        print(Track.faces, to: &sink)
        print(Track.illWind, to: &sink)
        print(Track.odeToViceroy, to: &sink)
        print(Track.reckoner, to: &sink)
        print(Track.theEnd, to: &sink)
        print(Track.time, to: &sink)
        print(PagingObject.jinxTracks, to: &sink)
    }
 
    func testUserProfile() {
        print(SpotifyUser.sampleCurrentUserProfile, to: &sink)
    }

    // print(<#type#>.<#property#>, to: &sink)
    
}
