//
//  Remote.swift
//  ImageViewer
//
//  Created by Alex Scherbakov on 4/10/23.
//

import Combine
import Foundation

class Remote<ItemType>: ObservableObject where ItemType: Codable & Identifiable {
    @Published public var items: [ItemType]?

    let endpoint = URL(string: "https://picsum.photos/v2/list")!

    // MARK: Internal

    func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: endpoint)

            let items = try JSONDecoder().decode([ItemType].self, from: data)

            await MainActor.run {
                self.items = items
            }
        }
        catch {
            print(error)
            return
        }
    }
}
