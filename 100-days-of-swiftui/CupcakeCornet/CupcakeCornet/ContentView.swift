//
//  ContentView.swift
//  CupcakeCornet
//
//  Created by Alex Scherbakov on 4/7/23.
//

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @StateObject var order = Order()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Select your cake type", selection: $order.type) {
                        ForEach(Order.types.indices, id: \.self) {
                            Text(Order.types[$0])
                        }
                    }

                    Stepper("Number of cakes: \(order.quantity)", value: $order.quantity, in: 3 ... 20)
                }

                Section {
                    Toggle("Any special requests?", isOn: $order.specialRequestEnabled.animation())

                    if order.specialRequestEnabled {
                        Toggle("Add extra frosting", isOn: $order.extraFrosting)
                        Toggle("Add sprinkles", isOn: $order.addSprinkles)
                    }
                }

                NavigationLink {
                    AddressView(order: order)
                } label: {
                    Text("Continue")
                }
                .foregroundColor(.accentColor)
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
