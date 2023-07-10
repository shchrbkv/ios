//
//  GFAlertContainerView.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/8/22.
//

import UIKit

class GFAlertContainerView: UIView {

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
		layer.cornerRadius = 16
		layer.borderWidth = 2
		layer.borderColor = UIColor.white.cgColor

		backgroundColor = .systemBackground
		translatesAutoresizingMaskIntoConstraints = false
	}

}
