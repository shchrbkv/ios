//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/14/22.
//

import UIKit

class VoidRollAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		if let fromView = transitionContext.view(forKey: .from) {
			
			let popupView = fromView.subviews[1]
			let time = transitionDuration(using: transitionContext)
			
			UIView.animate(
				withDuration: time,
				animations: {
					popupView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
					fromView.alpha = 0
				},
				completion: { finished in
					transitionContext.completeTransition(finished)
				})
		}
	}

}
