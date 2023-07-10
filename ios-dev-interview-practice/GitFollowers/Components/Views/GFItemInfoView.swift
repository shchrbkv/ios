//
//  GFItemInfoView.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/2/22.
//

import UIKit

enum ItemInfoType {
	case repos, gists, followers, following
}

class GFItemInfoView: UIView {

	let symbolImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFill
		view.tintColor = .label
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let dataLabel = GFTitleLabel(textAlignment: .left, fontSize: 16)

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private

	private func configure() {
		addSubviews(symbolImageView, dataLabel)

		NSLayoutConstraint.activate([
			symbolImageView.topAnchor.constraint(equalTo: topAnchor),
			symbolImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			symbolImageView.widthAnchor.constraint(equalToConstant: 20),
			symbolImageView.heightAnchor.constraint(equalTo: symbolImageView.widthAnchor),

			dataLabel.centerYAnchor.constraint(equalTo: symbolImageView.centerYAnchor),
			dataLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 8),
			dataLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			dataLabel.heightAnchor.constraint(equalTo: symbolImageView.heightAnchor),
		])
	}
	
	func set(itemInfoType: ItemInfoType, with count: Int) {
		switch itemInfoType {
		case .repos:
			symbolImageView.image = SFSymbols.repos
			dataLabel.text = "\(count) repos"
		case .gists:
			symbolImageView.image = SFSymbols.gists
			dataLabel.text = "\(count) gists"
		case .followers:
			symbolImageView.image = SFSymbols.followers
			dataLabel.text = "\(count) followers"
		case .following:
			symbolImageView.image = SFSymbols.following
			dataLabel.text = "\(count) following"
		}
	}
}
