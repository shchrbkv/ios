//
//  SearchViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/28/22.
//

import UIKit

class SearchViewController: UIViewController {
	
	let logoImageView = UIImageView()
	let usernameTextField = GFTextField()
	let callToActionButton = GFButton(backgroundColor: .systemGreen, title: "Get Followers")
	
	var isUsernameEntered: Bool {
		return !usernameTextField.text!.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		configureLogoImageView()
		configureTextField()
//		configureCallToActionButton()
		createDismissKeyboardTapGesture()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	func configureLogoImageView() {
		view.addSubview(logoImageView)
		logoImageView.translatesAutoresizingMaskIntoConstraints = false
		logoImageView.image = Images.ghLogo
		
		NSLayoutConstraint.activate([
			logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
			logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logoImageView.heightAnchor.constraint(equalToConstant: 196),
			logoImageView.widthAnchor.constraint(equalToConstant: 196)
		])
	}
	
	
	private func configureTextField() {
		view.addSubview(usernameTextField)
		usernameTextField.delegate = self
		
		NSLayoutConstraint.activate([
			usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
			usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
			usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
			usernameTextField.heightAnchor.constraint(equalToConstant: 48)
		])
	}
	
//	private func configureCallToActionButton() {
//		view.addSubview(callToActionButton)
//
//		let action = UIAction(handler: pushFollowersViewController)
//		callToActionButton.addAction(action, for: .touchUpInside)
//
//		NSLayoutConstraint.activate([
//			callToActionButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
//			callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
//			callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
//			callToActionButton.heightAnchor.constraint(equalToConstant: 48)
//		])
//	}
	
	private func createDismissKeyboardTapGesture() {
		let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
		view.addGestureRecognizer(tap)
	}
	
	private func pushFollowersViewController() {
		
		guard isUsernameEntered else {
			presentGFAlertOnMainThread(title: "Empty Username", message: "Please enter the GitHub username", buttonTitle: "Got it")
			return
		}
		
		let followersViewController = FollowersViewController(username: usernameTextField.text!)
		navigationController?.pushViewController(followersViewController, animated: true)
	}
}


extension SearchViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		pushFollowersViewController()
		return true
	}
	
}
