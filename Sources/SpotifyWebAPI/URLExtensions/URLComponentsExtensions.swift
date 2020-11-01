import Foundation

public extension URLComponents {

    init(
        scheme: String?,
        host: String?,
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
            path: path,
            queryItems: urlQueryItems,
            fragment: fragment
        )
    }


    init(
        scheme: String?,
        host: String?,
        path: String? = nil,
        queryItems: [URLQueryItem]?,
        fragment: String? = nil
    ) {
        self.init()
        self.scheme = scheme
        self.host = host
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
        path: String? = nil,
        queryString: String?,
        fragment: String? = nil
    ) {
        
        self.init()
        self.scheme = scheme
        self.host = host
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


    /// A dictionary of the query items in the URL.
    var queryItemsDict: [String: String] {

        return self.queryItems?.reduce(into: [:]) { dict, query in
            dict[query.name] = query.value
        } ?? [:]
    }
    
}

