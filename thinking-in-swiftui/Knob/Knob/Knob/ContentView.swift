//
//  ContentView.swift
//  Knob
//
//  Created by Chris Eidhof on 05.11.19.
//  Copyright © 2019 Chris Eidhof. All rights reserved.
//

import SwiftUI

// MARK: - KnobShape

struct KnobShape: Shape {
    var pointerSize: CGFloat = 0.1 // these are relative values
    var pointerWidth: CGFloat = 0.1
    func path(in rect: CGRect) -> Path {
        let pointerHeight = rect.height * pointerSize
        let pointerWidth = rect.width * pointerWidth
        let circleRect = rect.insetBy(dx: pointerHeight, dy: pointerHeight)
        return Path { p in
            p.addEllipse(in: circleRect)
            p.addRect(CGRect(x: rect.midX - pointerWidth / 2, y: 0, width: pointerWidth, height: pointerHeight + 2))
        }
    }
}

// MARK: - PointerSizeKey

private struct PointerSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0.1
}

// MARK: - PointerColorKey

struct PointerColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

extension EnvironmentValues {
    var knobPointerSize: CGFloat {
        get { self[PointerSizeKey.self] }
        set { self[PointerSizeKey.self] = newValue }
    }

    var knobColor: Color? {
        get { self[PointerColorKey.self] }
        set { self[PointerColorKey.self] = newValue }
    }
}

extension View {
    func knobPointerSize(_ size: CGFloat) -> some View {
        environment(\.knobPointerSize, size)
    }

    func knobPointerColor(_ color: Color?) -> some View {
        environment(\.knobColor, color)
    }
}

// MARK: - Knob

struct Knob: View {
    @Binding var value: Double // should be between 0 and 1
    var pointerSize: CGFloat? = nil
    @Environment(\.knobPointerSize) var envPointerSize
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.knobColor) var envColor

    var body: some View {
        KnobShape(pointerSize: pointerSize ?? envPointerSize)
            .fill(envColor ?? (colorScheme == .light ? .black : .white))
            .rotationEffect(Angle(degrees: value * 350))
            .onTapGesture {
                withAnimation(.default) {
                    value = value < 0.5 ? 1 : 0
                }
            }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State var value = 0.5
    @State var knobSize: CGFloat = 0.1
    @State var knobHue: Double = 0.0
    @State var customColor: Bool = true

    var body: some View {
        VStack {
            Knob(value: $value)
                .frame(width: 100, height: 100)
                .knobPointerSize(knobSize)
                .knobPointerColor(customColor ? Color(hue: knobHue, saturation: 0.95, brightness: 0.95) : nil)
            HStack {
                Text("Value")
                Slider(value: $value, in: 0 ... 1)
            }
            HStack {
                Text("Knob Size")
                Slider(value: $knobSize, in: 0 ... 0.4)
            }
            HStack {
                Text("Knob Hue")
                Slider(value: $knobHue, in: 0 ... 1)
            }
            Button("Toggle", action: {
                withAnimation(.default) {
                    customColor.toggle()
                }
            })
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
