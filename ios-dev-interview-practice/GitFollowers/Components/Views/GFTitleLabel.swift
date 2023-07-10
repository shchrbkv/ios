//
//  GFTitleLabel.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import UIKit

class GFTitleLabel: UILabel {

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat) {
		self.init(frame: .zero)
		self.textAlignment = textAlignment
		font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private

	private func configure() {
		textColor = .label
		adjustsFontSizeToFitWidth = false
		minimumScaleFactor = 0.9
		lineBreakMode = .byTruncatingTail
		translatesAutoresizingMaskIntoConstraints = false
	}

}
