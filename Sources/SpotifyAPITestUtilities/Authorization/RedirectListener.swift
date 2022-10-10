#if TEST
import Foundation
import Vapor

/// Manages a server that can be started to listen for when the Spotify web API
/// redirects to a specified redirect URI.
public struct RedirectListener {
    
    private let app: Application
    
    public let host: String
    public let port: Int
    public let pathComponents: [PathComponent]
    
    public private(set) var didRun = false
    
    /**
     Creates a listener that listens for redirects to the specified URL.
     
     - Parameters:
       - host: The host of the URL.
       - port: The port of the URL.
       - pathComponents: The path components of the URL.
     */
    public init(
        host: String = "localhost",
        port: Int = 8080,
        pathComponents: [PathComponent] = []
    ) {
        self.app = Application(
            Environment(
                name: "single_argument",
                arguments: [CommandLine.arguments.first!]
            )
        )
        self.host = host
        self.port = port
        self.pathComponents = pathComponents
        
    }
    
    /**
     Creates a listener that listens for redirects to the specified URL. The url
     *must* contain a host and a port.
    
     - Parameter url: The URL to listen for redirects to.
     */
    public init(url: URL) {
        self.init(
            host: url.host!,
            port: url.port!,
            pathComponents: url.vaporPathComponents
        )
    }
    
    /**
     Starts the server. Does not block; returns immediately after the server
     starts.
    
     - Parameter receiveURL: A closure that is called when the server receives
           the URL.
     */
    public mutating func start(
        receiveURL: @escaping (URL) -> Void
    ) throws {

        precondition(!self.didRun, "already ran listener")
        
        try self.configure(
            receiveURL: receiveURL
        )
        try self.app.start()
        self.didRun = true
    }

    /// Stops the server.
    public mutating func shutdown() {
        self.didRun = true
        self.app.shutdown()
    }
    
    private func configure(
        receiveURL: @escaping (URL) -> Void
    ) throws {

        self.app.http.server.configuration.hostname = self.host
        self.app.http.server.configuration.port = self.port

        var serverAddressURLComponents = URLComponents()
        serverAddressURLComponents.scheme = "http"
        serverAddressURLComponents.host = self.host
        serverAddressURLComponents.port = self.port

        // MARK: Register the route

        self.app.get(self.pathComponents) { request -> String in
            
            var urlComponents = serverAddressURLComponents
            if !(request.route?.path.isEmpty ?? true) {
                urlComponents.path = request.url.path
            }
            urlComponents.query = request.url.query
//            print("\n\nrequest.url.query: '\(request.url.query ?? "nil")'\n\n")
            let url = urlComponents.url!
            receiveURL(url)
            return "Received redirect. You can close this page."
            
        }

        
    }
    
}

public extension URL {
    
    var vaporPathComponents: [PathComponent] {
        if self.pathComponents.count < 2 {
            return []
        }
        return self.pathComponents[1...].map { "\($0)" }
    }

}

#endif
