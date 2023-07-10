import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

// min()

let publisher = [1, 20, -50, 36].publisher

publisher
    .print("publisher")
    .min()
    .sink { print("Lowest value is \($0)") }
