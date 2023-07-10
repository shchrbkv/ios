import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

// filter(_:)

// let numbers = (1...10).publisher
//
// numbers
//    .filter { $0.isMultiple(of: 3) }
//    .sink { print("\($0) is a multiple of three")}
//    .store(in: &subscriptions)

// removeDuplicates()

// let words = " hey hey there! want to listen to mister mister ?"
//    .components(separatedBy: " ")
//    .publisher
//
// words
//    .removeDuplicates()
//    .sink { print($0) }
//    .store(in: &subscriptions)

// compactMap()

// let strings = ["a", "1.24", "3", "def"].publisher
//
// strings
//    .compactMap { Float($0) }
//    .sink { print($0) }
//    .store(in: &subscriptions)
//

// ignoreOutput()

// let numbers = (1...10_000).publisher
//
// numbers
//    .ignoreOutput()
//    .sink(receiveCompletion: { _ in print("Completed") }, receiveValue: { print($0) })
//    .store(in: &subscriptions)

// finding values

// let numbers = (1...9).publisher
//
// numbers
//    .print("numbers")
//    .first(where: { $0 % 2 == 0 }) // halts upstream when finds
//    .sink { print($0) }
//
// numbers
//    .last { $0 % 2 == 0}
//    .sink { print($0) }

// Dropping values

//let isReady = PassthroughSubject<Void, Never>()
//let taps = PassthroughSubject<Int, Never>()
//
//taps
//    .drop(untilOutputFrom: isReady)
//    .sink { print($0) }
//
//(1 ... 5).forEach { n in
//    taps.send(n)
//
//    if n == 3 {
//        isReady.send()
//    }
//}

// Limiters


