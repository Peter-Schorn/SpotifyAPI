import Foundation

public extension String {

    enum PercentEncodingOptions {
        /// Encodes the string for use in a fragment URL component.
        case fragment
        /// Encodes the string for use in a host URL component.
        case host
        /// Encodes the string for use in a path URL component.
        case path
        /// Encodes the string for use in a password URL component.
        case password
        /// Encodes the string for use in a query URL component.
        case query
        /// Encodes the string for use in a user component.
        case user
        
        public var characterSet: CharacterSet {
            switch self {
                case .fragment:
                    return .urlFragmentAllowed
                case .host:
                    return .urlHostAllowed
                case .path:
                    return .urlPathAllowed
                case .password:
                    return .urlPasswordAllowed
                case .query:
                    return .urlQueryAllowed
                case .user:
                    return .urlUserAllowed
            }
        }
    }
    

    /// Percent encodes the string for the given option.
    func percentEncoded(_ option: PercentEncodingOptions) -> String? {
        return self.addingPercentEncoding(
            withAllowedCharacters: option.characterSet
        )
    }
    
    
}
