//
//  GFAlertViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import UIKit

class GFAlertViewController: UIViewController {

	// MARK: Lifecycle

	init(title: String, message: String, buttonTitle: String) {
		super.init(nibName: nil, bundle: nil)
		alertTitle = title
		alertMessage = message
		self.buttonTitle = buttonTitle
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
		
		configureContainerView()
		configureTitleLabel()
		configureActionButton()
		configureMessagelabel()
	}

	// MARK: Internal

	let containerView = GFAlertContainerView()
	let titleLabel = GFTitleLabel(textAlignment: .center, fontSize: 21)
	let messageLabel = GFBodyLabel(textAlignment: .center)
	let actionButton = GFButton(backgroundColor: .systemPink, title: "Ok")

	var alertTitle: String?
	var alertMessage: String?
	var buttonTitle: String?

	let padding: CGFloat = 16

	// MARK: Private

	private func configureContainerView() {
		view.addSubview(containerView)

		NSLayoutConstraint.activate([
			containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			containerView.widthAnchor.constraint(equalToConstant: 280),
		])
	}

	private func configureTitleLabel() {
		containerView.addSubview(titleLabel)

		titleLabel.text = alertTitle ?? "Alert"

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 1.5 * padding),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
		])
	}

	private func configureActionButton() {
		containerView.addSubview(actionButton)

		actionButton.setTitle(buttonTitle ?? "Ok", for: .normal)
		actionButton.addAction(UIAction { _ in self.dismiss(animated: true) }, for: .touchUpInside)

		NSLayoutConstraint.activate([
			actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -1.5 * padding),
			actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
			actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
			actionButton.heightAnchor.constraint(equalToConstant: 48),
		])
	}

	private func configureMessagelabel() {
		containerView.addSubview(messageLabel)

		messageLabel.text = alertMessage ?? "Something went wrong"
		messageLabel.numberOfLines = 4

		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
			messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
			messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
			messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -padding),
		])
	}

}
