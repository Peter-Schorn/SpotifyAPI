import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIAudiobookTests: SpotifyAPITests { }

extension SpotifyAPIAudiobookTests {
    
    func receiveHarryPotterAndTheSorcerersStone(_ audiobook: Audiobook) {
        
        encodeDecode(audiobook)

        XCTAssertEqual(audiobook.authors.count, 1)
        XCTAssertEqual(audiobook.authors.first?.name, "J.K. Rowling")
        XCTAssertEqual(
            audiobook.chapters?.href,
            URL(string: "https://api.spotify.com/v1/audiobooks/2IEBhnu61ieYGFRPEJIO40/chapters")
        )
        XCTAssertEqual(audiobook.chapters?.limit, 50)
        XCTAssertNil(audiobook.chapters?.next)
        XCTAssertEqual(audiobook.chapters?.offset, 0)
        XCTAssertNil(audiobook.chapters?.previous)
        XCTAssertEqual(audiobook.chapters?.total, 20)
        
        guard let chapters = audiobook.chapters?.items else {
            XCTFail(
                """
                chapters.items was missing from audiobook \
                '\(audiobook.name)'
                """
            )
            return
        }

        for (i, chapter) in chapters.enumerated() {
            XCTAssertEqual(chapter.chapterNumber, i)
        }
        
        if chapters.count < 20 {
            XCTFail(
                """
                expected 20 chapters (got \(chapters.count)) for \
                audiobook '\(audiobook.name)'
                """
            )
        }

        XCTAssertEqual(audiobook.chapters?.items.count, 20)
        
        XCTAssertEqual(
            audiobook.copyrights?.count, 1,
            "Expected 1 copyright object for audiobook '\(audiobook.name)'"
        )
        XCTAssertEqual(
            audiobook.copyrights?.first?.text,
            "Pottermore 1997"
        )
        XCTAssertEqual(audiobook.copyrights?.first?.type, "C")
        XCTAssertEqual(
            audiobook.description,
            """
            Author(s): J.K. Rowling
            Narrator(s): Jim Dale

            <em>"Turning the envelope over, his hand trembling, Harry saw a purple wax seal bearing a coat of arms; a lion, an eagle, a badger and a snake surrounding a large letter 'H'."</em></br></br>Harry Potter has never even heard of Hogwarts when the letters start dropping on the doormat at number four, Privet Drive. Addressed in green ink on yellowish parchment with a purple seal, they are swiftly confiscated by his grisly aunt and uncle. Then, on Harry's eleventh birthday, a great beetle-eyed giant of a man called Rubeus Hagrid bursts in with some astonishing news: Harry Potter is a wizard, and he has a place at Hogwarts School of Witchcraft and Wizardry. An incredible adventure is about to begin!
            """
        )
        XCTAssertEqual(
            audiobook.htmlDescription,
            """
            Author(s): J.K. Rowling<br/>Narrator(s): Jim Dale<br/>&lt;em&gt;&#34;Turning the envelope over, his hand trembling, Harry saw a purple wax seal bearing a coat of arms; a lion, an eagle, a badger and a snake surrounding a large letter &#39;H&#39;.&#34;&lt;/em&gt;&lt;/br&gt;&lt;/br&gt;Harry Potter has never even heard of Hogwarts when the letters start dropping on the doormat at number four, Privet Drive. Addressed in green ink on yellowish parchment with a purple seal, they are swiftly confiscated by his grisly aunt and uncle. Then, on Harry&#39;s eleventh birthday, a great beetle-eyed giant of a man called Rubeus Hagrid bursts in with some astonishing news: Harry Potter is a wizard, and he has a place at Hogwarts School of Witchcraft and Wizardry. An incredible adventure is about to begin!
            """
        )
        XCTAssertEqual(audiobook.id, "2IEBhnu61ieYGFRPEJIO40")
        XCTAssertEqual(audiobook.languages, ["English"])
        XCTAssertEqual(audiobook.mediaType, "audio")
        XCTAssertEqual(audiobook.name, "Harry Potter and the Sorcerer's Stone")
        XCTAssertEqual(audiobook.narrators.count, 1)
        XCTAssertEqual(audiobook.narrators.first?.name, "Jim Dale")
        XCTAssertEqual(audiobook.publisher, "Pottermore")
        XCTAssertEqual(audiobook.totalChapters, 20)
        XCTAssertEqual(audiobook.type, .audiobook)
        XCTAssertEqual(audiobook.uri, "spotify:show:2IEBhnu61ieYGFRPEJIO40")

        // MARK: Chapter 0
        do {
            let chapter0 = chapters[0]
            XCTAssertEqual(
                chapter0.restrictions?["reason"],
                "payment_required"
            )
            XCTAssertEqual(chapter0.id, "5HQIsy4eLtirwOw1rQ9ENK")
            XCTAssertEqual(chapter0.description, "")
            XCTAssertEqual(chapter0.htmlDescription, "")
            XCTAssertEqual(chapter0.chapterNumber, 0)
            XCTAssertEqual(chapter0.durationMS, 26000)
            XCTAssertEqual(chapter0.isExplicit, false)
//                XCTAssertEqual(chapter0.languages[0], "en")
            XCTAssertEqual(chapter0.name, "Opening Credits")
//                XCTAssertEqual(chapter0.audioPreviewURL, nil)
//                XCTAssertEqual(chapter0.releaseDate, "0000")
            XCTAssertEqual(chapter0.releaseDatePrecision, "year")
            
            if Self.spotify.authorizationManager.isAuthorized(
                for: [.userReadPlaybackPosition]
            ) {
                XCTAssertNotNil(
                    chapter0.resumePoint,
                    "chapter0 resume point was nil: " +
                    "\(type(of: Self.spotify.authorizationManager))"
                )
                XCTAssertEqual(chapter0.resumePoint?.fullyPlayed, false)
                XCTAssertEqual(chapter0.resumePoint?.resumePositionMS, 0)
            }

            // because of the "payment_required" restriction
            XCTAssertEqual(chapter0.isPlayable, false)
            XCTAssertEqual(chapter0.type, .chapter)
            XCTAssertEqual(
                chapter0.uri,
                "spotify:episode:5HQIsy4eLtirwOw1rQ9ENK"
            )
            XCTAssertEqual(
                chapter0.externalURLs?["spotify"],
                URL(string: "https://open.spotify.com/episode/5HQIsy4eLtirwOw1rQ9ENK")
            )
            XCTAssertEqual(
                chapter0.href,
                URL(string: "https://api.spotify.com/v1/chapters/5HQIsy4eLtirwOw1rQ9ENK")
            )
            
            XCTAssertImagesExist(chapter0.images, assertSizeNotNil: true)

        }
        
        // MARK: Chapter 10
        do {
            let chapter10 = chapters[10]
            XCTAssertEqual(
                chapter10.restrictions?["reason"],
                "payment_required"
            )
            XCTAssertEqual(chapter10.id, "7dMoLM0MolXl16OOpqvtq2")
            XCTAssertEqual(chapter10.description, "")
            XCTAssertEqual(chapter10.htmlDescription, "")
            XCTAssertEqual(chapter10.chapterNumber, 10)
            XCTAssertEqual(chapter10.durationMS, 1532000)
            XCTAssertEqual(chapter10.isExplicit, false)
//                XCTAssertEqual(chapter10.languages[0], "en")
            XCTAssertEqual(chapter10.name, "Chapter 10: Halloween")
//                XCTAssertEqual(chapter10.audioPreviewURL, nil)
//                XCTAssertEqual(chapter10.releaseDate, "0000")
            XCTAssertEqual(chapter10.releaseDatePrecision, "year")
            
            if Self.spotify.authorizationManager.isAuthorized(
                for: [.userReadPlaybackPosition]
            ) {
                XCTAssertNotNil(
                    chapter10.resumePoint,
                    "chapter10 resume point was nil: " +
                    "\(type(of: Self.spotify.authorizationManager))"
                )
                XCTAssertEqual(chapter10.resumePoint?.fullyPlayed, false)
                XCTAssertEqual(chapter10.resumePoint?.resumePositionMS, 0)
            }

            // because of the "payment_required" restriction
            XCTAssertEqual(chapter10.isPlayable, false)
            XCTAssertEqual(chapter10.type, .chapter)
            XCTAssertEqual(
                chapter10.uri,
                "spotify:episode:7dMoLM0MolXl16OOpqvtq2"
            )
            XCTAssertEqual(
                chapter10.externalURLs?["spotify"],
                URL(string: "https://open.spotify.com/episode/7dMoLM0MolXl16OOpqvtq2")
            )
            XCTAssertEqual(
                chapter10.href,
                URL(string: "https://api.spotify.com/v1/chapters/7dMoLM0MolXl16OOpqvtq2")
            )
            
            XCTAssertImagesExist(chapter10.images, assertSizeNotNil: true)

        }
        
        // MARK: Chapter 19
        do {
            let chapter19 = chapters[19]
            XCTAssertNil(chapter19.restrictions)
            XCTAssertEqual(chapter19.id, "4twr9j4P9xgnyNFYpuhWDa")
            XCTAssertEqual(chapter19.description, "")
            XCTAssertEqual(chapter19.htmlDescription, "")
            XCTAssertEqual(chapter19.chapterNumber, 19)
            XCTAssertEqual(chapter19.durationMS, 298656)
            XCTAssertEqual(chapter19.isExplicit, false)
//                XCTAssertEqual(chapter19.languages[0], "en")
            XCTAssertEqual(
                chapter19.name,
                "Harry Potter and the Sorcerer's Stone"
            )
//                XCTAssertEqual(chapter19.audioPreviewURL, nil)
//                XCTAssertEqual(chapter19.releaseDate, "0000")
            XCTAssertEqual(chapter19.releaseDatePrecision, "year")
            
            if Self.spotify.authorizationManager.isAuthorized(
                for: [.userReadPlaybackPosition]
            ) {
                XCTAssertNotNil(
                    chapter19.resumePoint,
                    "chapter19 resume point was nil: " +
                    "\(type(of: Self.spotify.authorizationManager))"
                )
                XCTAssertEqual(chapter19.resumePoint?.fullyPlayed, false)
                XCTAssertEqual(chapter19.resumePoint?.resumePositionMS, 0)
            }

            XCTAssertEqual(chapter19.isPlayable, true)
            XCTAssertEqual(chapter19.type, .chapter)
            XCTAssertEqual(
                chapter19.uri,
                "spotify:episode:4twr9j4P9xgnyNFYpuhWDa"
            )
            XCTAssertEqual(
                chapter19.externalURLs?["spotify"],
                URL(string: "https://open.spotify.com/episode/4twr9j4P9xgnyNFYpuhWDa")
            )
            XCTAssertEqual(
                chapter19.href,
                URL(string: "https://api.spotify.com/v1/chapters/4twr9j4P9xgnyNFYpuhWDa")
            )
            
            XCTAssertImagesExist(chapter19.images, assertSizeNotNil: true)

        }

    }

