//
//  JokeManagedObject+.swift
//  ChuckNorrisJokes
//
//  Created by Alex Scherbakov on 4/29/23.
//  Copyright © 2023 Scott Gardner. All rights reserved.
//

import ChuckNorrisJokesModel
import CoreData
import SwiftUI

extension JokeManagedObject {
    static func save(joke: Joke, inViewContext viewContext: NSManagedObjectContext) {
        guard joke.id != "error" else { return }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: JokeManagedObject.self))

        fetchRequest.predicate = NSPredicate(format: "id = %@", joke.id)

        if let results = try? viewContext.fetch(fetchRequest),
           let existing = results.first as? JokeManagedObject {
            existing.value = joke.value
            existing.categories = joke.categories as NSArray
        } else {
            let newJoke = self.init(context: viewContext)
            newJoke.id = joke.id
            newJoke.value = joke.value
            newJoke.categories = joke.categories as NSArray
        }

        do {
            try viewContext.save()
        }
        catch {
            fatalError("\(#file), \(#function), \(error.localizedDescription)")
        }
    }
}

extension Collection<JokeManagedObject> where Index == Int {
    func delete(at indices: IndexSet, inViewContext viewContext: NSManagedObjectContext) {
        indices.forEach { index in
            viewContext.delete(self[index])
        }

        do {
            try viewContext.save()
        }
        catch {
            fatalError("\(#file), \(#function), \(error.localizedDescription)")
        }
    }
}
