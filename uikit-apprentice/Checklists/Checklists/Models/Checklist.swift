//
//  Checklist.swift
//  Checklists
//
//  Created by Alex Scherbakov on 7/31/22.
//

import Foundation

class Checklist: NSObject, Codable {
    var name = ""
    var items: [ChecklistItem] = []
    var iconName: String
    
    init(name: String, iconName: String = "No Icon") {
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    var uncheckedItemsCount: Int {
        items.filter{!$0.checked}.count
    }
    
    func sortItems() {
        items.sort {
            $0.dueDate.compare($1.dueDate) == .orderedAscending
        }
    }
}
