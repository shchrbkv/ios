//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/14/22.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if let toViewController = transitionContext.viewController(forKey: .to),
		   let toView = transitionContext.view(forKey: .to) {
			
			let containerView = transitionContext.containerView
			toView.frame = transitionContext.finalFrame(for: toViewController)
			containerView.addSubview(toView)
			
			let popupView = toView.subviews[0]
			popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			
			toView.backgroundColor = .clear
			let dimmingView = GradientView(frame: toView.bounds)
			dimmingView.alpha = 0

			toView.insertSubview(dimmingView, at: 0)
			
			UIView.animateKeyframes(
				withDuration: transitionDuration(using: transitionContext),
				delay: 0,
				options: .calculationModeCubic,
				animations: {
					UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
						popupView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
						dimmingView.alpha = 1
					})
					
					UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3, animations: {
						popupView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
					})
					
					UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
						popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
					})
				},
				completion: { finished in
					transitionContext.completeTransition(finished)
				})
		}
	}

}
