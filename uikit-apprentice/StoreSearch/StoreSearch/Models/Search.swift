//
//  Search.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/15/22.
//

import Foundation

class Search {
	
	enum State {
		case idle
		case loading
		case noResults
		case results([SearchResult])
	}
	
	private(set) var state: State = .idle
	private var dataTask: URLSessionDataTask?
	
	typealias SearchComplete = (Bool) -> Void
	
	func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
		if text.isEmpty { return }
		
		dataTask?.cancel()
		
		state = .loading
		
		let url = iTunesURL(searchText: text, category: category)
		let session = URLSession.shared
		
		dataTask = session.dataTask(with: url) { data, response, error in
			var success = false
			
			if let error = error as NSError?, error.code == -999 { return }
			
			var newState: State = .idle
			
			if let httpResponse = response as? HTTPURLResponse,
			   httpResponse.statusCode == 200,
			   let data = data {
				
				var searchResults = self.parse(data: data)
				
				if searchResults.isEmpty {
					newState = .noResults
				} else {
					searchResults.sort(by: <)
					newState = .results(searchResults)
				}
				
				success = true
			}
			
			DispatchQueue.main.async {
				self.state = newState
				completion(success)
			}
		}
		dataTask?.resume()
	}
	
	enum Category: Int {
		case all, music, software, ebooks
		
		var type: String {
			switch self {
			case .music: return "musicTrack"
			case .software: return "software"
			case .ebooks: return "ebook"
			case .all: return ""
			}
		}
	}
	
	private func iTunesURL(searchText: String, category: Category) -> URL {
		
		let kind = category.type
		
		let locale = Locale.autoupdatingCurrent
		let language = locale.identifier
		let countryCode = locale.regionCode ?? "en_US"
		
		let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		let urlString = "https://itunes.apple.com/search?" +
						"term=\(encodedText)&entity=\(kind)" +
						"&lang=\(language)&country=\(countryCode)"
		
		
		
		let url = URL(string: urlString)
		return url!
	}
	
	private func parse(data: Data) -> [SearchResult] {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(ResultArray.self, from: data)
			return result.results
		} catch {
			debugPrint(error)
			return []
		}
	}
}
