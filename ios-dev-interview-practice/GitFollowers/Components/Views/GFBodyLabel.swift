//
//  GFBodyLabel.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import UIKit

class GFBodyLabel: UILabel {

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	convenience init(textAlignment: NSTextAlignment) {
		self.init(frame: .zero)
		self.textAlignment = textAlignment
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private

	private func configure() {
		textColor = .secondaryLabel
		font = UIFont.preferredFont(forTextStyle: .body)
		adjustsFontSizeToFitWidth = true
		adjustsFontForContentSizeCategory = true
		minimumScaleFactor = 0.75
		lineBreakMode = .byWordWrapping
		translatesAutoresizingMaskIntoConstraints = false
	}

}
