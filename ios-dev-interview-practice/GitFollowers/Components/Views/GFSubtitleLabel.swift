//
//  GFSubtitleLabel.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/1/22.
//

import UIKit

class GFSubtitleLabel: UILabel {

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	convenience init(fontSize: CGFloat) {
		self.init(frame: .zero)
		font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private

	private func configure() {
		textColor = .secondaryLabel
		adjustsFontSizeToFitWidth = false
		minimumScaleFactor = 0.9
		lineBreakMode = .byTruncatingTail
		translatesAutoresizingMaskIntoConstraints = false
	}
}
