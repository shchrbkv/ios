//
//  FollowerCell.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/30/22.
//

import UIKit

class FollowerCell: UICollectionViewCell {

	static let reuseId = "FollowerCell"

	let avatarImageView = GFAvatarImageView(frame: .zero)
	let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Public

	public func set(follower: Follower) {
		avatarImageView.downloadImage(fromURL: follower.avatarUrl)
		usernameLabel.text = follower.login
	}

	// MARK: Private

	private func configure() {
		contentView.addSubviews(avatarImageView, usernameLabel)

		let padding: CGFloat = 8

		NSLayoutConstraint.activate([
			avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
			avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

			usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
			usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
			usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			usernameLabel.heightAnchor.constraint(equalToConstant: 20),
		])
	}

}
