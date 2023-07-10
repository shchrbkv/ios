//
//  Prospect.swift
//  HotProspects
//
//  Created by Alex Scherbakov on 4/13/23.
//

import SwiftUI

// MARK: - Prospect

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

// MARK: - Prospects

@MainActor
class Prospects: ObservableObject {
    @Published var people: [Prospect]
    let saveKey = "SavedData"

    // MARK: Lifecycle

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }

        people = []
    }

    // MARK: Internal

    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }

    func toggle(_ prospect: Prospect) {
        objectWillChange.send() // Always before, as object WILL change
        prospect.isContacted.toggle()
        save()
    }

    // MARK: Private

    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
