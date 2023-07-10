//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/13/22.
//

import Foundation

class ResultArray: Codable {
	var resultCount = 0
	var results: [SearchResult] = []
}

class SearchResult: Codable, Comparable {
	
	var kind: String?
	var artistName: String?
	var imageSmall = ""
	var imageLarge = ""
	
	var collectionName: String?
	var trackName: String?
	
	var collectionViewUrl: String?
	var trackViewUrl: String?
	
	var currency = ""
	
	var trackPrice: Double?
	var collectionPrice: Double?
	var itemPrice: Double?
	
	var itemGenre: String?
	var bookGenre: [String]?
	
	enum CodingKeys: String, CodingKey {
		case kind, artistName, currency, trackName, trackPrice, trackViewUrl, collectionName, collectionViewUrl, collectionPrice
		case imageSmall = "artworkUrl60"
		case imageLarge = "artworkUrl100"
		case itemGenre = "primaryGenreName"
		case bookGenre = "genres"
		case itemPrice = "price"
	}
	
	private let typeForKind = [
	  "album": NSLocalizedString(
		"Album",
		comment: "Localized kind: Album"),
	  "audiobook": NSLocalizedString(
		"Audio Book",
		comment: "Localized kind: Audio Book"),
	  "book": NSLocalizedString(
		"Book",
		comment: "Localized kind: Book"),
	  "ebook": NSLocalizedString(
		"E-Book",
		comment: "Localized kind: E-Book"),
	  "feature-movie": NSLocalizedString(
		"Movie",
		comment: "Localized kind: Feature Movie"),
	  "music-video": NSLocalizedString(
		"Music Video",
		comment: "Localized kind: Music Video"),
	  "podcast": NSLocalizedString(
		"Podcast",
		comment: "Localized kind: Podcast"),
	  "software": NSLocalizedString(
		"App",
		comment: "Localized kind: Software"),
	  "song": NSLocalizedString(
		"Song",
		comment: "Localized kind: Song"),
	  "tv-episode": NSLocalizedString(
		"TV Episode",
		comment: "Localized kind: TV Episode")
	]
	
	// MARK: - Computed
	
	var type: String {
		let kind = self.kind ?? "audiobook"
		return typeForKind[kind] ?? kind
	}
	
	
	var name: String {
		trackName ?? collectionName ?? ""
	}
	
	var artist: String {
		artistName ?? ""
	}
	
	var storeURL: String {
		trackViewUrl ?? collectionViewUrl ?? ""
	}
	
	var price: Double {
		trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
	}
	
	var genre: String {
		if let genre = itemGenre {
			return genre
		}
		if let genres = bookGenre {
			return genres.joined(separator: ", ")
		}
		return ""
	}
	
	// MARK: - Operations
	
	static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
		lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
	}
	
	static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
		lhs.storeURL == rhs.storeURL
	}
}
