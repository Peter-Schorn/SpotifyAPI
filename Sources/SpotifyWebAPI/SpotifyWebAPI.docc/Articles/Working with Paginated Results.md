# Working with Paginated Results

Retrieve additional pages from an endpoint that returns paginated results.

## Overview

For endpoints that deal with data that is too large to fit into a single response, such as ``SpotifyAPI/artistAlbums(_:groups:country:limit:offset:)`` and ``SpotifyAPI/recentlyPlayed(_:limit:)``, Spotify uses a ``PagingObject`` or a ``CursorPagingObject`` to split up the results into multiple pages.

This library provides several convenience methods for requesting additional pages of results from a paginated type, as well as manual methods for requesting specific individual pages.

## Requesting Additional Pages of Results Serially

**`Publisher.extendPages(_:maxExtraPages:)` and ``SpotifyAPI/extendPages(_:maxExtraPages:)``** 

This publisher extension can be chained with any publisher that returns a ``PagingObject`` or a  ``CursorPagingObject``.  It uses the `next` property of the paging object sent from the upstream publisher to request the next page of results. Each time an additional page is received, its `next` property is used to retrieve the next page of results, and so on, until `next` is `nil` or `maxExtraPages` is reached. This means that the next page will not be requested until the previous one is received and that the pages will always be returned in order.

In this example, a request is made for an artist's albums. 10 albums per page and two additional pages, for a total of three pages, are requested:

```swift
let artist = "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9"

spotifyAPI.artistAlbums(artist, country: "US", limit: 10)
    .extendPages(spotifyAPI, maxExtraPages: 2)
    .sink(
        receiveCompletion: { completion in
            print("completion: \(completion)")
        },
        receiveValue: { albumsPage in
            print(
                """

                received page of albums:
                ------------------------
                """
            )
            for album in albumsPage.items {
                print(album.name)
            }
        }
    )
    .store(in: &cancellables)
```

Output:
```
received 10 albums:
------------------------
Delicate Sound of Thunder (2019 Remix) [Live]
The Later Years
The Later Years 1987-2019
The Endless River
Pulse (Live)
The Division Bell
Delicate Sound of Thunder (Live)
A Momentary Lapse of Reason
The Final Cut
The Wall

received 10 albums:
------------------------
Animals
Wish You Were Here
The Dark Side of the Moon
Obscured by Clouds
Meddle
Atom Heart Mother
Ummagumma
More
A Saucerful of Secrets
The Piper at the Gates of Dawn

received 10 albums:
------------------------
The Great Gig in the Sky (Live at Knebworth 1990 [2021 Edit])
Shine On You Crazy Diamond (Parts 1-5) [Live at Knebworth 1990 [2021 Edit]]
On the Turning Away (Delicate Sound Of Thunder 2019 Remix [Live])
Sorrow [Live at Knebworth 1990 (2019 Mix)]
The Doctor [(Comfortably Numb) [The Wall Work In Progress, Pt. 2, 1979] [Programme 1] [Band Demo] [2011 Remastered Version]]
Raving And Drooling [Live At Wembley 1974 (2011 Mix)]
Shine On You Crazy Diamond, Pts. 1-6 [Live At Wembley 1974 (2011 Mix)]
Money (Early Mix)
Run Like Hell [The Wall Work In Progress, Pt. 2, 1979 (Programme 1) [Band Demo] [2011 Remastered Version]]
Any Colour You Like [Live At The Empire Pool, Wembley, London 1974 (2011 Remastered Version)]
completion: finished
```

## Requesting Additional Pages of Results Concurrently

**`Publisher.extendPagesConcurrently(_:maxExtraPages:)` and ``SpotifyAPI/extendPagesConcurrently(_:maxExtraPages:)``**

This publisher extension requests additional pages of results *concurrently*, which means it is much faster than the above method, which must wait for the previous page to be received before requesting the next page. **However, the order in which the pages are received is unpredictable.** If you need to wait all pages to be received before processing them, then always use this method.

In this example, the tracks and episodes in a playlist are requested. 5 items per page and 5 additional pages, for a total of 6 pages, are requested.

```swift
let playlist = "spotify:playlist:37i9dQZF1DWXRqgorJj26U"

spotifyAPI.playlistItems(playlist, limit: 5, market: "US")
    .extendPagesConcurrently(spotifyAPI, maxExtraPages: 5)
    .sink(
        receiveCompletion: { completion in
            print("completion: \(completion)")
        },
        receiveValue: { playlistItemsPage in
            print(
                """

                received \(playlistItemsPage.items.count) tracks:
                ------------------------
                """
            )
            for track in playlistItemsPage.items.compactMap(\.item) {
                print(track.name)
            }
        }
    )
    .store(in: &cancellables)
```

Output:
```
received 5 tracks:
------------------------
Whole Lotta Love - 1990 Remaster
All Along the Watchtower
Back In Black
Paint It, Black - Mono
Rebel Rebel - 2016 Remaster

received 5 tracks:
------------------------
Come Together - Remastered 2009
Should I Stay or Should I Go - Remastered
Baba O'Riley
Sweet Emotion
Another One Bites The Dust - Remastered 2011

received 5 tracks:
------------------------
Light My Fire
La Grange - 2005 Remaster
American Girl
Paradise City
House Of The Rising Sun

received 5 tracks:
------------------------
Like a Rolling Stone
Sunshine Of Your Love
Sweet Home Alabama
Fortunate Son
Another Brick in the Wall, Pt. 2

received 5 tracks:
------------------------
The Chain - 2004 Remaster
Me and Bobby McGee
Hotel California - 2013 Remaster
The Joker
Born To Be Wild - Single Version

received 5 tracks:
------------------------
For What It's Worth
More Than a Feeling
Sultans of Swing
Somebody to Love
Walk On the Wild Side
completion: finished
```

