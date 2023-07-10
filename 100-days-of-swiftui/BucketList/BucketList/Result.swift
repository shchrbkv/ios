//
//  Result.swift
//  BucketList
//
//  Created by Alex Scherbakov on 4/13/23.
//

import Foundation

// MARK: - Result

struct Result: Codable {
    let query: Query
}

// MARK: - Query

struct Query: Codable {
    let pages: [Int: Page]
}

// MARK: - Page

struct Page: Codable, Comparable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    
    var description: String {
        terms?["description"]?.first ?? "No description available"
    }
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
}
