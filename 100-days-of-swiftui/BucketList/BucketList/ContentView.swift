//
//  ContentView.swift
//  BucketList
//
//  Created by Alex Scherbakov on 4/13/23.
//

import MapKit
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        if (viewModel.isUnlocked) {
            ZStack {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(
                        coordinate: location.coordinate) {
                            VStack {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundColor(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(Circle())
                                
                                Text(location.name)
                                    .fixedSize()
                            }
                            .onTapGesture {
                                viewModel.selectedPlace = location
                            }
                        }
                }
                .ignoresSafeArea()

                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.addLocation()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .font(.title)
                        .clipShape(Circle())
                        .padding([.trailing, .bottom])
                    }
                }
            }
            .sheet(item: $viewModel.selectedPlace) { place in
                EditView(location: place) { newLocation in
                    viewModel.update(location: newLocation)
                }
            }
        }
        else {
            Button("Unlock Places") {
                viewModel.authenticate()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
