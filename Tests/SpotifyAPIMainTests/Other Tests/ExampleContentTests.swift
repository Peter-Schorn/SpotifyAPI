import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent
import SpotifyAPITestUtilities

/// Ensure that the example content is correctly decoded from JSON
/// without errors.
final class ExampleContentTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testAlbums", testAlbums),
        ("testArtists", testArtists),
        ("testAudioAnalysis", testAudioAnalysis),
        ("testAudioFeatures", testAudioFeatures),
        ("testAudiobooks", testAudiobooks),
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
        encodeDecode(Album.abbeyRoad)
        XCTAssertEqual(Album.abbeyRoad.name, "Abbey Road (Remastered)")
        encodeDecode(Album.darkSideOfTheMoon)
        XCTAssertEqual(
            Album.darkSideOfTheMoon.name,
            "The Dark Side of the Moon"
        )
        encodeDecode(Album.inRainbows)
        XCTAssertEqual(Album.inRainbows.name, "In Rainbows")
        encodeDecode(Album.jinx)
        XCTAssertEqual(Album.jinx.name, "Jinx")
        encodeDecode(Album.meddle)
        XCTAssertEqual(Album.meddle.name, "Meddle")
        encodeDecode(Album.skiptracing)
        XCTAssertEqual(Album.skiptracing.name, "Skiptracing")
    }

    func testArtists() {
        encodeDecode(Artist.crumb, areEqual: ==)
        XCTAssertEqual(Artist.crumb.name, "Crumb")
        encodeDecode(Artist.levitationRoom, areEqual: ==)
        XCTAssertEqual(Artist.levitationRoom.name, "levitation room")
        encodeDecode(Artist.pinkFloyd, areEqual: ==)
        XCTAssertEqual(Artist.pinkFloyd.name, "Pink Floyd")
        encodeDecode(Artist.radiohead, areEqual: ==)
        XCTAssertEqual(Artist.radiohead.name, "Radiohead")
        encodeDecode(Artist.skinshape, areEqual: ==)
        XCTAssertEqual(Artist.skinshape.name, "Skinshape")
        encodeDecode(Artist.theBeatles, areEqual: ==)
        XCTAssertEqual(Artist.theBeatles.name, "The Beatles")
    }
    
    func testAudioAnalysis() {
        encodeDecode(AudioAnalysis.anyColourYouLike)
    }
    
    func testAudioFeatures() {
        encodeDecode(AudioFeatures.fearless)
    }
    
    func testAudiobooks() {
        
        encodeDecode(Audiobook.harryPotterAndTheSorcerersStone)
        XCTAssertEqual(
            Audiobook.harryPotterAndTheSorcerersStone.name,
            "Harry Potter and the Sorcerer's Stone"
        )
        encodeDecode(Audiobook.enlightenmentNow)
        XCTAssertEqual(
            Audiobook.enlightenmentNow.name,
            "Enlightenment Now: The Case for Reason, Science, Humanism, and Progress"
        )
        encodeDecode(Audiobook.freeWill)
        XCTAssertEqual(Audiobook.freeWill.name, "Free Will")
        
        encodeDecode(AudiobookChapter.freeWillChapter1)
        XCTAssertEqual(
            AudiobookChapter.freeWillChapter1.name,
            "Chapter 1"
        )
        XCTAssertEqual(
            AudiobookChapter.freeWillChapter1.audiobook?.name,
            "Free Will"
        )
        
        encodeDecode(AudiobookChapter.steveJobsChapter1)
        XCTAssertEqual(
            AudiobookChapter.steveJobsChapter1.name,
            "Chapter 1"
        )
        XCTAssertEqual(
            AudiobookChapter.steveJobsChapter1.audiobook?.name,
            "Steve Jobs"
        )

        encodeDecode(AudiobookChapter.enlightenmentNowChapter3)
        XCTAssertEqual(
            AudiobookChapter.enlightenmentNowChapter3.name,
            "Chapter 3"
        )
        XCTAssertEqual(
            AudiobookChapter.enlightenmentNowChapter3.audiobook?.name,
            "Enlightenment Now: The Case for Reason, Science, Humanism, and Progress"
        )
        
    }

    func testBrowse() {
        encodeDecode(PagingObject.sampleCategoryPlaylists, areEqual: ==)
        encodeDecode(FeaturedPlaylists.sampleFeaturedPlaylists, areEqual: ==)
        encodeDecode(SpotifyCategory.sampleCategories, areEqual: ==)
    }
    
    func testEpisodes() {
        encodeDecode(Episode.seanCarroll111)
        XCTAssertEqual(
            Episode.seanCarroll111.name,
            "111 | Nick Bostrom on Anthropic Selection and Living in a Simulation"
        )
        encodeDecode(Episode.seanCarroll112)
        XCTAssertEqual(
            Episode.seanCarroll112.name,
           "112 | Fyodor Urnov on Gene Editing, CRISPR, and Human Engineering"
        )
        encodeDecode(Episode.samHarris213)
        XCTAssertEqual(
            Episode.samHarris213.name,
            "#213 — The Worst Epidemic"
        )
        encodeDecode(Episode.samHarris214)
        XCTAssertEqual(
            Episode.samHarris214.name,
            "#214 — August 13, 2020"
        )
        encodeDecode(Episode.samHarris215)
        XCTAssertEqual(
            Episode.samHarris215.name,
            "#215 — August 21, 2020"
        )
    }
    
    func testLibrary() {
        encodeDecode(PagingObject.sampleCurrentUserSavedAlbums)
    }
    
    func testPlayer() {
        encodeDecode(CursorPagingObject.sampleRecentlyPlayed)
        encodeDecode(CurrentlyPlayingContext.sampleCurrentPlayback)
        encodeDecode(SpotifyQueue.sampleQueue)
    }
    
    func testPlaylists() {
        encodeDecode(PagingObject.thisIsJimiHendrix, areEqual: ==)
        encodeDecode(PagingObject.thisIsPinkFloyd, areEqual: ==)
        encodeDecode(PagingObject.thisIsMacDeMarco, areEqual: ==)
        encodeDecode(PagingObject.thisIsSpoon, areEqual: ==)
        encodeDecode(PagingObject.bluesClassics, areEqual: ==)
        
        encodeDecode(PagingObject.thisIsStevieRayVaughan, areEqual: ==)

        encodeDecode(Playlist.episodesAndLocalTracks, areEqual: ==)
        XCTAssertEqual(Playlist.episodesAndLocalTracks.name, "Local Songs")
        encodeDecode(Playlist.crumb, areEqual: ==)
        XCTAssertEqual(Playlist.crumb.name, "Crumb")
        encodeDecode(Playlist.lucyInTheSkyWithDiamonds, areEqual: ==)
        XCTAssertEqual(
            Playlist.lucyInTheSkyWithDiamonds.name,
            "Lucy in the sky with diamonds"
        )
        encodeDecode(Playlist.thisIsMFDoom, areEqual: ==)
        XCTAssertEqual(
            Playlist.thisIsMFDoom.name,
            "This Is MF DOOM"
        )
        encodeDecode(Playlist.rockClassics, areEqual: ==)
        XCTAssertEqual(
            Playlist.rockClassics.name,
            "Rock Classics"
        )
        encodeDecode(Playlist.thisIsSonicYouth, areEqual: ==)
        XCTAssertEqual(
            Playlist.thisIsSonicYouth.name,
            "This Is: Sonic Youth"
        )
        encodeDecode(Playlist.thisIsRadiohead, areEqual: ==)
        XCTAssertEqual(
            Playlist.thisIsRadiohead.name,
            "This Is Radiohead"
        )
        encodeDecode(Playlist.thisIsSkinshape, areEqual: ==)
        XCTAssertEqual(
            Playlist.thisIsSkinshape.name,
            "This is: Skinshape"
        )
        encodeDecode(Playlist.modernPsychedelia, areEqual: ==)
        XCTAssertEqual(
            Playlist.modernPsychedelia.name,
            "Modern Psychedelia"
        )
        encodeDecode(Playlist.thisIsMildHighClub, areEqual: ==)
        XCTAssertEqual(
            Playlist.thisIsMildHighClub.name,
            "This Is Mild High Club"
        )
        encodeDecode(Playlist.menITrust, areEqual: ==)
        XCTAssertEqual(
            Playlist.menITrust.name,
            "Men I Trust"
        )
        
    }
    
    func testPlaylistItems() {
        encodeDecode(PlaylistItem.samHarris216)
         XCTAssertEqual(
            PlaylistItem.samHarris216.name,
            "#216 — September 3, 2020"
         )
        encodeDecode(PlaylistItem.samHarris217)
        XCTAssertEqual(
            PlaylistItem.samHarris217.name,
            "#217 — The New Religion of Anti-Racism"
        )
        encodeDecode(PlaylistItem.joeRogan1536)
        XCTAssertEqual(
            PlaylistItem.joeRogan1536.name,
            "#1536 - Edward Snowden"
        )
        encodeDecode(PlaylistItem.joeRogan1537)
        XCTAssertEqual(
            PlaylistItem.joeRogan1537.name,
            "#1537 - Lex Fridman"
        )
        encodeDecode(PlaylistItem.oceanBloom)
        XCTAssertEqual(
            PlaylistItem.oceanBloom.name,
            "Hans Zimmer & Radiohead - Ocean Bloom (full song HQ)"
        )
        encodeDecode(PlaylistItem.echoesAcousticVersion)
        XCTAssertEqual(
            PlaylistItem.echoesAcousticVersion.name,
            "Echoes - Acoustic Version"
        )
        encodeDecode(PlaylistItem.killshot)
        XCTAssertEqual(
            PlaylistItem.killshot.name,
            "Killshot"
        )
    }
    
    func testSearch() {
        encodeDecode(SearchResult.queryCrumb)
    }
    
    func testShows() {
        encodeDecode(Show.seanCarroll)
        XCTAssertEqual(
            Show.seanCarroll.name,
            "Sean Carroll's Mindscape: Science, Society, Philosophy, Culture, Arts, and Ideas"
        )
        encodeDecode(Show.samHarris)
        XCTAssertEqual(Show.samHarris.name, "Making Sense with Sam Harris")
        encodeDecode(Show.joeRogan)
        XCTAssertEqual(Show.joeRogan.name, "The Joe Rogan Experience")
    }

    func testTracks() {
        encodeDecode(Track.because)
        XCTAssertEqual(Track.because.name, "Because - Remastered 2009")
        encodeDecode(Track.comeTogether)
        XCTAssertEqual(Track.comeTogether.name, "Come Together - Remastered 2009")
        encodeDecode(Track.faces)
        XCTAssertEqual(Track.faces.name, "Faces")
        encodeDecode(Track.illWind)
        XCTAssertEqual(Track.illWind.name, "Ill Wind")
        encodeDecode(Track.odeToViceroy)
        XCTAssertEqual(Track.odeToViceroy.name, "Ode To Viceroy")
        encodeDecode(Track.reckoner)
        XCTAssertEqual(Track.reckoner.name, "Reckoner")
        encodeDecode(Track.theEnd)
        XCTAssertEqual(Track.theEnd.name, "The End - Remastered 2009")
        encodeDecode(Track.time)
        XCTAssertEqual(Track.time.name, "Time")
        encodeDecode(PagingObject.jinxTracks)
    }
 
    func testUserProfile() {
        encodeDecode(SpotifyUser.sampleCurrentUserProfile, areEqual: ==)
    }

}

