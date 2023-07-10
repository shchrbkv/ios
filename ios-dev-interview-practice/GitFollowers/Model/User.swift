//
//  User.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import Foundation

public struct User: Codable {
	let login: String
	let avatarUrl: String
	var name: String?
	var location: String?
	var bio: String?
	let publicRepos: Int
	let publicGists: Int
	let htmlUrl: String
	let following: Int
	let followers: Int
	let createdAt: Date
}
