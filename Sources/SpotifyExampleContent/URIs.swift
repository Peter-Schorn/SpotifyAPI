import Foundation
import SpotifyWebAPI

/// An enum for which the raw values of all the cases are Spotify URIs.
public protocol SpotifyURIConvertibleEnum:
    SpotifyURIConvertible,
    CaseIterable,
    Codable,
    Hashable,
    RawRepresentable where RawValue == String
{
    
    /// A Spotify URI.
    var uri: String { get }

}

public extension SpotifyURIConvertibleEnum {
    
    /// A Spotify URI. Returns `self.rawValue`.
    @inlinable
    var uri: String { self.rawValue }
    
    /// Creates an array of URIs.
    ///
    /// - Parameter items: A variadic array of URIs.
    @inlinable
    static func array(_ items: Self...) -> [String] {
        return items.map(\.uri)
    }
    
}

/// A namespace of Spotify content identifiers (mostly URIs).
public enum URIs {
    
    /// A namespace of Spotify user URIs.
    public enum Users: String, SpotifyURIConvertibleEnum {
        case peter = "spotify:user:petervschorn"
        case april = "spotify:user:p8gjjfbirm8ucyt82ycfi9zuu"
        case nicholas = "spotify:user:osa09uoqscl4p2m6rqnfwjotn"
    }
    
    /// A namespace of Spotify Device Ids.
    public enum Devices {
        public static let petersiPhone = "a51265881bf877d8fd90e847c8eb9459b857323e"
        public static let petersComputer = "5840bef23cf13a49d38ea2a1b13075a72af9ebed"
    }
    
    /// A namespace of playlist URIs.
    public enum Playlists: String, SpotifyURIConvertibleEnum {
        case test = "spotify:playlist:0ijeB2eFmJL1euREk6Wu6C"
        case new = "spotify:playlist:5MlKAGFZNoN2d0Up8sQc0N"
        case crumb = "spotify:playlist:33yLOStnp2emkEA76ew1Dz"
        case all = "spotify:playlist:01KRdno32jt1vmG7s5pVFg"
        case index = "spotify:playlist:17gneMykp6L6O5R70wm0gE"
        case thisIsMacDeMarco = "spotify:playlist:37i9dQZF1DXe8E8oqpmTDI"
        case macDeMarco = "spotify:playlist:6oyVZ3dZZVCkXJm451Hj5v"
        case thisIsSpoon = "spotify:playlist:37i9dQZF1DZ06evO0ndiI8"
        case bluesClassics = "spotify:playlist:37i9dQZF1DXd9rSDyQguIk"
        case thisIsPinkFloyd = "spotify:playlist:37i9dQZF1DXaQ34lqGBfrU"
        case localSongs = "spotify:playlist:13S3Kgy80FmqaRjYoECK3U"
        case thisIsStevieRayVaughan = "spotify:playlist:37i9dQZF1DZ06evO35m9Q4"
        case thisIsJimiHendrix = "spotify:playlist:37i9dQZF1DWTNV753no4ic"
        case thisIsTheBeatles = "spotify:playlist:37i9dQZF1DZ06evO2iBPiw"
        case menITrust = "spotify:playlist:2EgZjzog2eSfApWQHZVn6t"
    }

    /// A namespace of artist URIs.
    public enum Artists: String, SpotifyURIConvertibleEnum {
        case crumb = "spotify:artist:4kSGbjWGxTchKpIxXPJv0B"
        case levitationRoom = "spotify:artist:0SVxQVCnJn1BNUMY9ZcRO4"
        case radiohead = "spotify:artist:4Z8W4fKeB5YxbusRsdQVPb"
        case skinshape = "spotify:artist:1itM5tXaK5THggpXA7ovAe"
        case mildHighClub = "spotify:artist:5J81VungUjSVHxlPpTI9KG"
        case pinkFloyd = "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9"
        case theBeatles = "spotify:artist:3WrFJ7ztbogyGnTHbHJFl2"
        case stevieRayVaughan = "spotify:artist:5fsDcuclIe8ZiBD5P787K1"
        /// Are you on point Phife?
        case aTribeCalledQuest = "spotify:artist:09hVIj6vWgoCDtT03h8ZCa"
        case ledZeppelin = "spotify:artist:36QJpDe2go2KgaRleHCDTp"
    }
    
