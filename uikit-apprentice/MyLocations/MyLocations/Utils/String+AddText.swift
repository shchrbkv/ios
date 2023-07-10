//
//  String+AddText.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/9/22.
//

extension String {
	mutating func add(text: String?, separatedBy separator: String = "") {
		if let text = text {
			if !isEmpty {
				self += separator
			}
			self += text
		}
	}
}
