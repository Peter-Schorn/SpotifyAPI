import Foundation


public extension URL {

    /// Returns a new URL with the specified query items appended to it.
    func appending(queryItems: [URLQueryItem]) -> URL? {

        guard var urlComponents = URLComponents(
            url: self, resolvingAgainstBaseURL: false
        ) else {
            return nil
        }

        // The query items that were already in the URL.
        var currentQueryItems = urlComponents.queryItems ??  []

        // Add the new query items to the existing ones.
        currentQueryItems.append(contentsOf: queryItems)

        urlComponents.queryItems = currentQueryItems

        return urlComponents.url
    }

    /// Returns a new URL with the specified query items appended to it.
    func appending(queryItems: [String: String]) -> URL? {

        let urlQueryItems = queryItems.map { item in
            URLQueryItem(name: item.key, value: item.value)
        }
        return self.appending(queryItems: urlQueryItems)

    }

    /// Returns a new URL with the query items removed.
    /// If the URL has fragments, they will be removed too.
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

    /// Returns a new URL with the trailing slash in the path component
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
    
    /// Returns a new URL with the trailing slash in the path component
    /// removed if it exists.
    mutating func removeTrailingSlashInPath() {
        self = self.removingTrailingSlashInPath()
    }
    
    /// Removes the query items from the URL.
    /// If the URL has fragments, they will be removed too.
    mutating func removeQueryItems() {
        self = self.removingQueryItems()
    }


    /// The query items in the URL. See also `queryItemsDict`.
    var queryItems: [URLQueryItem] {
        return components?.queryItems ?? []
    }

    /// A dictionary of the query items in the URL. See also `queryItems`.
    var queryItemsDict: [String: String] {

        return self.queryItems.reduce(into: [:]) { dict, query in
            dict[query.name] = query.value
        }
    }

    /// The URL components of this URL.
    var components: URLComponents? {
        return URLComponents(
            url: self, resolvingAgainstBaseURL: false
        )
    }

    // MARK: Initializers
    
    init?(
        string: String,
        sortQueryItems: Bool
    ) {
        guard let url = URL(string: string) else {
            return nil
        }
        if !sortQueryItems { self = url }
        
        guard var urlComponents = url.components else {
            return nil
        }
        urlComponents.queryItems?.sortByNameThenValue()
        
        guard let sortedURL = urlComponents.url else {
            return nil
        }
        self = sortedURL
        
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
