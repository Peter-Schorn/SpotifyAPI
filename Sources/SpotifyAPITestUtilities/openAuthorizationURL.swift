import Foundation
import XCTest
import SpotifyWebAPI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Opens the authorization URL and waits for the user to login
 and copy and paste the redirect URL into standard input or starts
 a server to listen for the redirect URL if the TEST flag is enabled.
 
 - Parameter authorizationURL: The authorization URL.
 - Returns: The redirect URI with the query, which is used for
       requesting access and refresh tokens
 */
public func openAuthorizationURLAndWaitForRedirect(
    _ authorizationURL: URL
) -> URL? {
    
    DistributedLock.redirectListener.lock()
    defer {
        DistributedLock.redirectListener.unlock()
    }

    #if !TEST
    // MARK: start the server
    
    var redirectURIWithQuery: URL? = nil
    
    var redirectListener = RedirectListener(url: localHostURL)
    
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    do {
        try redirectListener.start(receiveURL: { url in
            redirectURIWithQuery = url
//            for (name, value) in url.queryItemsDict {
//                print("'\(name)': '\(value)'")
//            }
            dispatchGroup.leave()
        })
        
    } catch {
        fatalError("couldn't run listener: \(error)")
    }
    
    #endif

    // MARK: open the authorization URL
    
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    NSWorkspace.shared.open(authorizationURL)
    #elseif canImport(UIKit)
    UIApplication.shared.open(authorizationURL)
    #endif
    print(
        """

        ======================================================\
        ===============================================
        Open the following URL in your browser:

        \(authorizationURL)
        """
    )
    
    #if !TEST
    print(
        """

        ======================================================\
        ===============================================
        Running local server to wait for redirect
        """
    )
    
    // MARK: retrieve the redirect URI from the server

    dispatchGroup.wait()
    redirectListener.shutdown()
    
    if let redirectURIWithQuery = redirectURIWithQuery {
        return redirectURIWithQuery
    }
    fatalError("couldn't get redirect URI from listener")
    
    #else
    print(
        """

        ======================================================\
        ===============================================
        After You approve the application and are redirected, \
        paste the url that you were redirected to here:
        """
    )
    
    // MARK: get the redirect URI from standard input
    
    guard var redirectURIWithQueryString = readLine() else {
        fatalError("couldn't read redirect URI from standard input")
    }
    
    // see the documentation for `readLine`
    // see also https://en.wikipedia.org/wiki/Specials_(Unicode_block)#Unicode_chart
    let replacementCharacters: [Character] = [
        "\u{FFF9}", "\u{FFFA}", "\u{FFFB}", "\u{FFFC}", "\u{FFFD}",
        "\u{F702}"
    ]
    
    redirectURIWithQueryString.removeAll(where: { character in
        replacementCharacters.contains(character)
    })
    
    return URL(string: redirectURIWithQueryString.strip())
    
    #endif

}
