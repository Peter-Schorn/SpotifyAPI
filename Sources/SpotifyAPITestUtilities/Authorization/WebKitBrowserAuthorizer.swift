#if canImport(WebKit)
import Foundation
import SpotifyWebAPI
@preconcurrency import WebKit

/// Can open an authorization URL and click the accept or cancel dialog and
/// then return the redirect URI with the query.
public class WebKitBrowserAuthorizer: NSObject {
    
    public let webView: WKWebView
    
    public let button: AuthorizationPageButton
    public let redirectURI: URL
    // MARK: TODO: make mutable so multiple authorization requests can be made
    // MARK: with the same instance?
    public let authorizationURL: URL
    
    var redirectURIWithQuery: URL? = nil
    var didReceiveRedirect = false

    static let maxRetries = 4
    var retries = WebKitBrowserAuthorizer.maxRetries

    /// Ensures the cookie is set before loading the authorization page.
    let setCookieDispatchGroup = DispatchGroup()
    
    /// Returns `nil` if the "SPOTIFY_DC" environment variable does not exist or
    /// if the cookie cannot be created from it.
    required public init(
        button: AuthorizationPageButton,
        redirectURI: URL,
        authorizationURL: URL
    ) {
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        self.webView = WKWebView(frame: .zero, configuration: configuration)

        self.button = button
        self.redirectURI = redirectURI
        self.authorizationURL = authorizationURL
        super.init()
        self.webView.navigationDelegate = self

    }
    
    /// Returns `true` if the "SPOTIFY_DC" environment variable exists and the
    /// cookie can be created from it. Else, `false`.
    func configureCookies() -> Bool {
        
        guard let spotifyDCCookie = spotifyDCCookieValue else {
            print("could not find 'SPOTIFY_DC' in environment variables")
            return false
        }

        guard let cookie = HTTPCookie(
            properties: [
                .version: 1,
                .name: "sp_dc",
                .value: spotifyDCCookie,
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
        
        let wkCookieJar = self.webView.configuration.websiteDataStore
            .httpCookieStore

        self.setCookieDispatchGroup.enter()
        wkCookieJar.setCookie(cookie) {
            print("wkCookieJar did set cookie: \(cookie.name)")
            wkCookieJar.getAllCookies { cookies in
                print("\n--- webViewCookieJar has \(cookies.count) cookies ---")
                for cookie in cookies {
                    print(cookie.name)
                }
                print("--------------------------------------\n")
                self.setCookieDispatchGroup.leave()
            }
        }

        return true

    }
    
    /// Timeout is expressed in seconds. Should be called on the main thread
    public func authorize(timeout: Double) -> URL? {
        
        if !self.configureCookies() {
            return nil
        }

        self.redirectURIWithQuery = nil

        self.setCookieDispatchGroup.notify(queue: .main) {
            self.loadAuthorizationURL()
        }
        CFRunLoopRunInMode(.defaultMode, timeout, false)
        
        return self.redirectURIWithQuery
    }
    
    func loadAuthorizationURL() {
        
        self.didReceiveRedirect = false

        // ensure the cookie is set before loading the authorization URL
        let request = URLRequest(url: self.authorizationURL)
        self.webView.load(request)
        print(
            """
            HeadlessBrowserAuthorizer.loadAuthorizationURL: loading \
            \(self.authorizationURL)
            """
        )
        
    }
    
    func reloadDelay() -> Double {
        // retries = 3, 2, 1, 0
        return Double(4 - self.retries)
        // delay = 1, 2, 3, 4
    }
    
}

// WKNavigationDelegate must be used from the main thread
extension WebKitBrowserAuthorizer: WKNavigationDelegate {
    
    // MARK: - Did Finish Navigation -

    public func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        
        print("--- did finish navigation ---")

        guard let url = webView.url else {
            print(
                "returning early from webView(_:didFinish:) because " +
                "webView.url was nil"
            )
            return
        }

        print("url: \(url)")
        
        guard
            // The authorization URL should look something like this, although
            // it may contain a different country code:
            // https://accounts.spotify.com/en/authorize
            url.host == Endpoints.accountsBase,
            url.pathComponents.last == "authorize"
        else {
            print("will not evaluate JavaScript for URL \(url)")
            return
        }
        
        let clickCancelButtonScript = """
            document.querySelector("[data-testid='auth-cancel']").click()
            """
        
        let clickAcceptButtonScript = """
            document.querySelector("[data-testid='auth-accept']").click()
            """
        
        let script = self.button == .accept ? clickAcceptButtonScript :
            clickCancelButtonScript
        
        print("webView.evaluateJavaScript: \(script)")
        
        webView.evaluateJavaScript(
            script
        ) { result, error in
            if let error = error {
                print("error clicking \(self.button.rawValue) button: \(error)")
                if self.retries > 0 {
                    self.retries -= 1
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + self.reloadDelay()
                    ) {
                        print("will reload web page; retries: \(self.retries)")
                        webView.reload()
                    }
                }
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
        
        print("baseURL: \(baseURL)")
        
        if baseURL == self.redirectURI {
            // MARK: Successfully retrieved redirectURIWithQuery
            self.retries = Self.maxRetries
            self.didReceiveRedirect = true
            self.redirectURIWithQuery = url
            decisionHandler(.cancel, .init())
            CFRunLoopStop(CFRunLoopGetMain())
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
        print(
            """
            navigationResponse: \(url)
            status code: \(statusCode)
            """
        )
    
        decisionHandler(.allow)
    
    }
    
    // MARK: - Failures -
    
    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("didFail navigation: error: \(error)")
        if self.retries > 0 {
            self.retries -= 1
            DispatchQueue.main.asyncAfter(
                deadline: .now() + self.reloadDelay()
            ) {
                print("will loadAuthorizationURL again")
                self.loadAuthorizationURL()
            }
        }
    }
    
    
    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        if !self.didReceiveRedirect {
            print("didFailProvisionalNavigation: error: \(error)")
            if self.retries > 0 {
                self.retries -= 1
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + self.reloadDelay()
                ) {
                    print("will loadAuthorizationURL again")
                    self.loadAuthorizationURL()
                }
            }
            
        }
    }
    
}

#endif
