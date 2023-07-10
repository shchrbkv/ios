//
//  ContentView.swift
//  Table
//
//  Created by Alex Scherbakov on 4/12/23.
//

import SwiftUI

// MARK: - WidthPreference

struct WidthPreference: PreferenceKey {
    static let defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: max)
    }
}

// MARK: - HeightPreference

struct HeightPreference: PreferenceKey {
    static let defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: max)
    }
}

extension View {
    func sizePreference(row: Int, column: Int) -> some View {
        background(GeometryReader { proxy in
            Color.clear
                .preference(key: WidthPreference.self, value: [column: proxy.size.width])
                .preference(key: HeightPreference.self, value: [row: proxy.size.height])
        })
    }
}

// MARK: - CellSelection

struct CellSelection: View {
    var body: some View {
        Rectangle()
            .stroke(.blue, lineWidth: 2)
    }
}

// MARK: - SelectedCell

struct SelectedCell: Hashable {
    var row: Int,
        column: Int
}

// MARK: - Table

struct Table<Cell: View>: View {
    var cells: [[Cell]]
    let padding: Double = 5
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var columnHeights: [Int: CGFloat] = [:]
    @State private var selectedCell: SelectedCell? = nil

    @Namespace private var table

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(cells.indices, id: \.self) { row in
                    HStack {
                        ForEach(cells[row].indices, id: \.self) { column in
                            cellFor(row: row, column: column)
                                .matchedGeometryEffect(id: SelectedCell(row: row, column: column), in: table, isSource: true)
                                .onTapGesture {
                                    withAnimation {
                                        selectedCell = SelectedCell(row: row, column: column)
                                    }
                                }
                        }
                    }
                    .background(!row.isMultiple(of: 2) ? Color(.secondarySystemBackground) : Color(.systemBackground))
                }
            }
            if let selectedCell {
                CellSelection()
                    .matchedGeometryEffect(id: selectedCell, in: table, isSource: false)
            }
        }
        .onPreferenceChange(WidthPreference.self) { columnWidths = $0 }
        .onPreferenceChange(HeightPreference.self) { columnHeights = $0 }
    }

    // MARK: Internal

    func cellFor(row: Int, column: Int) -> some View {
        cells[row][column]
            .sizePreference(row: row, column: column)
            .frame(width: columnWidths[column], height: columnHeights[row], alignment: .leading)
            .padding(padding)
            .background(.white.opacity(0.01))
    }
}

// MARK: - ContentView

struct ContentView: View {
    var cells = [
        [
            Text(""),
            Text("Monday").bold(),
            Text("Tuesday").bold(),
            Text("Wednesday").bold(),
        ],
        [Text("Berlin").bold(), Text("Cloudy"), Text("Mostly\nSunny"), Text("Sunny")],
        [Text("London").bold(), Text("Heavy\nRain"), Text("Cloudy"), Text("Sunny")],
    ]
    var body: some View {
        Table(cells: cells)
            .font(Font.system(.body, design: .serif))
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
