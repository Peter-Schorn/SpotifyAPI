import Foundation
import SpotifyWebAPI

public struct SeleniumBrowserAuthorizer {
    
    static let authorizerScriptPath: String? = {
        return Bundle.module.url(
            forResource: "spotify_api_authorizer",
            withExtension: "py"
        )?.path
    }()

    public let button: AuthorizationPageButton
    public let redirectURI: URL
    // MARK: TODO: make mutable so multiple authorization requests can be made
    // MARK: with the same instance?
    public let authorizationURL: URL

    public init(
        button: AuthorizationPageButton,
        redirectURI: URL,
        authorizationURL: URL
    ) {
        self.button = button
        self.redirectURI = redirectURI
        self.authorizationURL = authorizationURL
    }
    
    /// Returns redirectURIWithQuery
    public func authorize(timeout: Double) -> URL? {
        
#if os(macOS) || os(Linux)
        DistributedLock.redirectListener.lock()
        defer {
            DistributedLock.redirectListener.unlock()
        }

        guard let spotifyDC = spotifyDCCookieValue else {
            print("spotifyDCCookieValue was nil")
            return nil
        }
        
        guard let scriptPath = Self.authorizerScriptPath else {
            print("couldn't get path of spotify_api_authorizer.py script")
            return nil
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        
        process.arguments = [
            "python3", scriptPath,
            "--button", self.button.rawValue,
            "--sp-dc", spotifyDC,
            "--redirect-uri", self.redirectURI.absoluteString,
            "--url", self.authorizationURL.absoluteString,
            "--timeout", "\(timeout)"
        ]
        
        if ProcessInfo.processInfo
                .environment["SPOTIFY_API_AUTHORIZER_NON_HEADLESS"] == "true" {
            process.arguments!.append("--non-headless")
        }

        let stdout = Pipe()
        let stderror = Pipe()
        process.standardOutput = stdout
        process.standardError = stderror
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let exitCode = process.terminationStatus
            let stdoutString = stdout.asString() ?? ""
            let stderrorString = stderror.asString() ?? ""
            print("exit code: \(exitCode)")
            print("stdout: `\(stdoutString)`")
            print("stderror: `\(stderrorString)`")
            
            guard
                process.terminationStatus == 0,
                let redirectURIWithQuery = stdoutString
                    .split(separator: "\n")
                    .last
                    .map(String.init(_:))?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            else {
                print("could not get redirectURIWithQuery")
                return nil
            }
            
            if let url = URL(string: redirectURIWithQuery) {
                return url
            }
            else {
                print(
                    """
                    could not convert redirectURIWithQuery string to \
                    URL: '\(redirectURIWithQuery)'
                    """
                )
                return nil
            }
            
        } catch {
            print("caught error: \(error)")
            return nil
        }
#else
        return nil
#endif
        
    }

}

public extension Pipe {
    
    func asString(encoding: String.Encoding = .utf8) -> String? {
        let data = self.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: encoding)
    }
    
}
