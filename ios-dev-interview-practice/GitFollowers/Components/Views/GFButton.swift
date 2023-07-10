//
//  GFButton.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import UIKit

class GFButton: UIButton {

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	convenience init(backgroundColor: UIColor, title: String) {
		self.init(frame: .zero)
		set(backgroundColor: backgroundColor, title: title)
	}

	// MARK: Private

	private func configure() {
		layer.cornerRadius = 10
		setTitleColor(.white, for: .normal)
		titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	func set(backgroundColor: UIColor, title: String) {
		self.backgroundColor = backgroundColor
		self.setTitle(title, for: .normal)
	}

}
