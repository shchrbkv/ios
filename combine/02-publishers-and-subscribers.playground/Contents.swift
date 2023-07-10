import _Concurrency
import Combine
import Foundation

// MARK: - SomeObject

/// ** Notification Center Publisher

// var subscriptions = Set<AnyCancellable>()
//
// let myNotification = Notification.Name("MyNotification")
//
// let publisher = NotificationCenter.default.publisher(for: myNotification, object: nil)
//
// let center = NotificationCenter.default
//
// let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in
//    print("Notification received")
// }
//
// center.post(name: myNotification, object: nil)
//
// center.removeObserver(observer)

/// ** Notification Center  Subscriber

// let myNotification = Notification.Name("MyNotification")
// let center = NotificationCenter.default
//
// let publisher = center.publisher(for: myNotification, object: nil)
//
// let subscription = publisher.sink { _ in
//    print("Notification from publisher!")
// }
//
// center.post(name: myNotification, object: nil)
//
// subscription.cancel()

/// ** Just

// let just = Just("Hello")
//
// _ = just.sink(
//    receiveCompletion: {
//        print("Received completion",  $0)
//    }, receiveValue: {
//        print("Received value", $0)
//    })
//
// _ = just.sink(
//    receiveCompletion: {
//        print("Received completion 2",  $0)
//    }, receiveValue: {
//        print("Received value 2", $0)
//    })

/// ** assign(to:on:)

// class SomeObject {
//    var value: String = "" {
//        didSet {
//            print(value)
//        }
//    }
// }
//
// let object = SomeObject()
//
// let publisher = ["Hello", "World"].publisher
//
// _ = publisher.assign(to: \.value, on: object)

/// ** assign(to:)

// class SomeObject {
//    @Published var value = 0
// }
//
// let object = SomeObject()
//
// object.$value.sink {
//    print($0)
// }
//
// (0..<10).publisher.assign(to: &object.$value)

/// ** Cancellable

// let publisher = (1 ... 6).publisher
//
//// MARK: - IntSubscriber
//
// final class IntSubscriber: Subscriber {
//
//    typealias Input = Int
//    typealias Failure = Never
//
//    // MARK: Internal
//
//    func receive(subscription: Subscription) {
//        subscription.request(.max(3))
//    }
//
//    func receive(_ input: Input) -> Subscribers.Demand {
//        print("Received value", input)
//        return .none
//    }
//
//    func receive(completion: Subscribers.Completion<Never>) {
//        print("Received completion", completion)
//    }
// }
//
// let subscriber = IntSubscriber()
//
// publisher.subscribe(subscriber)

/// **  Futures
//
// var subscriptions = Set<AnyCancellable>()
//
// func futureIncrement(integer: Int, afterDelay delay: Int) -> Future<Int, Never> {
//    Future<Int, Never> { promise in
//        print("Original")
//        Task {
//            try await Task.sleep(for: .seconds(delay))
//            promise(.success(integer + 1))
//        }
//    }
// }
//
// let future = futureIncrement(integer: 1, afterDelay: 3)
//
// future
//    .sink(
//        receiveCompletion: { print($0) },
//        receiveValue: { print($0) })
//    .store(in: &subscriptions)
//
// future
//    .sink(
//        receiveCompletion: { print("Second", $0) },
//        receiveValue: { print("Second", $0) })
//    .store(in: &subscriptions)

/// ** Subject

// enum MyError: Error {
//    case test
// }
//
// final class StringSubscriber: Subscriber {
//
//    typealias Input = String
//    typealias Failure = MyError
//
//    func receive(subscription: Subscription) {
//        subscription.request(.max(2))
//    }
//
//    func receive(_ input: String) -> Subscribers.Demand {
//        print("Value", input)
//        return input == "World" ? .max(1) : .none
//    }
//
//    func receive(completion: Subscribers.Completion<MyError>) {
//        print("Completion", completion)
//    }
// }
//
// let subscriber = StringSubscriber()
//
// let subject = PassthroughSubject<String, MyError>()
//
// subject.subscribe(subscriber)
//
// let subscription = subject
//    .sink { completion in
//        print("Sink Completion", completion)
//    } receiveValue: { value in
//        print("Sink Value", value)
//    }
//
// subject.send("Hello")
// subject.send("World")
//
// subscription.cancel()
//
// subject.send("Still there?")
//
// subject.send(completion: .failure(MyError.test))
// subject.send("And now?")

/// ** CurrentValueSubject

// var subscriptions = Set<AnyCancellable>()
//
// let subject = CurrentValueSubject<Int, Never>(0)
//
// subject
//    .print()
//    .sink { completion in
//        print("Completion", completion)
//    } receiveValue: { value in
//        print("Value", value)
//    }
//    .store(in: &subscriptions)
//
//
// subject.send(1)
// subject.send(2)
//
// subject.value = 3
//
// subject
//    .print()
//    .sink(receiveValue: { print("Second", $0) })
//    .store(in: &subscriptions)

/// ** Dynamically adjusting demand

//final class IntSubscriber: Subscriber {
//
//    typealias Input = Int
//    typealias Failure = Never
//
//    // MARK: Internal
//
//    func receive(subscription: Subscription) {
//        subscription.request(.max(2))
//    }
//
//    func receive(_ input: Int) -> Subscribers.Demand {
//        print("Received", input)
//
//        switch input {
//        case 1:
//            return .max(2) // 4
//        case 3:
//            return .max(1) // 5
//        default:
//            return .none
//        }
//    }
//
//    func receive(completion: Subscribers.Completion<Never>) {
//        print("Completion", completion)
//    }
//}
//
//
//let subscriber = IntSubscriber()
//
//let subject = PassthroughSubject<Int, Never>()
//
//subject.subscribe(subscriber)
//
//subject.send(1)
//subject.send(2)
//subject.send(3)
//subject.send(4)
//subject.send(5)
//subject.send(6)


///** Type Erasure

//let subject = PassthroughSubject<Int, Never>()
//
//let publisher = subject.eraseToAnyPublisher() // Prevents users from accessing .send()
//
//publisher
//    .sink(receiveValue: { print($0) })
//
//subject.send(0)


///** async/await Bridging

//let subject = CurrentValueSubject<Int, Never>(0)
//
//Task {
//    for await element in subject.values {
//        print("Element:", element)
//    }
//    print("Completed.")
//}
//
//subject.send(1)
//subject.send(2)
//subject.send(3)
//
//subject.send(completion: .finished)

