//
//  FavoriteCell.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/7/22.
//

import UIKit

class FavoriteCell: UITableViewCell {

	static let reuseID = "FavoriteCell"

	let avatarImageView = GFAvatarImageView(frame: .zero)
	let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 21)

	// MARK: Lifecycle

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configure()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Public

	public func set(favorite: Follower) {
		avatarImageView.downloadImage(fromURL: favorite.avatarUrl)
		usernameLabel.text = favorite.login
	}

	// MARK: Private

	private func configure() {
		addSubviews(avatarImageView, usernameLabel)
		
		accessoryType = .disclosureIndicator
		let padding: CGFloat = 12

		NSLayoutConstraint.activate([
			avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			avatarImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: padding),
			avatarImageView.widthAnchor.constraint(equalToConstant: 60),
			avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

			usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
			usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
			usernameLabel.heightAnchor.constraint(equalToConstant: 36),
		])
	}
}
