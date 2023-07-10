//
//  FavoritesViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/28/22.
//

import UIKit

// MARK: - FavoritesViewController

class FavoritesViewController: GFDataLoadingViewController {

	let tableView = UITableView()
	var favorites: [Follower] = []

	var inEmptyState = false

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		configureViewController()
		configureTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		getFavorites()
	}

	// MARK: Private

	private func configureViewController() {
		title = "Favorites"
		view.backgroundColor = .systemBackground
		navigationController?.navigationBar.prefersLargeTitles = true
	}

	private func configureTableView() {
		view.addSubview(tableView)

		tableView.frame = view.bounds
		tableView.rowHeight = 80
		tableView.delegate = self
		tableView.dataSource = self

		tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
	}

	private func getFavorites() {
		PersistenceManager.loadFavorites { [weak self] result in

			guard let self else { return }

			switch result {
			case .success(let favorites):
				self.updateUI(with: favorites)

			case .failure(let error):
				self.presentGFAlertOnMainThread(title: "Loading Failed", message: error.rawValue, buttonTitle: "Ok")
			}
		}
	}
	
	private func updateUI(with favorites: [Follower]) {
		switch (favorites.isEmpty, self.inEmptyState) {
		case (true, true):
			return

		case (true, false):
			self.inEmptyState = true
			let message = "No Favorites... yet?"
			DispatchQueue.main.async { self.showEmptyStateView(with: message, in: self.view) }
			return

		case (false, _):
			self.inEmptyState = false
		}

		self.favorites = favorites

		DispatchQueue.main.async {
			self.tableView.reloadData()
			self.view.bringSubviewToFront(self.tableView)
		}
	}
}

// MARK: UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		favorites.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID, for: indexPath) as! FavoriteCell
		let favorite = favorites[indexPath.row]

		cell.set(favorite: favorite)
		return cell
	}
}

// MARK: UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let favorite = favorites[indexPath.row]
		let destinationViewController = FollowersViewController(username: favorite.login)

		navigationController?.pushViewController(destinationViewController, animated: true)
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard case .delete = editingStyle else { return }

		let favorite = favorites[indexPath.row]

		PersistenceManager.updateWith(favorite: favorite, actionType: .remove) { [weak self] persitenceResult in
			guard let self else { return }

			if case .failure(let error) = persitenceResult {
				self.presentGFAlertOnMainThread(title: "Deleting Failed",
				                                message: error.rawValue,
				                                buttonTitle: "Ok")
				return
			}

			self.favorites.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .left)

			self.getFavorites()
		}
	}
}
