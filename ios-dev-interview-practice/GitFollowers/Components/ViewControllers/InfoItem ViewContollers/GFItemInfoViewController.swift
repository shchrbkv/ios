//
//  GFItemInfoViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/2/22.
//

import UIKit

// MARK: - GFItemInfoViewController

class GFItemInfoViewController: UIViewController {

	let stackView = UIStackView()
	let itemInfoViewOne = GFItemInfoView()
	let itemInfoViewTwo = GFItemInfoView()
	let actionButton = GFButton()

	var user: User!

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		configureBackgroundView()
		layoutUI()
		configureStackView()
		configureActionButton()
	}

	public init(user: User) {
		self.user = user
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Internal

	func configureBackgroundView() {
		view.layer.cornerRadius = 16
		view.backgroundColor = .secondarySystemBackground
	}

	func actionButtonTapped(_ action: UIAction) { }

	// MARK: Private

	private func layoutUI() {
		view.addSubviews(stackView, actionButton)

		stackView.translatesAutoresizingMaskIntoConstraints = false

		let padding: CGFloat = 20
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
			stackView.heightAnchor.constraint(equalToConstant: 50),

			actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
			actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
			actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
			actionButton.heightAnchor.constraint(equalToConstant: 48),
		])
	}

	private func configureStackView() {
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.spacing = 16

		stackView.addArrangedSubview(itemInfoViewOne)
		stackView.addArrangedSubview(itemInfoViewTwo)
	}

	private func configureActionButton() {
		let action = UIAction(handler: actionButtonTapped(_:))
		actionButton.addAction(action, for: .touchUpInside)
	}
}
