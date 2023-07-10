//
//  PersistenceManager.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/2/22.
//

import UIKit

// MARK: - PersistenceActionType

enum PersistenceActionType {
	case add, remove
}

// MARK: - PersistenceManager

enum PersistenceManager {

	typealias PersistenceResult<Value> = Result<Value, GFError>

	static private let defaults = UserDefaults.standard

	enum Keys {
		static let favorites = "favorites"
	}

	// MARK: Internal

	static func updateWith(
		favorite: Follower,
		actionType: PersistenceActionType,
		completion: @escaping (PersistenceResult<Void>) -> Void) {
		loadFavorites { loadResult in
			switch loadResult {
			case .success(var favorites):
				switch actionType {
				case .add:
					guard !favorites.contains(favorite) else {
						completion(.failure(.alreadyInFavorites))
						return
					}
					favorites.append(favorite)

				case .remove:
					favorites.removeAll { $0.login == favorite.login }
				}

				save(favorites: favorites) { saveResult in
					completion(saveResult)
				}

			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	static func loadFavorites(completion: @escaping (PersistenceResult<[Follower]>) -> Void) {
		guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
			completion(.success([]))
			return
		}

		guard let favorites = try? JSONDecoder().decode([Follower].self, from: favoritesData) else {
			completion(.failure(.persistenceError))
			return
		}
		
		completion(.success(favorites))
	}

	static func save(favorites: [Follower], completion: @escaping (PersistenceResult<Void>) -> Void) {
		guard let encodedFavorites = try? JSONEncoder().encode(favorites) else {
			completion(.failure(.persistenceError))
			return
		}

		defaults.set(encodedFavorites, forKey: Keys.favorites)

		completion(.success)
	}
}
