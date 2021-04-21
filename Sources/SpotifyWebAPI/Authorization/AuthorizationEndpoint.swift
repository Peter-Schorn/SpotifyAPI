//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 15.04.21.
//

import Foundation
import Logging

public final class AuthorizationFlowLogging {
	/// The logger for this class. By default, its level is `critical`.
	public static var logger = Logger(
		label: "AuthorizationFlowLogging", level: .critical
	)
}

public protocol AuthorizationCodeFlowEndpoint: Codable, Hashable {
	var clientId: String { get }
	
	func makeTokenRequest(code: String, redirectURIWithQuery: URL) -> URLRequest
	func makeTokenRefreshRequest(refreshToken: String) -> URLRequest
}

public protocol AuthorizationCodeFlowPKCEEndpoint: AuthorizationCodeFlowEndpoint {
	func makePKCETokenRequest(code: String, codeVerifier: String, redirectURIWithQuery: URL) -> URLRequest
	func makePKCETokenRefreshRequest(refreshToken: String) -> URLRequest
}
