//
//  ContentView.swift
//  Layout
//
//  Created by Alex Scherbakov on 4/11/23.
//

import SwiftUI

// MARK: - Collapsible

struct Collapsible<Content: View>: View {
    var expanded = false
    var spacing: CGFloat? = 8
    var items: [Content]

    var collapsedWidth: Double = 10

    var body: some View {
        HStack(alignment: .center, spacing: expanded ? spacing : nil) {
            ForEach(items.indices, id: \.self) { index in
                let showExpanded = expanded || index == items.endIndex - 1
                items[index]
                    .frame(width: showExpanded ? nil : collapsedWidth, alignment: .leading)
            }
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    let colors: [(Color, CGFloat)] = [(.init(white: 0.3), 50), (.init(white: 0.8), 30), (.init(white: 0.5), 75)]
    @State var expanded = true
    var body: some View {
        VStack(spacing: 20) {
            Collapsible(expanded: expanded, items: colors.map { item in
                Rectangle()
                    .fill(item.0)
                    .frame(width: item.1, height: item.1)
            })

            Button("Expanded") {
                withAnimation {
                    expanded.toggle()
                }
            }
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
