# Object Model Samples

Sample versions of some of the objects in the object model.

## Overview

Each of the sample objects are defined as static properties of type `Self` on the types listed below. For example, `Track` has a static property called `because` which contains the song "Because" by The Beatles. 

These sample data are particularly useful in SwiftUI previews:

```swift
struct TrackView_Previews: PreviewProvider {
    
    static let tracks: [Track] = [
        .because, .comeTogether, .faces,
        .illWind, .odeToViceroy, .reckoner,
        .theEnd, .time
    ]

    static var previews: some View {
        List(tracks, id: \.id) { track in
            TrackView(track: track)
        }
        .environmentObject(Spotify())
    }
}
```

## Sample Objects

### Track

* `because`
* `comeTogether`
* `faces`
* `illWind`
* `odeToViceroy`
* `reckoner`
* `theEnd`
* `time`

### Album

* `abbeyRoad`
* `darkSideOfTheMoon`
* `inRainbows`
* `jinx`
* `meddle`
* `skiptracing`

### Artist

* `crumb`
* `levitationRoom`
* `pinkFloyd`
* `radiohead`
* `skinshape`
* `theBeatles`

### Episode

* `seanCarroll111`
* `seanCarroll112`
* `samHarris213`
* `samHarris214`
* `samHarris215`

### Show

* `seanCarroll`
* `samHarris`
* `joeRogan`

##  Audiobook

* `harryPotterAndTheSorcerersStone`
* `enlightenmentNow`
* `freeWill`

## AudiobookChapter

* `freeWillChapter1`
* `steveJobsChapter1`
* `enlightenmentNowChapter3`

### SpotifyUser

* `sampleCurrentUserProfile`

### PlaylistItem

* `samHarris216`
* `samHarris217`
* `joeRogan1536`
* `joeRogan1537`
* `oceanBloom`
* `echoesAcousticVersion`
* `killshot`

### PlaylistTracks

* `thisIsJimiHendrix`
* `thisIsPinkFloyd`
* `thisIsMacDeMarco`
* `thisIsSpoon`
* `bluesClassics`

### PlaylistItems

* `thisIsStevieRayVaughan`

### Playlist<PlaylistItems>

* `episodesAndLocalTracks`
* `crumb`

### Playlist<PlaylistItemsReference>

* `lucyInTheSkyWithDiamonds`
* `thisIsMFDoom`
* `rockClassics`
* `thisIsSonicYouth`
* `thisIsRadiohead`
* `thisIsSkinshape`
* `modernPsychedelia`
* `thisIsMildHighClub`
* `menITrust`

### PagingObject<Playlist<PlaylistItemsReference>>

* `sampleCategoryPlaylists`

### FeaturedPlaylists

* `sampleFeaturedPlaylists`

### SearchResult

* `queryCrumb`


### SpotifyCategory

* `sampleCategories`

### PagingObject<Track>

* `jinxTracks`

### PagingObject<SavedAlbum>

* `sampleCurrentUserSavedAlbums`

### AudioAnalysis

* `anyColourYouLike`

### AudioFeatures

* `fearless`

### CursorPagingObject<PlayHistory>

* `sampleRecentlyPlayed`

### CurrentlyPlayingContext

* `sampleCurrentPlayback`

### SpotifyQueue

* `sampleQueue`




