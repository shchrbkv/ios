//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/9/22.
//

import UIKit

extension UIImage {
	
	func resized(withBounds bounds: CGSize) -> UIImage {
		
		let horizontalRatio = bounds.width / size.width
		let verticalRatio = bounds.height / size.height
		let ratio = max(horizontalRatio, verticalRatio)
		
		let newSize = CGSize(width: size.width * ratio,
							 height: size.height * ratio)
		
		UIGraphicsBeginImageContextWithOptions(bounds, true, 0)
		
		let origin = CGPoint(x: (bounds.width - newSize.width) / 2,
							 y: (bounds.height - newSize.height) / 2)
		
		draw(in: CGRect(origin: origin, size: newSize))
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
	
}
