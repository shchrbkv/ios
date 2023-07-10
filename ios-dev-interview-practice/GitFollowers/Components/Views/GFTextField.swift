//
//  GFTextField.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import UIKit

class GFTextField: UITextField {

	// MARK: Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Private

	private func configure() {
		translatesAutoresizingMaskIntoConstraints = false

		layer.cornerRadius = 10
		layer.borderWidth = 2
		layer.borderColor = UIColor.systemGray4.cgColor

		textColor = .label
		tintColor = .label
		textAlignment = .center
		font = UIFont.preferredFont(forTextStyle: .body)
		adjustsFontSizeToFitWidth = false
		minimumFontSize = 12

		backgroundColor = .tertiarySystemBackground
		autocorrectionType = .no
		autocapitalizationType = .none
		returnKeyType = .search
		clearButtonMode = .whileEditing

		placeholder = "Enter a username"
	}

}
