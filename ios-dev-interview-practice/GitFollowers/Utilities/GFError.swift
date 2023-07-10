//
//  GFError.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/30/22.
//

import Foundation

public enum GFError: String, Error {
	case invalidUsername = "Wrong username format. Use alphanumerical, _, -."
	case networkError = "Network request failed with an error. Please try again."
	case invalidResponse = "Server returned with invalid response code. Please try again."
	case invalidData = "Data received from server is invalid. Please try again."
	case persistenceError = "There was a problem with storage. Please try again."
	case alreadyInFavorites = "You've already added this user to favorites!"
}
