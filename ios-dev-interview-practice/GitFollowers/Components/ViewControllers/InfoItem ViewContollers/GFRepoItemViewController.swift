//
//  GFRepoItemViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/2/22.
//

import UIKit

// MARK: - RepoItemViewControllerDelegate

protocol RepoItemViewControllerDelegate: AnyObject {
	func didTapGitHubProfile(for user: User)
}

// MARK: - GFRepoItemViewController

class GFRepoItemViewController: GFItemInfoViewController {

	weak var delegate: RepoItemViewControllerDelegate!

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		configureItems()
	}

	// MARK: Internal

	override func actionButtonTapped(_ action: UIAction) {
		delegate.didTapGitHubProfile(for: user)
	}

	// MARK: Private

	private func configureItems() {
		itemInfoViewOne.set(itemInfoType: .repos, with: user.publicRepos)
		itemInfoViewTwo.set(itemInfoType: .gists, with: user.publicGists)
		actionButton.set(backgroundColor: .systemPurple, title: "GitHub Profile")
	}
}
