import Foundation
#if canImport(WebKit)
import WebKit
#endif

/// Can open an authorization URL and click the accept or cancel dialog and
/// then return the redirect URI with the query.
public class HeadlessBrowserAuthorizer: NSObject {
    
    /// The button to click on the authorization page.
    public enum Button: String {
        case accept
        case cancel
    }
    
    #if canImport(WebKit)
    
    public let webView = WKWebView()
    
    public var didReceiveRedirect = false
    
    public let button: Button
    public let redirectURI: URL
    public let receiveRedirectURIWithQuery: (URL) -> Void
    
    /// Ensures the cookie is set before loading the authorization page.
    public let setCookieDispatchGroup = DispatchGroup()
    
    /// Returns `nil` if the "SPOTIFY_DC" environment variable does not exist or
    /// if the cookie cannot be created from it.
    public init?(
        button: Button,
        redirectURI: URL,
        receiveRedirectURIWithQuery: @escaping (URL) -> Void
    ) {
        
        self.button = button
        self.redirectURI = redirectURI
        self.receiveRedirectURIWithQuery = receiveRedirectURIWithQuery
        super.init()
        self.webView.navigationDelegate = self
     
        if !self.configureCookies() {
            return nil
        }

    }
    
    /// Returns `true` if the "SPOTIFY_DC" environment variable exists and the
    /// cookie can be created from it. Else, `false`.
    func configureCookies() -> Bool {
        
        guard let spotifyDCCookieValue = spotifyDCCookieValue else {
            print("could not find 'SPOTIFY_DC' in environment variables")
            return false
        }
        
        guard let cookie = HTTPCookie(
            properties: [
                .version: 1,
                .name: "sp_dc",
                .value: spotifyDCCookieValue,
                // the real cookie expires in a year
                .expires: Date.distantFuture,
                .discard: false,
                .domain: ".spotify.com",
                .path: "/",
                .secure: true
            ]
        ) else {
            print("could not create 'sp_dc' cookie")
            return false
        }
        
        let wkCookieJar = WKWebsiteDataStore.default().httpCookieStore

        self.setCookieDispatchGroup.enter()
        wkCookieJar.setCookie(cookie) {
            print("wkCookieJar did set cookie: \(cookie.name)")
            self.setCookieDispatchGroup.leave()
        }

        return true

    }
    
    public func loadAuthorizationURL(_ url: URL) {
        
        // ensure the cookie is set before loading the authorization URL
        self.setCookieDispatchGroup.notify(queue: .main) {
            let request = URLRequest(url: url)
            self.webView.load(request)
            print("HeadlessBrowserAuthorizer.loadAuthorizationURL: did load")
        }
    }
    
    #endif

}

#if canImport(WebKit)

extension HeadlessBrowserAuthorizer: WKNavigationDelegate {
    
    public func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        
        print("--- did finish navigation ---")
        print("url: \(webView.url?.absoluteString ?? "nil")")
        
        let clickCancelButtonScript = """
            document.getElementById("auth-cancel").click()
            """
        
        let clickAcceptButtonScript = """
            document.getElementById("auth-accept").click()
            """
        
        let script = self.button == .accept ? clickAcceptButtonScript :
            clickCancelButtonScript
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("error clicking \(self.button.rawValue) button: \(error)")
            }
            else if let result = result {
                print("click \(self.button.rawValue) button result: \(result)")
            }
            else {
                print("executed click \(self.button.rawValue) button; no result")
            }
        }
        
    }
    
    // MARK: - Decide Policy -
    
    // MARK: Request
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        
        let url = navigationAction.request.url!
        
        print("preference navigationAction request: \(url)")
        
        let baseURL = url
            .removingQueryItems()
            .removingTrailingSlashInPath()
        
        if baseURL == self.redirectURI {
//            print("redirectURIWithQuery: \(url)")
            self.didReceiveRedirect = true
            self.receiveRedirectURIWithQuery(url)
            decisionHandler(.cancel, .init())
        }
        else {
            decisionHandler(.allow, .init())
        }
        
    }
    
    // MARK: Response
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        
        let statusCode = (navigationResponse.response as! HTTPURLResponse)
            .statusCode
        
        let url = navigationResponse.response.url?.absoluteString ?? "nil"
        print("navigationResponse: \(url)")
        
        if statusCode != 200 {
            print("unexpected status code: \(statusCode)")
            if (500..<600).contains(statusCode) {
                print("reloading page")
                webView.reloadFromOrigin()
            }
        }
        
        decisionHandler(.allow)
        
    }
    
    // MARK: - Failures -
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail navigation: error: \(error)")
    }
    
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !self.didReceiveRedirect {
            print("didFailProvisionalNavigation: error: \(error)")
        }
    }
    
}

// MARK: - HTTP Cookie Extensions -

//extension HTTPCookie {
//
//    func archivedData() throws -> Data? {
//        guard let properties = self.properties else {
//            return nil
//        }
//        return try NSKeyedArchiver.archivedData(
//            withRootObject: properties,
//            requiringSecureCoding: false
//        )
//    }
//
//    convenience init?(archivedData: Data) throws {
//        guard let properties = try NSKeyedUnarchiver
//                .unarchiveTopLevelObjectWithData(archivedData)
//                as? [HTTPCookiePropertyKey : Any] else {
//            return nil
//        }
//        self.init(properties: properties)
//    }
//
//
//}

#endif
