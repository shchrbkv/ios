//
//  ContentView.swift
//  ImageViewer
//
//  Created by Alex Scherbakov on 4/10/23.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var remote = Remote<Photo>()

    var body: some View {
        NavigationView {
            Group {
                if remote.items == nil {
                    VStack {
                        ProgressView()
                        Spacer()
                    }
                }
                else {
                    List {
                        ForEach(remote.items ?? [], id: \.id) { photo in
                            NavigationLink {
                                PhotoView(photo: photo)
                            } label: {
                                HStack {
                                    Text(photo.author)
                                    Spacer()
                                    AsyncImage(url: photo.downloadURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ZStack{
                                            Rectangle()
                                                .fill(.yellow)
                                            ProgressView()
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                }
                            }
                        }
                    }
                }
            }
            .task {
                await remote.load()
            }
            .navigationTitle("ImageViewer")
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
