//
//  GFDataLoadingViewController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/8/22.
//

import UIKit

class GFDataLoadingViewController: UIViewController {

	var containerView: UIView!

	// MARK: Public

	public func showLoadingView() {
		containerView = UIView(frame: view.bounds)
		view.addSubview(containerView)

		containerView.backgroundColor = .systemBackground
		containerView.alpha = 0

		UIView.animate(withDuration: 0.25, delay: 0) { self.containerView.alpha = 0.8 }

		let activityIndicator = UIActivityIndicatorView(style: .large)
		containerView.addSubview(activityIndicator)

		activityIndicator.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
		])

		activityIndicator.startAnimating()
	}

	public func dismissLoadingView() {
		containerView.removeFromSuperview()
		containerView = nil
	}

	public func showEmptyStateView(with message: String, in view: UIView) {
		let emptyStateView = GFEmptyStateView(message: message)
		view.addSubview(emptyStateView)
		emptyStateView.pinToEdges(of: view)
	}

}
