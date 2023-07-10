import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

// collect(_:)

// ["A", "B", "C", "D", "E"].publisher
//    .collect(2)
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &subscriptions)
//

// map(_:)

// let formatter = NumberFormatter()
// formatter.numberStyle = .spellOut
//
// [123, 4, 56].publisher
//    .map {
//        formatter.string(for: $0) ?? ""
//    }
//    .sink(receiveValue: { print($0) })
//    .store(in: &subscriptions)

// map<T>(_:)

// let publisher = PassthroughSubject<Coordinate, Never>()
//
// publisher
//    .map(\.x, \.y)
//    .sink { x, y in
//        print("(\(x), \(y)) is in quadrant", quadrantOf(x: x, y: y))
//    }
//    .store(in: &subscriptions)
//
// publisher.send(Coordinate(x: 10, y: -8))

// tryMap(_:)

// Just("Abracadabra")
//    .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
//    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
//    .store(in: &subscriptions)

// flatMap(maxPublishers:_:)

// func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
//    Just(
//        codes
//            .compactMap { code in
//                guard (32 ... 255).contains(code) else { return nil }
//                return String(UnicodeScalar(code) ?? " ")
//            }
//            .joined())
//        .eraseToAnyPublisher()
// }
//
// [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]
//    .publisher
//    .collect()
//    .flatMap(decode)
//    .sink { print($0) }
//    .store(in: &subscriptions)

// replaceNil(with:)

// ["A", nil, "C"].publisher
//    .eraseToAnyPublisher() // used to force conversion from String? to String
//    .replaceNil(with: "-")
//    .sink(receiveValue: { print($0) })
//    .store(in: &subscriptions)

// replaceEmpty(with:)

// let empty = Empty<Int, Never>()
//
// empty
//    .replaceEmpty(with: 1)
//    .sink { print($0) } receiveValue: { print($0) }
//    .store(in: &subscriptions)

// scan(_:_:)

var dailyGainLoss: Int { .random(in: -10 ... 10) }

let august2019 = (0 ..< 22)
    .map { _ in dailyGainLoss }
    .publisher

august2019
    .scan(50) { latest, current in
        max(0, latest + current)
    }
