//
//  FollowersViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import UIKit

// MARK: - FollowersViewController

class FollowersViewController: GFDataLoadingViewController {

	private enum Section { case main }

	var username: String!

	var collectionView: UICollectionView!
	private var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!

	var followers: [Follower] = []
	var page = 1
	var hasMoreFollowers = true
	var filteredFollowers: [Follower] = []
	var isSearching = false
	var isLoadingMoreFollowers = false

	// MARK: Lifecycle

	init(username: String) {
		super.init(nibName: nil, bundle: nil)
		self.username = username
		title = username
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		configureViewController()
		configureSearchController()
		configureCollectionView()
		getFollowers(username: username, page: 1)
		configureDataSource()
	}

	override func viewWillAppear(_ animated: Bool) {
		// Hidden on Search VC
		navigationController?.setNavigationBarHidden(false, animated: true)
	}

	// MARK: Private

	private func configureViewController() {
		view.backgroundColor = .systemBackground
		navigationController?.navigationBar.prefersLargeTitles = true

		let addAction = UIAction(handler: addButtonTapped(action:))
		let addButton = UIBarButtonItem(systemItem: .add, primaryAction: addAction)

		navigationItem.rightBarButtonItem = addButton
	}

	private func addButtonTapped(action: UIAction) {
		showLoadingView()
		
		Task {
			do {
				let user = try await NetworkManager.shared.getUserInfo(for: username)
				addToFavorites(user: user)
			} catch {
				if let error = error as? GFError {
					presentGFAlert(title: "Error",
								   message: error.rawValue,
								   buttonTitle: "Ok")
				} else {
					presentDefaultErrorGFAlert()
				}
			}
			dismissLoadingView()
		}

//		NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
//			guard let self else { return }
//			self.dismissLoadingView()
//
//			switch result {
//			case .success(let user):
//				self.addToFavorites(user: user)
//
//			case .failure(let error):
//				self.presentGFAlertOnMainThread(title: "Error", message: error.rawValue, buttonTitle: "Ok")
//			}
//		}
	}

	private func addToFavorites(user: User) {
		let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)

		PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] persitenceResult in
			guard let self else { return }

			switch persitenceResult {
			case .success:
				self.presentGFAlertOnMainThread(title: "Added",
				                                message: "User was successfully added to favorites!",
				                                buttonTitle: "Great!")

			case .failure(let error):
				self.presentGFAlertOnMainThread(title: "Error",
				                                message: error.rawValue,
				                                buttonTitle: "Ok")
			}
		}
	}

	private func getFollowers(username: String, page: Int) {
		showLoadingView()
		isLoadingMoreFollowers = true

		Task {
			do {
				let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
				updateUI(with: followers)
			} catch {
				if let error = error as? GFError {
					presentGFAlert(title: "Everything broke",
					               message: error.rawValue,
					               buttonTitle: "Sad, but ok")
				} else {
					presentDefaultErrorGFAlert()
				}
			}

			dismissLoadingView()
		}

//		NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
//
//			guard let self else { return }
//
//			self.dismissLoadingView()
//
//			switch result {
//			case .success(let followers):
//				self.updateUI(with: followers)
//
//			case .failure(let error):
//				self.presentGFAlertOnMainThread(title: "Everything broke",
//				                                message: error.rawValue,
//				                                buttonTitle: "Sad, but ok")
//			}
//
//			self.isLoadingMoreFollowers = false
//		}
	}

	private func configureSearchController() {
		let searchController = UISearchController()
		searchController.searchResultsUpdater = self
		searchController.searchBar.placeholder = "Search for a username"
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
	}

	private func updateUI(with followers: [Follower]) {
		if followers.count < 100 { hasMoreFollowers = false }
		self.followers.append(contentsOf: followers)

		if self.followers.isEmpty {
			let message = "This person doesn't have any followers :("

			DispatchQueue.main.async {
				self.navigationItem.searchController = nil
				self.navigationController?.view.setNeedsLayout()
				self.navigationController?.view.layoutSubviews()
				self.showEmptyStateView(with: message, in: self.view)
			}
		}
		updateData(on: followers)
	}
}

// MARK: - Collection View Configuration
extension FollowersViewController {

	// MARK: Public

	public func updateData(on followers: [Follower]) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
		snapshot.appendSections([.main])
		snapshot.appendItems(followers)
		DispatchQueue.main.async {
			self.dataSource.apply(snapshot, animatingDifferences: true)
		}
	}

	// MARK: Private

	// MARK: Configuration

	private func configureCollectionView() {
		collectionView = UICollectionView(frame: view.bounds,
		                                  collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
		view.addSubview(collectionView)
		collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseId)
		collectionView.delegate = self
		collectionView.alwaysBounceVertical = true
	}

	private func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<Section,
			Follower>(collectionView: collectionView) { collectionView, indexPath, follower -> UICollectionViewCell? in
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseId,
				                                              for: indexPath) as! FollowerCell
				cell.set(follower: follower)
				return cell
			}
	}
}

// MARK: UICollectionViewDelegate

extension FollowersViewController: UICollectionViewDelegate {

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		let height = scrollView.bounds.height

		if offsetY > contentHeight - height {
			guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
			page += 1
			getFollowers(username: username, page: page)
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let userInfoViewController = UserInfoViewController()
		let navController = UINavigationController(rootViewController: userInfoViewController)

		let activeArray = isSearching ? filteredFollowers : followers
		let follower = activeArray[indexPath.item]

		userInfoViewController.username = follower.login
		userInfoViewController.delegate = self

		present(navController, animated: true)
	}

}

// MARK: UISearchResultsUpdating

extension FollowersViewController: UISearchResultsUpdating {

	func updateSearchResults(for searchController: UISearchController) {
		guard let filter = searchController.searchBar.text,
		      !filter.isEmpty
		else {
			updateData(on: followers)
			isSearching = false
			return
		}

		isSearching = true

		filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }

		updateData(on: filteredFollowers)
	}
}

// MARK: UserInfoViewControllerDelegate

extension FollowersViewController: UserInfoViewControllerDelegate {
	func didRequestFollowers(for username: String) {
		self.username = username
		title = username
		page = 1
		followers.removeAll()
		filteredFollowers.removeAll()
		collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
		updateData(on: followers)
		getFollowers(username: username, page: page)
	}

}
