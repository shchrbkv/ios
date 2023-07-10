//
//  UILabel+Extensions.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/8/22.
//

import UIKit

extension UILabel {
	var maximumHeight: CGFloat {
		let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
		let text = (text ?? "") as NSString
		let textRect = text.boundingRect(with: maxSize,
		                                 options: .usesLineFragmentOrigin,
		                                 attributes: [.font: font!],
		                                 context: nil)
		return textRect.height
	}
}