    /// A namespace of album URIs.
    public enum Albums: String, SpotifyURIConvertibleEnum {
        case jinx = "spotify:album:3vukTUpiENDHDoYTVrwqtz"
        case locket = "spotify:album:2Q61Zm3rOli876QegmVY50"
        case skiptracing = "spotify:album:1qMDN9zRQreK81cJ9G1hed"
        case tiger = "spotify:album:4OPBRShV2OxYoT4hAenDPl"
        case saladDays = "spotify:album:7xPhDaYZ2ejV04aNtdBdvj"
        case meddle = "spotify:album:468ZwCchVtzEbt9BHmXopb"
        case darkSideOfTheMoon = "spotify:album:4LH4d3cOWNNsVw41Gqt2kv"
        case longestAlbum = "spotify:album:1Hnvk7i2oLf4ZQnOB8kYqt"
        case inRainbows = "spotify:album:7eyQXxuf2nGj9d2367Gi5f"
        case abbeyRoad = "spotify:album:0ETFjACtuP2ADo6LFhL6HN"
        case illmatic = "spotify:album:3kEtdS2pH6hKcMU9Wioob1"
        case housesOfTheHoly = "spotify:album:0GqpoHJREPp0iuXK3HzrHk"
    }

    /// A namespace of track URIs.
    public enum Tracks: String, SpotifyURIConvertibleEnum {
        case locket = "spotify:track:0bxcUgWlOURkU6lZt4zog0"
        case jinx = "spotify:track:3t5htCiGucfhAQjm88U3K9"
        case plants = "spotify:track:0vMr3GXZJi1IIIWE8bBJuZ"
        case faces = "spotify:track:1u7LOyLuApChbPeqMfXFKC"
        case partIII = "spotify:track:4HDLmWf73mge8isanCASnU"

        case illWind = "spotify:track:12VTgfn13lUx12D7MOYfsn"
        
        case friends = "spotify:track:43NI5sAcvDLG7QQAmUc7UU"
        case theBay = "spotify:track:4x0QYD0DhErAC1sPvvPmq9"
        case wadingOut = "spotify:track:3e7WFkI9OBb9ANwqJroJwZ"
        case nuclearFusion = "spotify:track:1pmImsdC9t35L3TkD26ax8"
        case honey = "spotify:track:0nObOnIxnz6PlPf04tZh1g"
        
        // MARK: Dark Side of the Moon
        case speakToMe = "spotify:track:574y1r7o2tRA009FW0LE7v"
        case breathe = "spotify:track:2ctvdKmETyOzPb2GiJJT53"
        case onTheRun = "spotify:track:73OIUNKRi2y24Cu9cOLrzM"
        case time = "spotify:track:3TO7bbrUKrOSPGRTB5MeCz"
        case theGreatGigInTheSky = "spotify:track:2TjdnqlpwOjhijHCwHCP2d"
        case money = "spotify:track:0vFOzaXqZHahrZp6enQwQb"
        case usAndThem = "spotify:track:1TKTiKp3zbNgrBH2IwSwIx"
        case anyColourYouLike = "spotify:track:6FBPOJLxUZEair6x4kLDhf"
        case brainDamage = "spotify:track:05uGBKRCuePsf43Hfm0JwX"
        case eclipse = "spotify:track:1tDWVeCR9oWGX8d5J9rswk"
        
        case fearless = "spotify:track:7AalBKBoLDR4UmRYRJpdbj"
        
        case odeToViceroy = "spotify:track:601KiLiZtBJRTXBrTjeieP"
        case saladDays = "spotify:track:4keAoywVf4jxRvXU7ON0hV"
        case blueBoy = "spotify:track:6drC7tBnx8AiYfTfBmDPVO"
        
        case reckoner = "spotify:track:02ppMPbg1OtEdHgoPqoqju"
        case houseOfCards = "spotify:track:48X4D1FYOShPz2VF3YdfCF"
        
        /// Right now.
        case comeTogether = "spotify:track:2EqlS6tkEnglzr7tkKAAYD"
        /// The sky is blue.
        case because = "spotify:track:1rxoyGj1QuPoVi8fOft1Kt"
        /// The love that you take is equal to the love that you make.
        case theEnd = "spotify:track:5aHHf6jrqDRb1fcBmue2kn"
        
        case lauren = "spotify:track:7vptmeNwSEVkcwDdqk7UQO"
        
