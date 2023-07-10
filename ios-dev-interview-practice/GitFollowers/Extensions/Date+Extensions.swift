//
//  Date+Extensions.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/2/22.
//

import Foundation

extension Date {
	
	func convertToMonthYearFormat() -> String {
		return formatted(.dateTime.locale(Locale(identifier: "en_US_POSIX")).month().year())
	}
	
//	func convertToMonthYearFormat() -> String {
//		let dateFormatter = DateFormatter()
//
//		dateFormatter.dateFormat = "MMMM yyyy"
//		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//		dateFormatter.timeZone = .current
//
//		return dateFormatter.string(from: self)
//	}
	
}
