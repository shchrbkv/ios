//
//  HudView.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/4/22.
//

import UIKit

class HudView: UIView {
	var text = ""
	
	// Init with frame of parent view
	convenience init(inView view: UIView, animated: Bool) {
		
		self.init(frame: view.bounds)
		
		self.isOpaque = false
		
		view.addSubview(self)
		
		// Interactions disabled while on screen
		view.isUserInteractionEnabled = false
		
		self.show(animated: animated)
		
	}
	
	override func draw(_ rect: CGRect) {
		let boxWidth: CGFloat = 96
		let boxHeight: CGFloat = 96
		
		let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2),
							 y: round((bounds.size.height - boxHeight) / 2),
							 width: boxWidth,
							 height: boxHeight)
		
		let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
		
		UIColor(white: 0.3, alpha: 0.8).setFill()
		
		roundedRect.fill()
		
		let conf = UIImage.SymbolConfiguration(pointSize: 48)
		if let image = UIImage(systemName: "checkmark.circle", withConfiguration: conf) {
			
			let imagePoint = CGPoint(x: boxRect.midX - image.size.width / 2,
									 y: boxRect.midY - image.size.height / 2 - boxHeight / 8)
			
			image.withTintColor(.white).draw(at: imagePoint)
		}
		
		let attributes = [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
			NSAttributedString.Key.foregroundColor: UIColor.white,
		]
		
		let textSize = text.size(withAttributes: attributes)
		
		let textPoint = CGPoint(x: boxRect.midX - round(textSize.width / 2),
								y: boxRect.midY + boxHeight / 2 - textSize.height - 12)
		
		text.draw(at: textPoint, withAttributes: attributes)
	}
	
	func show(animated: Bool) {
		if animated {
			
			alpha = 0
			transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			
			UIView.animate(
				withDuration: 0.3,
				delay: 0,
				usingSpringWithDamping: 0.7,
				initialSpringVelocity: 0.5,
				options: [],
				animations: {
					self.alpha = 1
					self.transform = CGAffineTransform.identity
				}, completion: nil)
		}
	}
	
	func hide() {
		superview?.isUserInteractionEnabled = true
		removeFromSuperview()
	}
}
