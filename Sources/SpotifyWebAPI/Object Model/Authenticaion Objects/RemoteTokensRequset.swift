import Foundation

/**
 After the user has authorized your app and a code has been provided,
 this struct is used to request a refresh and access token for the
 [Authorization Code Flow][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
struct RemoteTokensRequest: Hashable, Codable {
	let code: String

	func formURLEncoded() -> Data {
		guard let data = ["code": code].formURLEncoded() else {
			fatalError("could not form-url-encode tokens request")
		}
		return data
	}
}
