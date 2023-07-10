//
//  DataModel.swift
//  Checklists
//
//  Created by Alex Scherbakov on 7/31/22.
//

import Foundation

class DataModel {
    
    var lists: [Checklist] = []
    
    init() {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    func registerDefaults() {
        let dictionary: [String: Any] = ["ChecklistIndex": -1, "FirstTime": true]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    var indexOfSelectedChecklist: Int {
        get {
            UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            
            saveChecklists()
        }
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        return itemID
    }
    
    func sortChecklists() {
        lists.sort {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
    
    // MARK: - Data Persistence
    
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    var dataFilePath: URL {
        return documentsDirectory.appendingPathComponent("Checklists.plist")
    }

    func saveChecklists() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(lists)
            
            try data.write(to: dataFilePath, options: .atomic)
            
        } catch {
            return
        }
    }
    
    func loadChecklists() {
        let path = dataFilePath
        
        if let data = try? Data(contentsOf: path) {
            
            let decoder = PropertyListDecoder()
            
            do {
                lists = try decoder.decode([Checklist].self, from: data)
            }
            catch {
                return
            }
        }
    }
}
