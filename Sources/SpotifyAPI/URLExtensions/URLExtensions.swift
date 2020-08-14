import Foundation


public extension URL {

    /// Returns a new url with the specified query items appended to it.
    func appending(queryItems: [URLQueryItem]) -> URL? {

        guard var urlComponents = URLComponents(
            url: self, resolvingAgainstBaseURL: false
        ) else {
            return nil
        }

        var currentQueryItems = urlComponents.queryItems ??  []

        currentQueryItems.append(contentsOf: queryItems)

        urlComponents.queryItems = currentQueryItems

        return urlComponents.url
    }

    /// Returns a new url with the specified query items appended to it.
    func appending(queryItems: [String: String]) -> URL? {

        let urlQueryItems = queryItems.map { item in
            URLQueryItem(name: item.key, value: item.value)
        }
        return self.appending(queryItems: urlQueryItems)

    }

    /// Appends the query items to the url.
    ///
    /// - Warning: Throws a fatalError if a new URL could
    ///       not be constructed.
    mutating func append(queryItems: [URLQueryItem]) {
        guard let url = self.appending(queryItems: queryItems) else {
            fatalError(
                """
                could not construct new url after appending query items.
                original url: '\(self)'
                queryItems: '\(queryItems)'
                """
            )
        }
        self = url
    }

    /// Appends the query items to the url.
    ///
    /// - Warning: Throws a fatalError if a new URL could
    ///       not be constructed.
    mutating func append(queryItems: [String: String]) {
        let urlQueryItems = queryItems.map { item in
            URLQueryItem(name: item.key, value: item.value)
        }
        self.append(queryItems: urlQueryItems)
    }

    /// Returns a new url with the query items removed.
    /// If the url has fragments, they will be removed too.
    func removingQueryItems() -> URL {
        guard let url = URL(
            scheme: self.scheme,
            host: self.host,
            path: self.path
        )
        else {
            fatalError(
                "could not construct new url after removing query items\n" +
                "original url: '\(self)'"
            )
        }
        return url
    }

    /// Returns a new url with the trailing slash in the path component
    /// removed if it exists.
    func removingTrailingSlashInPath() -> URL {
        var components = self.components!
        var path = components.path
        if path.hasSuffix("/") {
            let lastCharacterIndex = path.index(before: path.endIndex)
            path.replaceSubrange(lastCharacterIndex...lastCharacterIndex, with: "")
            components.path = path
        }
        return components.url!
        
    }
    
    /// Returns a new url with the trailing slash in the path component
    /// removed if it exists.
    mutating func removeTrailingSlashInPath() {
        self = self.removingTrailingSlashInPath()
    }
    
    
    
    /// Removes the query items from the url.
    /// If the url has fragments, they will be removed too.
    mutating func removeQueryItems() {
        self = self.removingQueryItems()
    }


    /// The query items in the url.
    var queryItems: [URLQueryItem] {
        return components?.queryItems ?? []
    }

    /// A dictionary of the query items in the url.
    var queryItemsDict: [String: String] {

        return self.queryItems.reduce(into: [:]) { dict, query in
            dict[query.name] = query.value
        }
    }

    /// The url components of this url.
    var components: URLComponents? {
        return URLComponents(
            url: self, resolvingAgainstBaseURL: false
        )
    }



    init?(
        scheme: String?,
        host: String?,
        path: String? = nil,
        queryItems: [String: String]? = nil,
        fragment: String? = nil
    ) {

        if let url = URLComponents(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems,
            fragment: fragment
        ).url {
            self = url
        }
        else {
            return nil
        }

    }

    init?(
        scheme: String?,
        host: String?,
        path: String? = nil,
        queryItems: [URLQueryItem]?,
        fragment: String? = nil
    ) {

        if let url = URLComponents(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems,
            fragment: fragment
        ).url {
            self = url
        }
        else {
            return nil
        }
    }

    init?(
        scheme: String?,
        host: String?,
        path: String? = nil,
        queryString: String?,
        fragment: String? = nil
    ) {

        if let url = URLComponents(
            scheme: scheme,
            host: host,
            path: path,
            queryString: queryString,
            fragment: fragment
        ).url {
            self = url
        }
        else {
            return nil
        }
    }


}


/// Encodes a dictionary of URL queries into data according to
/// `application/x-www-form-urlencoded`.
///
/// Returns `nil` if the query string cannot be converted to
/// `Data` using a utf-8 character encoding.
public func formURLEncode(_ dict: [String: String]) -> Data? {

    var urlComponents = URLComponents()
    urlComponents.queryItems = dict.map { item in
        URLQueryItem(name: item.key, value: item.value)
    }
    return urlComponents.query?.data(using: .utf8)
}
