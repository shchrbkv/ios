//
//  GFEmptyStateView.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/30/22.
//

import UIKit

class GFEmptyStateView: UIView {

	let messageLabel = GFTitleLabel(textAlignment: .center, fontSize: 28)
	let logoImageView = UIImageView()

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	convenience init(message: String) {
		self.init(frame: .zero)
		messageLabel.text = message
	}

	// MARK: Private

	private func configure() {
		addSubviews(messageLabel, logoImageView)

		messageLabel.numberOfLines = 2
		messageLabel.textColor = .secondaryLabel
		messageLabel.translatesAutoresizingMaskIntoConstraints = false

		logoImageView.image = Images.emptyStateLogo
		logoImageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -150),
			messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
			messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
			messageLabel.heightAnchor.constraint(equalToConstant: 100),

			logoImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.3),
			logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
			logoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 170),
			logoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 30),
		])
	}

}