        /// Non-US market.
        case heavenAndHell = "spotify:track:6kLCHFM39wkFjOuyPGLGeQ"
    }
    
    /// A namespace of episode URIs.
    public enum Episodes: String, SpotifyURIConvertibleEnum {
        case samHarris217 = "spotify:episode:7nsYz7tSJryO5vVYtkKiot"
        case samHarris216 = "spotify:episode:3CSvovzvlYeuWGGoby8mbd"
        case samHarris215 = "spotify:episode:1Vrpa83y0vBdWZqeEbkKk3"
        case samHarris214 = "spotify:episode:3d1cFPfj3kZB27D4b8ZJm2"
        case samHarris213 = "spotify:episode:7jrEoNMrNicZSxIuKhATHN"
        case samHarris212 = "spotify:episode:3OEdPEYB69pfXoBrhvQYeC"
        
        case seanCarroll112 = "spotify:episode:5LEFdZ9pYh99wSz7Go2D0g"
        case seanCarroll111 = "spotify:episode:0Bbtb2VFGYAl54Enix23Qd"
        
        /// Miley Cyrus.
        case joeRogan1531 = "spotify:episode:0ZEDvQuPtAEBnXE37slSoX"
    }
    
    /// A namespace of show URIs.
    public enum Shows: String, SpotifyURIConvertibleEnum {
        case samHarris = "spotify:show:5rgumWEx4FsqIY8e1wJNAk"
        case joeRogan = "spotify:show:4rOoJ6Egrf8K2IrywzwOMk"
        case seanCarroll = "spotify:show:622lvLwp8CVu6dvCsYAJhN"
        case scienceSalon = "spotify:show:4eDCVvVXJVwKCa0QfNbuXA"
    }
    
    /// A namespace of audiobook URIs.
    public enum Audiobooks: String, SpotifyURIConvertibleEnum {
        case harryPotterAndTheSorcerersStone = "spotify:audiobook:2IEBhnu61ieYGFRPEJIO40"
        case enlightenmentNow = "spotify:audiobook:2fUedmI8FowN4xYJuMIDfi"
        case freeWill = "spotify:audiobook:4x3Y9YYK84XJSTTJp2atHe"
        case steveJobs = "spotify:audiobook:2rBiFKvU85lq19QYB3Zr38"
    }
    
    /// A namespace of audiobook chapter URIs.
    public enum Chapters: String, SpotifyURIConvertibleEnum {
        case freeWillOpeningCredits = "spotify:chapter:4uGM8lfEQeljIkJlFQLPtT"
        case freeWillChapter1 = "spotify:chapter:6QYoIxxar5q4AfdTOGsZqE"
        case freeWillChapter2 = "spotify:chapter:70yieYbr9tuu1aSgu0cmzb"
        case freeWillChapter3 = "spotify:chapter:39k2xZuSzfDKOaYd4SIf90"
        case freeWillChapter4 = "spotify:chapter:4K8cBhSa7J8hs8aQolX9Pr"
        case freeWillChapter5 = "spotify:chapter:0BQpGw8WjyW66NTeB43vSX"
        case freeWillChapter6 = "spotify:chapter:79JmvSTN5qe5pqwby9a2EI"
        case freeWillChapter7 = "spotify:chapter:2mktZRz3WikSKvs1tTNCC7"
        case freeWillChapter8 = "spotify:chapter:3LdcW0rY9kfaKGykoWDUUV"
        case freeWillConclusion = "spotify:chapter:66yM123UFvb4QDSIUSdrZx"
        case freeWillEndingCredits = "spotify:chapter:6kbaTOLPUK6KQrcoOeXc1m"
        case steveJobsChapter1 = "spotify:chapter:0PIs96Eps5PTbnoaKrPR67"
        case steveJobsChapter2 = "spotify:chapter:7z9aAoKD03hEVfg47PJdzQ"
        case steveJobsChapter3 = "spotify:chapter:2tyNeWG1hpHR1I0jY1PXVd"
        case enlightenmentNowChapter1 = "spotify:chapter:07T2JL4HDFOQ4DXvz5qtMU"
        case enlightenmentNowChapter2 = "spotify:chapter:40P6suc4526KR5BkQZwZOM"
        case enlightenmentNowChapter3 = "spotify:chapter:1cwNPlPUCmwHBR72q6ecge"
    }

}
