//
//  UserInfoViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/1/22.
//

import SafariServices
import UIKit

// MARK: - UserInfoViewControllerDelegate

protocol UserInfoViewControllerDelegate: AnyObject {
	func didRequestFollowers(for username: String)
}

// MARK: - UserInfoViewController

class UserInfoViewController: UIViewController {

	let scrollView = UIScrollView()
	let contentView = UIView()

	let headerView = UIView()
	let repoView = UIView()
	let followersView = UIView()
	let dateLabel = GFBodyLabel(textAlignment: .center)

	public var username: String!
	weak var delegate: UserInfoViewControllerDelegate!

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		configureViewController()
		configureScrollView()
		layoutUI()
		getUserInfo()
	}

	// MARK: Private

	private func configureViewController() {
		view.backgroundColor = .systemBackground
		let doneAction = UIAction { _ in self.dismiss(animated: true) }
		let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
		navigationItem.rightBarButtonItem = doneButton
	}

	private func configureScrollView() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)

		scrollView.pinToEdges(of: view)
		contentView.pinToEdges(of: scrollView)

		NSLayoutConstraint.activate([
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			contentView.heightAnchor.constraint(equalToConstant: 600),
		])
	}

	private func layoutUI() {
		let padding: CGFloat = 20

		[headerView, repoView, followersView, dateLabel].forEach { itemView in
			contentView.addSubview(itemView)
			itemView.translatesAutoresizingMaskIntoConstraints = false

			NSLayoutConstraint.activate([
				itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
				itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			])
		}

		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
			headerView.heightAnchor.constraint(equalToConstant: 170),

			repoView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
			repoView.heightAnchor.constraint(equalToConstant: 120),

			followersView.topAnchor.constraint(equalTo: repoView.bottomAnchor, constant: padding),
			followersView.heightAnchor.constraint(equalToConstant: 120),

			dateLabel.topAnchor.constraint(equalTo: followersView.bottomAnchor, constant: padding),
			dateLabel.heightAnchor.constraint(equalToConstant: 40),
		])
	}

	private func add(childVC: UIViewController, to containerView: UIView) {
		addChild(childVC)
		containerView.addSubview(childVC.view)
		childVC.view.frame = containerView.bounds
		childVC.didMove(toParent: self)
	}

	private func configureUIElements(with user: User) {
		let repoItemViewController = GFRepoItemViewController(user: user)
		repoItemViewController.delegate = self

		let followersItemViewController = GFFollowersItemViewController(user: user)
		followersItemViewController.delegate = self

		let headerViewController = GFUserInfoHeaderViewController(user: user)

		add(childVC: repoItemViewController, to: repoView)
		add(childVC: headerViewController, to: headerView)
		add(childVC: followersItemViewController, to: followersView)
		dateLabel.text = "Joined \(user.createdAt.convertToMonthYearFormat())"
	}

	private func getUserInfo() {
		Task {
			do {
				let user = try await NetworkManager.shared.getUserInfo(for: username)
				configureUIElements(with: user)
			} catch {
				if let error = error as? GFError {
					presentGFAlert(title: "Error",
					               message: error.rawValue,
					               buttonTitle: "Ok")
				} else {
					presentDefaultErrorGFAlert()
				}
			}
		}
//		NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
//
//			guard let self else { return }
//
//			switch result {
//			case .success(let user):
//				DispatchQueue.main.async { self.configureUIElements(with: user) }
//
//			case .failure(let error):
//				self.presentGFAlertOnMainThread(title: "Something went wrong",
//				                                message: error.rawValue,
//				                                buttonTitle: "Ok")
//			}
//		}
	}
}

// MARK: FollowersItemViewControllerDelegate

extension UserInfoViewController: FollowersItemViewControllerDelegate {

	func didTapGetFollowers(for user: User) {
		guard user.followers > 0 else {
			presentGFAlertOnMainThread(title: "No followers", message: "This user has no followers",
			                           buttonTitle: "That's just sad")
			return
		}
		delegate.didRequestFollowers(for: user.login)
		dismiss(animated: true)
	}
}

// MARK: RepoItemViewControllerDelegate

extension UserInfoViewController: RepoItemViewControllerDelegate {
	func didTapGitHubProfile(for user: User) {
		guard let url = URL(string: user.htmlUrl) else {
			presentGFAlertOnMainThread(title: "Invalid URL",
			                           message: "Url attached to this user is invalid.",
			                           buttonTitle: "Sadge")
			return
		}

		presentSafariViewController(with: url)
	}
}