    func audiobook() {
        
        let expectation = XCTestExpectation(
            description: "testAudiobook"
        )
        
        Self.spotify.audiobook(
            URIs.Audiobooks.harryPotterAndTheSorcerersStone,
            market: "US"
        )
        .XCTAssertNoFailure()
        .receiveOnMain()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveHarryPotterAndTheSorcerersStone(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func audiobooks() {
        
        func receiveAudiobooks(_ audiobooks: [Audiobook?]) {
            
            encodeDecode(audiobooks)

            let audiobooks = audiobooks.enumerated().compactMap {
                audiobook -> Audiobook? in

                XCTAssertNotNil(
                    audiobook.element,
                    "audiobook at index \(audiobook.offset) was nil"
                )

                return audiobook.element
            }
            
            guard audiobooks.count == 4 else {
                // we already display errors above if one or more elements
                // was nil
                return
            }
            
            self.receiveHarryPotterAndTheSorcerersStone(
                audiobooks[0]
            )

            // MARK: Enlighenment Now
            do {
                let audiobook = audiobooks[1]
                XCTAssertEqual(audiobook.authors.count, 1)
                XCTAssertEqual(audiobook.authors.first?.name, "Steven Pinker")
                XCTAssertEqual(
                    audiobook.description,
                    """
                    Author(s): Steven Pinker
                    Narrator(s): Arthur Morey

                    <p><b>The follow-up to Pinker's groundbreaking <i>The Better Angels of Our Nature</i> presents the big picture of human progress: people are living longer, healthier, freer, and happier lives, and while our problems are formidable, the solutions lie in the Enlightenment ideal of using reason and science.</b></p><p>Is the world really falling apart? Is the ideal of progress obsolete? In this elegant assessment of the human condition in the third millennium, cognitive scientist and public intellectual Steven Pinker urges us to step back from the gory headlines and prophecies of doom, which play to our psychological biases. Instead, follow the data: In seventy-five jaw-dropping graphs, Pinker shows that life, health, prosperity, safety, peace, knowledge, and happiness are on the rise, not just in the West, but worldwide. This progress is not the result of some cosmic force. It is a gift of the Enlightenment: the conviction that reason and science can enhance human flourishing.</p><p>Far from being a naïve hope, the Enlightenment, we now know, has worked. But more than ever, it needs a vigorous defense. The Enlightenment project swims against currents of human nature&mdash;tribalism, authoritarianism, demonization, magical thinking&mdash;which demagogues are all too willing to exploit. Many commentators, committed to political, religious, or romantic ideologies, fight a rearguard action against it. The result is a corrosive fatalism and a willingness to wreck the precious institutions of liberal democracy and global cooperation.</p><p>With intellectual depth and literary flair, <i>Enlightenment Now</i> makes the case for reason, science, and humanism: the ideals we need to confront our problems and continue our progress.</p>
                    """
                )
                XCTAssertEqual(
                    audiobook.htmlDescription,
                    """
                    Author(s): Steven Pinker<br/>Narrator(s): Arthur Morey<br/>&lt;p&gt;&lt;b&gt;The follow-up to Pinker&#39;s groundbreaking &lt;i&gt;The Better Angels of Our Nature&lt;/i&gt; presents the big picture of human progress: people are living longer, healthier, freer, and happier lives, and while our problems are formidable, the solutions lie in the Enlightenment ideal of using reason and science.&lt;/b&gt;&lt;/p&gt;&lt;p&gt;Is the world really falling apart? Is the ideal of progress obsolete? In this elegant assessment of the human condition in the third millennium, cognitive scientist and public intellectual Steven Pinker urges us to step back from the gory headlines and prophecies of doom, which play to our psychological biases. Instead, follow the data: In seventy-five jaw-dropping graphs, Pinker shows that life, health, prosperity, safety, peace, knowledge, and happiness are on the rise, not just in the West, but worldwide. This progress is not the result of some cosmic force. It is a gift of the Enlightenment: the conviction that reason and science can enhance human flourishing.&lt;/p&gt;&lt;p&gt;Far from being a naïve hope, the Enlightenment, we now know, has worked. But more than ever, it needs a vigorous defense. The Enlightenment project swims against currents of human nature&amp;mdash;tribalism, authoritarianism, demonization, magical thinking&amp;mdash;which demagogues are all too willing to exploit. Many commentators, committed to political, religious, or romantic ideologies, fight a rearguard action against it. The result is a corrosive fatalism and a willingness to wreck the precious institutions of liberal democracy and global cooperation.&lt;/p&gt;&lt;p&gt;With intellectual depth and literary flair, &lt;i&gt;Enlightenment Now&lt;/i&gt; makes the case for reason, science, and humanism: the ideals we need to confront our problems and continue our progress.&lt;/p&gt;
                    """
                )
                XCTAssertEqual(audiobook.edition, "Unabridged")
                XCTAssertEqual(audiobook.isExplicit, false)
                XCTAssertEqual(audiobook.id, "2fUedmI8FowN4xYJuMIDfi")
                XCTAssertEqual(audiobook.uri, "spotify:show:2fUedmI8FowN4xYJuMIDfi")
                XCTAssertNotNil(audiobook.images)
                XCTAssertEqual(audiobook.languages.first, "English")
                XCTAssertEqual(audiobook.mediaType, "audio")
                XCTAssertEqual(audiobook.publisher, "Penguin Random House")
                XCTAssertEqual(
                    audiobook.name,
                    "Enlightenment Now: The Case for Reason, Science, Humanism, and Progress"
                )
                XCTAssertEqual(audiobook.narrators.count, 1)
                XCTAssertEqual(audiobook.narrators.first?.name, "Arthur Morey")
                XCTAssertEqual(audiobook.totalChapters, 28)
                XCTAssertEqual(audiobook.type, .audiobook)
                XCTAssertEqual(
                    audiobook.chapters?.href,
                    URL(string: "https://api.spotify.com/v1/audiobooks/2fUedmI8FowN4xYJuMIDfi/chapters")
                )
                XCTAssertEqual(audiobook.chapters?.items.count, 28)
                XCTAssertEqual(audiobook.chapters?.limit, 50)
                XCTAssertNil(audiobook.chapters?.next)
                XCTAssertEqual(audiobook.chapters?.offset, 0)
                XCTAssertNil(audiobook.chapters?.previous)
                XCTAssertEqual(audiobook.chapters?.total, 28)
            }
            
            // MARK: Free Will
            do {
                let audiobook = audiobooks[2]
                XCTAssertEqual(audiobook.authors.count, 1)
                XCTAssertEqual(audiobook.authors.first?.name, "Sam Harris")
                XCTAssertEqual(
                    audiobook.description,
                    """
                    Author(s): Sam Harris
                    Narrator(s): Sam Harris

                    A BELIEF IN FREE WILL touches nearly everything that human beings value. It is difficult to think about law, politics, religion, public policy, intimate relationships, morality—as well as feelings of remorse or personal achievement—without first imagining that every person is the true source of his or her thoughts and actions. And yet the facts tell us that free will is an illusion. <br><br>In this enlightening book, Sam Harris argues that this truth about the human mind does not undermine morality or diminish the importance of social and political freedom, but it can and should change the way we think about some of the most important questions in life.
                    """
                )
                XCTAssertEqual(
                    audiobook.htmlDescription,
                    """
                    Author(s): Sam Harris<br/>Narrator(s): Sam Harris<br/>A BELIEF IN FREE WILL touches nearly everything that human beings value. It is difficult to think about law, politics, religion, public policy, intimate relationships, morality—as well as feelings of remorse or personal achievement—without first imagining that every person is the true source of his or her thoughts and actions. And yet the facts tell us that free will is an illusion. &lt;br&gt;&lt;br&gt;In this enlightening book, Sam Harris argues that this truth about the human mind does not undermine morality or diminish the importance of social and political freedom, but it can and should change the way we think about some of the most important questions in life.
                    """
                )
                XCTAssertEqual(audiobook.edition, "Unabridged")
                XCTAssertEqual(audiobook.isExplicit, false)
                XCTAssertEqual(audiobook.id, "4x3Y9YYK84XJSTTJp2atHe")
                XCTAssertEqual(audiobook.uri, "spotify:show:4x3Y9YYK84XJSTTJp2atHe")
                XCTAssertNotNil(audiobook.images)
                XCTAssertEqual(audiobook.languages.first, "English")
                XCTAssertEqual(audiobook.mediaType, "audio")
                XCTAssertEqual(audiobook.publisher, "Simon & Schuster")
                XCTAssertEqual(audiobook.name, "Free Will")
                XCTAssertEqual(audiobook.narrators.count, 1)
                XCTAssertEqual(audiobook.narrators.first?.name, "Sam Harris")
                XCTAssertEqual(audiobook.totalChapters, 11)
                XCTAssertEqual(audiobook.type, .audiobook)
                XCTAssertEqual(
                    audiobook.chapters?.href,
                    URL(string: "https://api.spotify.com/v1/audiobooks/4x3Y9YYK84XJSTTJp2atHe/chapters")
                )
                XCTAssertEqual(audiobook.chapters?.items.count, 11)
                XCTAssertEqual(audiobook.chapters?.limit, 50)
                XCTAssertNil(audiobook.chapters?.next)
                XCTAssertEqual(audiobook.chapters?.offset, 0)
                XCTAssertNil(audiobook.chapters?.previous)
                XCTAssertEqual(audiobook.chapters?.total, 11)
            }
            
            // MARK: Steve Jobs
            do {
                let audiobook = audiobooks[3]
                XCTAssertEqual(audiobook.authors.count, 1)
                XCTAssertEqual(audiobook.authors.first?.name, "Walter Isaacson")
                XCTAssertEqual(
                    audiobook.description,
                    """
                    Author(s): Walter Isaacson
                    Narrator(s): Dylan Baker

                    <P><B>Featuring a new epilogue read by the author.</P><P>From the author of the best-selling biographies of Benjamin Franklin and Albert Einstein, this is the exclusive biography of Steve Jobs.</B></P><P>Based on more than 40 interviews with Jobs conducted over two years—as well as interviews with more than a hundred family members, friends, adversaries, competitors, and colleagues—Walter Isaacson has written a riveting story of the roller-coaster life and searingly intense personality of a creative entrepreneur whose passion for perfection and ferocious drive revolutionized six industries: personal computers, animated movies, music, phones, tablet computing, and digital publishing.</P><P>At a time when America is seeking ways to sustain its innovative edge, and when societies around the world are trying to build digital-age economies, Jobs stands as the ultimate icon of inventiveness and applied imagination. He knew that the best way to create value in the 21st century was to connect creativity with technology. He built a company where leaps of the imagination were combined with remarkable feats of engineering.</P><P>Although Jobs cooperated with this book, he asked for no control over what was written. He put nothing off-limits. He encouraged the people he knew to speak honestly. And Jobs speaks candidly, sometimes brutally so, about the people he worked with and competed against. His friends, foes, and colleagues provide an unvarnished view of the passions, perfectionism, obsessions, artistry, devilry, and compulsion for control that shaped his approach to business and the innovative products that resulted.</P><P>Driven by demons, Jobs could drive those around him to fury and despair. But his personality and products were interrelated, just as Apple's hardware and software tended to be, as if part of an integrated system. His tale is instructive and cautionary, filled with lessons about innovation, character, leadership, and values.</P>
                    """
                )
                XCTAssertEqual(
                    audiobook.htmlDescription,
                    """
                    Author(s): Walter Isaacson<br/>Narrator(s): Dylan Baker<br/>&lt;P&gt;&lt;B&gt;Featuring a new epilogue read by the author.&lt;/P&gt;&lt;P&gt;From the author of the best-selling biographies of Benjamin Franklin and Albert Einstein, this is the exclusive biography of Steve Jobs.&lt;/B&gt;&lt;/P&gt;&lt;P&gt;Based on more than 40 interviews with Jobs conducted over two years—as well as interviews with more than a hundred family members, friends, adversaries, competitors, and colleagues—Walter Isaacson has written a riveting story of the roller-coaster life and searingly intense personality of a creative entrepreneur whose passion for perfection and ferocious drive revolutionized six industries: personal computers, animated movies, music, phones, tablet computing, and digital publishing.&lt;/P&gt;&lt;P&gt;At a time when America is seeking ways to sustain its innovative edge, and when societies around the world are trying to build digital-age economies, Jobs stands as the ultimate icon of inventiveness and applied imagination. He knew that the best way to create value in the 21st century was to connect creativity with technology. He built a company where leaps of the imagination were combined with remarkable feats of engineering.&lt;/P&gt;&lt;P&gt;Although Jobs cooperated with this book, he asked for no control over what was written. He put nothing off-limits. He encouraged the people he knew to speak honestly. And Jobs speaks candidly, sometimes brutally so, about the people he worked with and competed against. His friends, foes, and colleagues provide an unvarnished view of the passions, perfectionism, obsessions, artistry, devilry, and compulsion for control that shaped his approach to business and the innovative products that resulted.&lt;/P&gt;&lt;P&gt;Driven by demons, Jobs could drive those around him to fury and despair. But his personality and products were interrelated, just as Apple&#39;s hardware and software tended to be, as if part of an integrated system. His tale is instructive and cautionary, filled with lessons about innovation, character, leadership, and values.&lt;/P&gt;
                    """
                )
                XCTAssertEqual(audiobook.edition, "Unabridged")
                XCTAssertEqual(audiobook.isExplicit, false)
                XCTAssertEqual(audiobook.id, "2rBiFKvU85lq19QYB3Zr38")
                XCTAssertEqual(audiobook.uri, "spotify:show:2rBiFKvU85lq19QYB3Zr38")
                XCTAssertNotNil(audiobook.images)
                XCTAssertEqual(audiobook.languages.first, "English")
                XCTAssertEqual(audiobook.mediaType, "audio")
                XCTAssertEqual(audiobook.publisher, "Simon & Schuster")
                XCTAssertEqual(audiobook.name, "Steve Jobs")
                XCTAssertEqual(audiobook.narrators.count, 1)
                XCTAssertEqual(audiobook.narrators.first?.name, "Dylan Baker")
                XCTAssertEqual(audiobook.totalChapters, 47)
                XCTAssertEqual(audiobook.type, .audiobook)
                XCTAssertEqual(
                    audiobook.chapters?.href,
                    URL(string: "https://api.spotify.com/v1/audiobooks/2rBiFKvU85lq19QYB3Zr38/chapters")
                )
                XCTAssertEqual(audiobook.chapters?.items.count, 47)
                XCTAssertEqual(audiobook.chapters?.limit, 50)
                XCTAssertNil(audiobook.chapters?.next)
                XCTAssertEqual(audiobook.chapters?.offset, 0)
                XCTAssertNil(audiobook.chapters?.previous)
                XCTAssertEqual(audiobook.chapters?.total, 47)
            }

        }

        let expectation = XCTestExpectation(
            description: "testAudiobooks"
        )
        
        let audiobooks = URIs.Audiobooks.array(
            .harryPotterAndTheSorcerersStone,
            .enlightenmentNow,
            .freeWill,
            .steveJobs
        )
        
        Self.spotify.audiobooks(audiobooks, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveAudiobooks(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func receiveFreeWillChapter1(_ chapter: AudiobookChapter) {
        
        encodeDecode(chapter)
        
        XCTAssertEqual(chapter.id, "6QYoIxxar5q4AfdTOGsZqE")
        XCTAssertEqual(chapter.chapterNumber, 1)
        XCTAssertEqual(chapter.durationMS, 425_000)
        XCTAssertEqual(chapter.isExplicit, false)
        XCTAssertEqual(chapter.name, "Chapter 1")
        XCTAssertEqual(chapter.releaseDatePrecision, "year")
        XCTAssertEqual(chapter.type, .chapter)
        XCTAssertEqual(chapter.uri, "spotify:episode:6QYoIxxar5q4AfdTOGsZqE")
        XCTAssertEqual(
            chapter.externalURLs?["spotify"],
            URL(string: "https://open.spotify.com/episode/6QYoIxxar5q4AfdTOGsZqE")
        )
        XCTAssertEqual(
            chapter.href,
            URL(string: "https://api.spotify.com/v1/chapters/6QYoIxxar5q4AfdTOGsZqE")
        )
        XCTAssertImagesExist(chapter.images, assertSizeNotNil: true)
        
        if Self.spotify.authorizationManager.isAuthorized(
            for: [.userReadPlaybackPosition]
        ) {
            XCTAssertNotNil(chapter.resumePoint)
        }

        guard let auiodbook = chapter.audiobook else {
            XCTFail("audiobook was nil for chapter '\(chapter.name)'")
            return
        }
        
        XCTAssertEqual(auiodbook.authors.count, 1)
        XCTAssertEqual(auiodbook.authors.first?.name, "Sam Harris")
        XCTAssertEqual(auiodbook.copyrights?.count, 1)
        XCTAssertEqual(
            auiodbook.copyrights?.first?.text,
            "Simon & Schuster 2012"
        )
        XCTAssertEqual(auiodbook.copyrights?.first?.type, "C")
        XCTAssertEqual(
            auiodbook.description,
            """
            Author(s): Sam Harris
            Narrator(s): Sam Harris

            A BELIEF IN FREE WILL touches nearly everything that human beings value. It is difficult to think about law, politics, religion, public policy, intimate relationships, morality—as well as feelings of remorse or personal achievement—without first imagining that every person is the true source of his or her thoughts and actions. And yet the facts tell us that free will is an illusion. <br><br>In this enlightening book, Sam Harris argues that this truth about the human mind does not undermine morality or diminish the importance of social and political freedom, but it can and should change the way we think about some of the most important questions in life.
            """
        )
        XCTAssertEqual(
            auiodbook.htmlDescription,
            """
            Author(s): Sam Harris<br/>Narrator(s): Sam Harris<br/>A BELIEF IN FREE WILL touches nearly everything that human beings value. It is difficult to think about law, politics, religion, public policy, intimate relationships, morality—as well as feelings of remorse or personal achievement—without first imagining that every person is the true source of his or her thoughts and actions. And yet the facts tell us that free will is an illusion. &lt;br&gt;&lt;br&gt;In this enlightening book, Sam Harris argues that this truth about the human mind does not undermine morality or diminish the importance of social and political freedom, but it can and should change the way we think about some of the most important questions in life.
            """
        )
        XCTAssertEqual(auiodbook.isExplicit, false)
        XCTAssertEqual(
            auiodbook.externalURLs?["spotify"],
            URL(string: "https://open.spotify.com/show/4x3Y9YYK84XJSTTJp2atHe")
        )
        XCTAssertEqual(
            auiodbook.href,
            URL(string: "https://api.spotify.com/v1/audiobooks/4x3Y9YYK84XJSTTJp2atHe")
        )
        XCTAssertEqual(auiodbook.id, "4x3Y9YYK84XJSTTJp2atHe")
        XCTAssertEqual(auiodbook.languages, ["English"])
        XCTAssertEqual(auiodbook.mediaType, "audio")
        XCTAssertEqual(auiodbook.name, "Free Will")
        XCTAssertEqual(auiodbook.narrators.count, 1)
        XCTAssertEqual(auiodbook.narrators.first?.name, "Sam Harris")
        XCTAssertEqual(auiodbook.publisher, "Simon & Schuster")
        XCTAssertEqual(auiodbook.type, .audiobook)
        XCTAssertEqual(auiodbook.uri, "spotify:show:4x3Y9YYK84XJSTTJp2atHe")
        XCTAssertImagesExist(auiodbook.images, assertSizeNotNil: true)

    }

    func chapter() {
        
        let expectation = XCTestExpectation(
            description: "testChapter"
        )
        
        Self.spotify.chapter(
            URIs.Chapters.freeWillChapter1,
            market: "US"
        )
        .XCTAssertNoFailure()
        .receiveOnMain()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveFreeWillChapter1(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }
    
    func chapters() {
        
        func receiveChapters(_ chapters: [AudiobookChapter?]) {
            
            encodeDecode(chapters)

            let chapters = chapters.enumerated().compactMap {
                chapter -> AudiobookChapter? in

                XCTAssertNotNil(
                    chapter.element,
                    "chapter at index \(chapter.offset) was nil"
                )

                return chapter.element
            }
            
            guard chapters.count == 3 else {
                // we already display errors above if one or more elements
                // was nil
                return
            }
            
            self.receiveFreeWillChapter1(chapters[0])
            
            // MARK: Steve Jovs Chapter 2
            do {
                let chapter = chapters[1]
                XCTAssertEqual(
                    chapter.restrictions?["reason"],
                    "payment_required"
                )
                XCTAssertEqual(chapter.id, "7z9aAoKD03hEVfg47PJdzQ")
                XCTAssertEqual(chapter.chapterNumber, 4)
                XCTAssertEqual(chapter.durationMS, 1_480_000)
                XCTAssertEqual(chapter.isExplicit, false)
                XCTAssertEqual(chapter.name, "Chapter 2")
                XCTAssertEqual(chapter.releaseDatePrecision, "year")
                XCTAssertEqual(chapter.isPlayable, false)
                XCTAssertEqual(chapter.type, .chapter)
                XCTAssertEqual(chapter.uri, "spotify:episode:7z9aAoKD03hEVfg47PJdzQ")
                XCTAssertEqual(
                    chapter.externalURLs?["spotify"],
                    URL(string: "https://open.spotify.com/episode/7z9aAoKD03hEVfg47PJdzQ")
                )
                XCTAssertEqual(
                    chapter.href,
                    URL(string: "https://api.spotify.com/v1/chapters/7z9aAoKD03hEVfg47PJdzQ")
                )
                XCTAssertEqual(chapter.audiobook?.name, "Steve Jobs")
                XCTAssertEqual(
                    chapter.audiobook?.uri,
                    "spotify:show:2rBiFKvU85lq19QYB3Zr38"
                )
            }
            
            // MARK: Enlightenment Now Chapter 3
            do {
                let chapter = chapters[2]
                XCTAssertEqual(
                    chapter.restrictions?["reason"],
                    "payment_required"
                )
                XCTAssertEqual(chapter.id, "1cwNPlPUCmwHBR72q6ecge")
                XCTAssertEqual(chapter.chapterNumber, 5)
                XCTAssertEqual(chapter.durationMS, 1_194_000)
                XCTAssertEqual(chapter.isExplicit, false)
                XCTAssertEqual(chapter.name, "Chapter 3")
                XCTAssertEqual(chapter.releaseDatePrecision, "year")
                XCTAssertEqual(chapter.isPlayable, false)
                XCTAssertEqual(chapter.type, .chapter)
                XCTAssertEqual(chapter.uri, "spotify:episode:1cwNPlPUCmwHBR72q6ecge")
                XCTAssertEqual(
                    chapter.externalURLs?["spotify"],
                    URL(string: "https://open.spotify.com/episode/1cwNPlPUCmwHBR72q6ecge")
                )
                XCTAssertEqual(
                    chapter.href,
                    URL(string: "https://api.spotify.com/v1/chapters/1cwNPlPUCmwHBR72q6ecge")
                )
                XCTAssertEqual(
                    chapter.audiobook?.name,
                    "Enlightenment Now: The Case for Reason, Science, Humanism, and Progress"
                )
                XCTAssertEqual(
                    chapter.audiobook?.uri,
                    "spotify:show:2fUedmI8FowN4xYJuMIDfi"
                )
            }

        }

        let expectation = XCTestExpectation(
            description: "testChapters"
        )
        
        let chapters = URIs.Chapters.array(
            .freeWillChapter1,
            .steveJobsChapter2,
            .enlightenmentNowChapter3
        )
        
        Self.spotify.chapters(
            chapters, market: "US"
        )
        .XCTAssertNoFailure()
        .receiveOnMain()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveChapters(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        

    }

}

final class SpotifyAPIClientCredentialsFlowAudiobookTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIAudiobookTests
{
    
    static let allTests = [
        ("testAudiobook", testAudiobook),
        ("testAudiobooks", testAudiobooks),
        ("testChapter", testChapter),
        ("testChapters", testChapters)
    ]

    func testAudiobook() { audiobook() }
    func testAudiobooks() { audiobooks() }
    func testChapter() { chapter() }
    func testChapters() { chapters() }

}

final class SpotifyAPIAuthorizationCodeFlowAudiobookTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIAudiobookTests
{
    
    static let allTests = [
        ("testAudiobook", testAudiobook),
        ("testAudiobooks", testAudiobooks),
        ("testChapter", testChapter),
        ("testChapters", testChapters)
    ]

    func testAudiobook() { audiobook() }
    func testAudiobooks() { audiobooks() }
    func testChapter() { chapter() }
    func testChapters() { chapters() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEAudiobookTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIAudiobookTests
{
    
    static let allTests = [
        ("testAudiobook", testAudiobook),
        ("testAudiobooks", testAudiobooks),
        ("testChapter", testChapter),
        ("testChapters", testChapters)
    ]

    func testAudiobook() { audiobook() }
    func testAudiobooks() { audiobooks() }
    func testChapter() { chapter() }
    func testChapters() { chapters() }

}
