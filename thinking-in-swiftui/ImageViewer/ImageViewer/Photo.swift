//
//  Photo.swift
//  ImageViewer
//
//  Created by Alex Scherbakov on 4/10/23.
//

import SwiftUI

struct Photo: Identifiable, Codable, Hashable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    var url: URL
    var downloadURL: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.author = try container.decode(String.self, forKey: .author)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.url = try container.decode(URL.self, forKey: .url)
        self.downloadURL = try container.decode(URL.self, forKey: .downloadURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case downloadURL = "download_url"
    }
}
