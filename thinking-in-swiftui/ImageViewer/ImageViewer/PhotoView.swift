//
//  PhotoView.swift
//  ImageViewer
//
//  Created by Alex Scherbakov on 4/10/23.
//

import SwiftUI

// MARK: - PhotoView

struct PhotoView: View {
    var photo: Photo

    var body: some View {
        VStack {
            AsyncImage(url: photo.downloadURL) { image in
                image
                    .resizable()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(Double(photo.width) / Double(photo.height), contentMode: .fit)
            Spacer()
        }
        .navigationTitle("#\(photo.id)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - PhotoView_Previews

struct PhotoView_Previews: PreviewProvider {
    static let result = """
        {"id":"0","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/yC-Yzbqy7PY","download_url":"https://picsum.photos/id/0/5000/3333"}
        """
    static let jsonData = result.data(using: .utf8)!
    static let photo = try? JSONDecoder().decode(Photo.self, from: jsonData)

    static var previews: some View {
        NavigationView {
            PhotoView(photo: photo!)
        }
    }
}
