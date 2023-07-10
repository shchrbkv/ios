//
//  ContentView.swift
//  Badge
//
//  Created by Alex Scherbakov on 4/11/23.
//

import SwiftUI

// MARK: - BadgeModifier

struct BadgeModifier: ViewModifier {
    var count: Int

    func body(content: Content) -> some View {
        if (count != 0) {
            content
                .overlay(alignment: .topTrailing) {
                    Text(String(count))
                        .font(.callout)
                        .padding(5)
                        .frame(minWidth: 30, minHeight: 30)
                        .foregroundColor(.white)
                        .background(.red)
                        .clipShape(Capsule(style: .continuous))
                        .offset(CGSize(width: 10, height: -10))
                }
        } else {
            content
        }
    }
}

extension View {
    func badge(count: Int) -> some View {
        modifier(BadgeModifier(count: count))
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State var count: Int = -2
    
    var body: some View {
        HStack {
            Button {
                count += 1
            } label: {
                Text("This is a button")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .badge(count: count)
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
