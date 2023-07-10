//
//  Expenses.swift
//  iExpense
//
//  Created by Alex Scherbakov on 4/6/23.
//

import Foundation

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "expenses")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "expenses") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
    }
}
