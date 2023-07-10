//
//  UIView+Extensions.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 9/29/22.
//

import SafariServices
import UIKit

extension UIViewController {

	public func presentGFAlertOnMainThread(title: String, message: String, buttonTitle: String) {
		DispatchQueue.main.async {
			let alertViewController = GFAlertViewController(title: title, message: message, buttonTitle: buttonTitle)
			alertViewController.modalPresentationStyle = .overFullScreen
			alertViewController.modalTransitionStyle = .crossDissolve
			self.present(alertViewController, animated: true)
		}
	}

	public func presentGFAlert(title: String, message: String, buttonTitle: String) {
		let alertViewController = GFAlertViewController(title: title, message: message, buttonTitle: buttonTitle)
		alertViewController.modalPresentationStyle = .overFullScreen
		alertViewController.modalTransitionStyle = .crossDissolve
		present(alertViewController, animated: true)
	}
	
	public func presentDefaultErrorGFAlert() {
		presentGFAlert(title: "Everything broke",
					   message: "Couldn't complete the task. Try again later.",
					   buttonTitle: "Sad, but ok")
	}

	public func presentSafariViewController(with url: URL) {
		let safariViewController = SFSafariViewController(url: url)
		safariViewController.preferredControlTintColor = .systemGreen
		present(safariViewController, animated: true)
	}
}
