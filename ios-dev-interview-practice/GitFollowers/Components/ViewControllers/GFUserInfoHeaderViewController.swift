//
//  GFUserInfoHeaderViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/1/22.
//

import UIKit

class GFUserInfoHeaderViewController: UIViewController {

	let avatarImageView = GFAvatarImageView(frame: .zero)
	let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 34)
	let nameLabel = GFSubtitleLabel(fontSize: 18)
	var locationImageView = {
		let view = UIImageView()
		view.tintColor = .secondaryLabel
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let locationLabel = GFSubtitleLabel(fontSize: 18)
	let bioLabel = {
		let label = GFBodyLabel(textAlignment: .left)
		label.numberOfLines = 0
		label.adjustsFontSizeToFitWidth = false
		label.lineBreakMode = .byTruncatingTail
		return label
	}()

	let user: User!

	// MARK: Lifecycle

	public init(user: User) {
		self.user = user
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		view.addSubviews(avatarImageView,
		                 usernameLabel,
		                 nameLabel,
		                 locationImageView,
		                 locationLabel,
		                 bioLabel)
		layoutUI()
		configureUIElements(for: user)
	}

	// MARK: Public

	public func configureUIElements(for user: User) {
		avatarImageView.downloadImage(fromURL: user.avatarUrl)
		usernameLabel.text = user.login
		nameLabel.text = user.name ?? ""

		locationImageView.image = SFSymbols.location
		if user.location == nil {
			locationLabel.text = ""
			locationImageView.isHidden = true
		} else {
			locationLabel.text = user.location
		}

		bioLabel.text = user.bio ?? "User preferred to not specify bio."
	}

	// MARK: Private

	private func layoutUI() {
		let textImagePadding: CGFloat = 12

		NSLayoutConstraint.activate([
			avatarImageView.topAnchor.constraint(equalTo: view.topAnchor),
			avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			avatarImageView.widthAnchor.constraint(equalToConstant: 90),
			avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

			usernameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
			usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: textImagePadding),
			usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			usernameLabel.heightAnchor.constraint(equalToConstant: 38),

			nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 4),
			nameLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
			nameLabel.heightAnchor.constraint(equalToConstant: 20),

			locationImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
			locationImageView.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
			locationImageView.widthAnchor.constraint(equalToConstant: 20),
			locationImageView.heightAnchor.constraint(equalTo: locationImageView.widthAnchor),

			locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
			locationLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 5),
			locationLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
			locationLabel.heightAnchor.constraint(equalToConstant: 20),

			bioLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: textImagePadding),
			bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bioLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
		])
	}
}
