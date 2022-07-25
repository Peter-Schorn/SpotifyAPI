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

#if canImport(WebKit)

/**
 Opens the authorization URL in a headless browser and then clicks either the
 accept or cancel button in order to redirect the user to the redirect URI with
 the query. Requires cookies from Spotify, which prevent the browser from having
 to log in.

 If WebKit cannot be imported or an error occurs during the above-described
 process, then opens the authorization URL and waits for the user to login and
 copy and paste the redirect URL into standard input or starts a server to
 listen for the redirect URL if the TEST flag is enabled.
 
 - Parameters:
   - authorizationURL: The authorization URL.
   - button: Which button to click on the authorization page. If the
         `show_dialog` query parameter of the authorization URL is `false` and
         the user has previously logged in, then they will be immediately
         redirected to the redirect URI as if `accept` was passed in for this
         parameter, meaning that passing in `cancel` will have no effect.
         Therefore, if you want to guarantee that the cancel button is clicked,
         you must set the `show_dialog` query parameter to `true`.
 
 - Returns: The redirect URI with the query, which is used for requesting access
 and refresh tokens.
 */
public func openAuthorizationURLAndWaitForRedirect(
    _ authorizationURL: URL,
    button: HeadlessBrowserAuthorizer.Button = .accept
) -> URL? {
    
    let runLoop = CFRunLoopGetCurrent()
    
    var redirectURIWithQuery: URL? = nil
    
    guard let headlessBrowser = HeadlessBrowserAuthorizer(
        button: button,
        redirectURI: localHostURL,
        receiveRedirectURIWithQuery: { url in
            redirectURIWithQuery = url
            CFRunLoopStop(runLoop)
        }
    ) else {
        return openAuthorizationURLAndWaitForRedirectNonHeadless(authorizationURL)
    }
    
    print(
        "loading the authorization URL in the headless browser authorizer: " +
        "\(authorizationURL)"
    )
    headlessBrowser.loadAuthorizationURL(authorizationURL)
    CFRunLoopRunInMode(.defaultMode, 30, false)  // 30 second timeout
    if let redirectURIWithQuery = redirectURIWithQuery {
        return redirectURIWithQuery
    }
    print("couldn't get redirect URI from headless browser authorizer")
    return openAuthorizationURLAndWaitForRedirectNonHeadless(authorizationURL)
    
}


#else  // MARK: Cannot import WebKit

/**
 Opens the authorization URL and waits for the user to login and copy and paste
 the redirect URL into standard input or starts a server to listen for the
 redirect URL if the TEST flag is enabled.
 
 - Parameter authorizationURL: The authorization URL.
 - Returns: The redirect URI with the query, which is used for requesting access
 and refresh tokens.
 */
public func openAuthorizationURLAndWaitForRedirect(
    _ authorizationURL: URL
) -> URL? {
 
    return openAuthorizationURLAndWaitForRedirectNonHeadless(authorizationURL)
    
}

#endif

/**
 Opens the authorization URL and waits for the user to login and copy and paste
 the redirect URL into standard input or starts a server to listen for the
 redirect URL if the TEST flag is enabled.
 
 - Parameter authorizationURL: The authorization URL.
 - Returns: The redirect URI with the query, which is used for requesting access
       and refresh tokens.
 */
public func openAuthorizationURLAndWaitForRedirectNonHeadless(
    _ authorizationURL: URL
) -> URL? {
    
    DistributedLock.redirectListener.lock()
    defer {
        DistributedLock.redirectListener.unlock()
    }

    #if TEST
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
        dispatchGroup.leave()
        print("couldn't run listener: \(error)")
        return nil
    }
    
    #endif

    // MARK: open the authorization URL
    
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    NSWorkspace.shared.open(authorizationURL)
    #elseif canImport(UIKit)
    UIApplication.shared.open(authorizationURL)
    #elseif os(macOS) || os(Linux)
    do {
        try openURLWithPython3(authorizationURL)
    
    } catch {
        print("couldn't open \(authorizationURL) with python3: \(error)")
    }
    #endif
    print(
        """

        ======================================================\
        ===============================================
        Open the following URL in your browser:

        \(authorizationURL)
        """
    )
    
    #if TEST
    print(
        """

        ======================================================\
        ===============================================
        Running local server to wait for redirect
        """
    )
    
    // MARK: retrieve the redirect URI from the server

    if dispatchGroup.wait(timeout: .now() + 60) == .timedOut {
        print("listening for redirect URI timed out after 60 seconds")
    }
    redirectListener.shutdown()
    
    if let redirectURIWithQuery = redirectURIWithQuery {
        return redirectURIWithQuery
    }
    print("couldn't get redirect URI from listener")
    return nil
    
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
        print("couldn't read redirect URI from standard input")
        return nil
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

#if os(macOS) || os(Linux)

/// Opens a URL in the default browser using python3 via a shell script.
public func openURLWithPython3(_ url: URL) throws {

    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
    task.arguments = ["-m", "webbrowser", "-t", url.absoluteString]
    try task.run()

}

#endif
