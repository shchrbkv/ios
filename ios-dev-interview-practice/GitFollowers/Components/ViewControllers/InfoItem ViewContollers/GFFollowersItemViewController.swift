//
//  GFFollowersItemViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/2/22.
//

import UIKit

// MARK: - FollowersItemViewControllerDelegate

protocol FollowersItemViewControllerDelegate: AnyObject {
	func didTapGetFollowers(for user: User)
}

// MARK: - GFFollowersItemViewController

class GFFollowersItemViewController: GFItemInfoViewController {

	weak var delegate: FollowersItemViewControllerDelegate!

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		configureItems()
	}

	// MARK: Internal

	override func actionButtonTapped(_ action: UIAction) {
		delegate.didTapGetFollowers(for: user)
	}

	// MARK: Private

	private func configureItems() {
		itemInfoViewOne.set(itemInfoType: .followers, with: user.followers)
		itemInfoViewTwo.set(itemInfoType: .following, with: user.following)
		actionButton.set(backgroundColor: .systemGreen, title: "All Followers")
	}
}
