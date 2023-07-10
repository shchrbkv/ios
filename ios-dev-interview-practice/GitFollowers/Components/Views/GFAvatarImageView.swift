//
//  GFAvatarImageView.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/30/22.
//

import UIKit

class GFAvatarImageView: UIImageView {

	let placeholderImage = Images.avatarPlaceholder

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Internal

	func downloadImage(fromURL url: String) {
		Task { image = await NetworkManager.shared.downloadImage(from: url) ?? placeholderImage }
	}

	// MARK: Private

	private func configure() {
		layer.cornerRadius = 10
		clipsToBounds = true
		image = placeholderImage
		translatesAutoresizingMaskIntoConstraints = false
	}
}
