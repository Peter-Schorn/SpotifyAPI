import Foundation

extension URLComponents {

    init(
        scheme: String?,
        host: String?,
        port: Int? = nil,
        path: String? = nil,
        queryItems: [String: String]? = nil,
        fragment: String? = nil
    ) {
        let urlQueryItems = queryItems?.map { item in
            URLQueryItem(name: item.key, value: item.value)
        }

        self.init(
            scheme: scheme,
            host: host,
            port: port,
            path: path,
            queryItems: urlQueryItems,
            fragment: fragment
        )
    }

    init(
        scheme: String?,
        host: String?,
        port: Int? = nil,
        path: String? = nil,
        queryItems: [URLQueryItem]?,
        fragment: String? = nil
    ) {
        self.init()
        self.scheme = scheme
        self.host = host
        self.port = port
        if let path = path {
            self.path = path
        }
        
        if let queryItems = queryItems?.sortedByNameThenValue(),
               !queryItems.isEmpty {
            self.queryItems = queryItems
        }
        if let fragment = fragment, !fragment.isEmpty {
            self.fragment = fragment
        }
    }

    init(
        scheme: String?,
        host: String?,
        port: Int? = nil,
        path: String? = nil,
        queryString: String?,
        fragment: String? = nil
    ) {
        
        self.init()
        self.scheme = scheme
        self.host = host
        self.port = port
        if let path = path {
            self.path = path
        }
        
        if let queryString = queryString, !queryString.isEmpty {
            self.query = queryString
        }
        if let fragment = fragment, !fragment.isEmpty {
            self.fragment = fragment
            
        }
        
    }
    
}

public extension URLComponents {

    /// A dictionary of the query items in the URL.
    var queryItemsDict: [String: String] {
        get {
            return self.queryItems?.reduce(into: [:]) { dict, query in
                dict[query.name] = query.value
            } ?? [:]
        }
        set {
            self.queryItems = newValue.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
    }
    

    /// Returns a new URL with the trailing slash in the path component removed
    /// if it exists.
    func removingTrailingSlashInPath() -> URLComponents {
        var copy = self
        copy.removeTrailingSlashInPath()
        return copy
        
    }

    /// Removes the trailing slash in the path component, if it exists.
    mutating func removeTrailingSlashInPath() {
        if self.path.hasSuffix("/") {
            let index = self.path.index(before: self.path.endIndex)
            self.path.remove(at: index)
        }
    }

}
