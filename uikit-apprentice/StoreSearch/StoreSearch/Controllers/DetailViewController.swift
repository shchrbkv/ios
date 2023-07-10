//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/14/22.
//

import UIKit

class DetailViewController: UIViewController {
	
	@IBOutlet var popupView: UIView!
	@IBOutlet weak var artworkImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var kindLabel: UILabel!
	@IBOutlet weak var genreLabel: UILabel!
	@IBOutlet weak var priceButton: UIButton!
	
	var downloadTask: URLSessionDownloadTask?
	
	var result: SearchResult!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		transitioningDelegate = self
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
		gestureRecognizer.cancelsTouchesInView = false
		gestureRecognizer.delegate = self
		view.addGestureRecognizer(gestureRecognizer)
		
		modalPresentationStyle = .custom
		popupView.layer.cornerRadius = 10
		
		populateView()
    }
	
	
	// MARK: - Actions
	
	@IBAction func close() {
		dismiss(animated: true)
	}
	
	@IBAction func openInStore() {
		if let url = URL(string: result.storeURL) {
			UIApplication.shared.open(url)
		}
	}

    
	// MARK: - Helper Methods
	
	func populateView() {
		nameLabel.text = result.name
		artistNameLabel.text = result.artist.isEmpty ? "Unknown" : result.artist
		kindLabel.text = result.type
		genreLabel.text = result.genre
		
		artworkImageView.image = UIImage(systemName: "questionmark.square")
		if let largeURL = URL(string: result.imageLarge) {
			downloadTask = artworkImageView.loadImage(url: largeURL)
		}
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = result.currency
		
		let priceText: String
		
		if result.price == 0 { priceText = "Free" }
		else if let formatted = formatter.string(from: result.price as NSNumber) {
			priceText = formatted
		} else {
			priceText = ""
		}
		
		priceButton.setTitle(priceText, for: .normal)
	}

	deinit {
		downloadTask?.cancel()
	}

}

// MARK: - Gesture handling

extension DetailViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return touch.view == view.subviews[0]
	}
}

// MARK: - Transition Controller

extension DetailViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BounceAnimationController()
	}
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return VoidRollAnimationController()
	}
}
