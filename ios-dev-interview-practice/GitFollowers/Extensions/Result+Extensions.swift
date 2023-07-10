//
//  Result+Extensions.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/3/22.
//

import Foundation

extension Result where Success == Void {
	public static var success: Self { .success(()) }
}