## Collecting all Pages of Results

**`Publisher.collectAndSortByOffset()`**

This publisher waits for all pages to be received and then sorts them based on the page they were received in and returns just the items in the pages.

For example:

```swift
let album = "spotify:album:5iT3F2EhjVQVrO4PKhsP8c"

spotifyAPI.albumTracks(album, market: "US", limit: 20)
    .extendPagesConcurrently(spotifyAPI)
    .collectAndSortByOffset()
    .sink(
        receiveCompletion: { completion in
            print("completion: \(completion)")
        },
        receiveValue: { tracks in
            print("received \(tracks.count) tracks:")
            for track in tracks {
                print(track.name)
            }
        }
    )
    .store(in: &cancellables)
```

Output:
```
received 40 tracks:
Come Together - 2019 Mix
Something - 2019 Mix
Maxwell's Silver Hammer - 2019 Mix
Oh! Darling - 2019 Mix
Octopus's Garden - 2019 Mix
I Want You (She's So Heavy) - 2019 Mix
Here Comes The Sun - 2019 Mix
Because - 2019 Mix
You Never Give Me Your Money - 2019 Mix
Sun King - 2019 Mix
Mean Mr Mustard - 2019 Mix
Polythene Pam - 2019 Mix
She Came In Through The Bathroom Window - 2019 Mix
Golden Slumbers - 2019 Mix
Carry That Weight - 2019 Mix
The End - 2019 Mix
Her Majesty - 2019 Mix
I Want You (She's So Heavy) - Trident Recording Session & Reduction Mix
Goodbye - Home Demo
Something - Studio Demo
The Ballad Of John And Yoko - Take 7
Old Brown Shoe - Take 2
Oh! Darling - Take 4
Octopus's Garden - Take 9
You Never Give Me Your Money - Take 36
Her Majesty - Takes 1-3
Golden Slumbers / Carry That Weight - Takes 1-3 / Medley
Here Comes The Sun - Take 9
Maxwell's Silver Hammer - Take 12
Come Together - Take 5
The End - Take 3
Come And Get It - Studio Demo
Sun King - Take 20
Mean Mr. Mustard - Take 20
Polythene Pam - Take 27
She Came In Through The Bathroom Window - Take 27
Because - Take 1 / Instrumental
The Long One - Comprising of ‘You Never Give Me Your Money’, ’Sun King’/’Mean Mr Mustard’, ‘Her Majesty’, ‘Polythene Pam’/’She Came In Through The Bathroom Window’, ’Golden Slumbers’/ ’Carry That Weight’, ’The End’
Something - Take 39 / Instrumental / Strings Only
Golden Slumbers / Carry That Weight - Take 17 / Instrumental / Strings & Brass Only
completion: finished
```

## Manually Requesting Specific Pages

You can manually retrieve the next and previous page of a ``PagingObject`` by passing the  ``PagingObject/next`` and ``PagingObject/previous`` properties, respectively, into  ``SpotifyAPI/getFromHref(_:responseType:)``.

```swift
let dispatchGroup = DispatchGroup()

/// The full URL to the next page of results
var nextHref: URL? = nil

dispatchGroup.enter()
spotifyAPI.currentUserTopArtists()
    .sink(
        receiveCompletion: { completion in
            print("completion: \(completion)")
            dispatchGroup.leave()
        },
        receiveValue: { artistsPage in
            print("received \(artistsPage.items.count) artists:")
            for artist in artistsPage.items {
                print(artist.name)
            }
            // MARK: Retrieve the next property of the paging object
            nextHref = artistsPage.next
            
        }
    )
    .store(in: &cancellables)

dispatchGroup.wait()

// request the next page if `nextHref` is non-`nil`.
if let nextHref = nextHref {
    
    print("\n\nrequesting next page of artists")
    dispatchGroup.enter()
    spotifyAPI.getFromHref(
        nextHref,
        responseType: PagingObject<Artist>.self
    )
    .sink(
        receiveCompletion: { completion in
            print("completion: \(completion)")
            dispatchGroup.leave()
        },
        receiveValue: { artistsPage in
            print("received \(artistsPage.items.count) artists:")
            for artist in artistsPage.items {
                print(artist.name)
            }
            
        }
    )
    .store(in: &cancellables)
    dispatchGroup.wait()
    
}
```
Output:
```
received 20 artists:
The Beatles
Pink Floyd
Crumb
Radiohead
levitation room
Spoon
Jimi Hendrix
King Gizzard & The Lizard Wizard
Mac DeMarco
deadmau5
Skinshape
Led Zeppelin
Men I Trust
Causa Sui
Psychedelic Porn Crumpets
Mild High Club
Allan Rayman
Das Kope
Naxatras
The Doors
completion: finished


requesting next page of artists
received 20 artists:
Santana
2Pac
Childish Gambino
The Rolling Stones
Stevie Ray Vaughan
The Thrills
MF DOOM
Cream
Paul McCartney
The Animals
Sugar Candy Mountain
Klaatu
Allman Brothers Band
King Krule
King Crimson
Motörhead
Mazzy Star
C418
Speck Joliet
Eminem
completion: finished
```
