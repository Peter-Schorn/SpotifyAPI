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
        XCTAssertEqual(Album.abbeyRoad.name, "Abbey Road (Remastered)")
        print(Album.darkSideOfTheMoon, to: &sink)
        XCTAssertEqual(
            Album.darkSideOfTheMoon.name,
            "The Dark Side of the Moon"
        )
        print(Album.inRainbows, to: &sink)
        XCTAssertEqual(Album.inRainbows.name, "In Rainbows")
        print(Album.jinx, to: &sink)
        XCTAssertEqual(Album.jinx.name, "Jinx")
        print(Album.meddle, to: &sink)
        XCTAssertEqual(Album.meddle.name, "Meddle")
        print(Album.skiptracing, to: &sink)
        XCTAssertEqual(Album.skiptracing.name, "Skiptracing")
    }

    func testArtists() {
        print(Artist.crumb, to: &sink)
        XCTAssertEqual(Artist.crumb.name, "Crumb")
        print(Artist.levitationRoom, to: &sink)
        XCTAssertEqual(Artist.levitationRoom.name, "levitation room")
        print(Artist.pinkFloyd, to: &sink)
        XCTAssertEqual(Artist.pinkFloyd.name, "Pink Floyd")
        print(Artist.radiohead, to: &sink)
        XCTAssertEqual(Artist.radiohead.name, "Radiohead")
        print(Artist.skinshape, to: &sink)
        XCTAssertEqual(Artist.skinshape.name, "Skinshape")
        print(Artist.theBeatles, to: &sink)
        XCTAssertEqual(Artist.theBeatles.name, "The Beatles")
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
        XCTAssertEqual(
            Episode.seanCarroll111.name,
            "111 | Nick Bostrom on Anthropic Selection and Living in a Simulation"
        )
        print(Episode.seanCarroll112, to: &sink)
        XCTAssertEqual(
            Episode.seanCarroll112.name,
           "112 | Fyodor Urnov on Gene Editing, CRISPR, and Human Engineering"
        )
        print(Episode.samHarris213, to: &sink)
        XCTAssertEqual(
            Episode.samHarris213.name,
            "#213 — The Worst Epidemic"
        )
        print(Episode.samHarris214, to: &sink)
        XCTAssertEqual(
            Episode.samHarris214.name,
            "#214 — August 13, 2020"
        )
        print(Episode.samHarris215, to: &sink)
        XCTAssertEqual(
            Episode.samHarris215.name,
            "#215 — August 21, 2020"
        )
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
        XCTAssertEqual(Playlist.episodesAndLocalTracks.name, "Local Songs")
        print(Playlist.crumb, to: &sink)
        XCTAssertEqual(Playlist.crumb.name, "Crumb")
        print(Playlist.lucyInTheSkyWithDiamonds, to: &sink)
        XCTAssertEqual(
            Playlist.lucyInTheSkyWithDiamonds.name,
            "Lucy in the sky with diamonds"
        )
        print(Playlist.thisIsMFDoom, to: &sink)
        XCTAssertEqual(
            Playlist.thisIsMFDoom.name,
            "This Is MF DOOM"
        )
        print(Playlist.rockClassics, to: &sink)
        XCTAssertEqual(
            Playlist.rockClassics.name,
            "Rock Classics"
        )
        print(Playlist.thisIsSonicYouth, to: &sink)
        XCTAssertEqual(
            Playlist.thisIsSonicYouth.name,
            "This Is: Sonic Youth"
        )
        print(Playlist.thisIsRadiohead, to: &sink)
        XCTAssertEqual(
            Playlist.thisIsRadiohead.name,
            "This Is Radiohead"
        )
        print(Playlist.thisIsSkinshape, to: &sink)
        XCTAssertEqual(
            Playlist.thisIsSkinshape.name,
            "This is: Skinshape"
        )
        print(Playlist.modernPsychedelia, to: &sink)
        XCTAssertEqual(
            Playlist.modernPsychedelia.name,
            "Modern Psychedelia"
        )
        print(Playlist.thisIsMildHighClub, to: &sink)
        XCTAssertEqual(
            Playlist.thisIsMildHighClub.name,
            "This Is Mild High Club"
        )
        print(Playlist.menITrust, to: &sink)
        XCTAssertEqual(
            Playlist.menITrust.name,
            "Men I Trust"
        )
        
    }
    
    func testPlaylistItems() {
        print(PlaylistItem.samHarris216, to: &sink)
         XCTAssertEqual(
            PlaylistItem.samHarris216.name,
            "#216 — September 3, 2020"
         )
        print(PlaylistItem.samHarris217, to: &sink)
        XCTAssertEqual(
            PlaylistItem.samHarris217.name,
            "#217 — The New Religion of Anti-Racism"
        )
        print(PlaylistItem.joeRogan1536, to: &sink)
        XCTAssertEqual(
            PlaylistItem.joeRogan1536.name,
            "#1536 - Edward Snowden"
        )
        print(PlaylistItem.joeRogan1537, to: &sink)
        XCTAssertEqual(
            PlaylistItem.joeRogan1537.name,
            "#1537 - Lex Fridman"
        )
        print(PlaylistItem.oceanBloom, to: &sink)
        XCTAssertEqual(
            PlaylistItem.oceanBloom.name,
            "Hans Zimmer & Radiohead - Ocean Bloom (full song HQ)"
        )
        print(PlaylistItem.echoesAcousticVersion, to: &sink)
        XCTAssertEqual(
            PlaylistItem.echoesAcousticVersion.name,
            "Echoes - Acoustic Version"
        )
        print(PlaylistItem.killshot, to: &sink)
        XCTAssertEqual(
            PlaylistItem.killshot.name,
            "Killshot"
        )
    }
    
    func testSearch() {
        print(SearchResult.queryCrumb, to: &sink)
    }
    
    func testShows() {
        print(Show.seanCarroll, to: &sink)
        XCTAssertEqual(
            Show.seanCarroll.name,
            "Sean Carroll's Mindscape: Science, Society, Philosophy, Culture, Arts, and Ideas"
        )
        print(Show.samHarris, to: &sink)
        XCTAssertEqual(Show.samHarris.name, "Making Sense with Sam Harris")
        print(Show.joeRogan, to: &sink)
        XCTAssertEqual(Show.joeRogan.name, "The Joe Rogan Experience")
    }

    func testTracks() {
        print(Track.because, to: &sink)
        XCTAssertEqual(Track.because.name, "Because - Remastered 2009")
        print(Track.comeTogether, to: &sink)
        XCTAssertEqual(Track.comeTogether.name, "Come Together - Remastered 2009")
        print(Track.faces, to: &sink)
        XCTAssertEqual(Track.faces.name, "Faces")
        print(Track.illWind, to: &sink)
        XCTAssertEqual(Track.illWind.name, "Ill Wind")
        print(Track.odeToViceroy, to: &sink)
        XCTAssertEqual(Track.odeToViceroy.name, "Ode To Viceroy")
        print(Track.reckoner, to: &sink)
        XCTAssertEqual(Track.reckoner.name, "Reckoner")
        print(Track.theEnd, to: &sink)
        XCTAssertEqual(Track.theEnd.name, "The End - Remastered 2009")
        print(Track.time, to: &sink)
        XCTAssertEqual(Track.time.name, "Time")
        print(PagingObject.jinxTracks, to: &sink)
    }
 
    func testUserProfile() {
        print(SpotifyUser.sampleCurrentUserProfile, to: &sink)
    }

    // print(<#type#>.<#property#>, to: &sink)
    // XCTAssertEqual(Playlist.<#name#>.name, "<#name#>")
    
}

