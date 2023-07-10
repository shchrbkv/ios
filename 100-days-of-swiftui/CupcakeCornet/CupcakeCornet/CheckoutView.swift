//
//  Checkout.swift
//  CupcakeCornet
//
//  Created by Alex Scherbakov on 4/7/23.
//

import SwiftUI

// MARK: - CheckoutView

struct CheckoutView: View {
    @ObservedObject var order: Order

    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false

    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)

                Text("Your total cost is \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)

                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
    }

    // MARK: Internal

    func placeOrder() async {
        guard let encoded = try? JSONEncoder().encode(order) else {
            return
        }

        let url = URL(string: "https://reqres.in/api/cupcakes")!

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)

            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage =
                "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way"
            showingConfirmation = true
        } catch {
            print("Error")
        }
    }
}

// MARK: - CheckoutView_Previews

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
