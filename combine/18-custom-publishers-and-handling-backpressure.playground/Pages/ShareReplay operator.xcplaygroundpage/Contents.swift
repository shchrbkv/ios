import Combine
import Foundation

// MARK: - ShareReplaySubscription

private final class ShareReplaySubscription<Output, Failure: Error>: Subscription {

    let capacity: Int

    var subscriber: AnySubscriber<Output, Failure>? = nil

    var demand: Subscribers.Demand = .none

    var buffer: [Output]

    var completion: Subscribers.Completion<Failure>? = nil

    init<S>(
        subscriber: S,
        replay: [Output],
        capacity: Int,
        completion: Subscribers.Completion<Failure>?)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
        self.subscriber = AnySubscriber(subscriber)
        buffer = replay
        self.capacity = capacity
        self.completion = completion
    }

    private func complete(with completion: Subscribers.Completion<Failure>) {
        guard let subscriber else { return }
        self.subscriber = nil
        self.completion = nil
        buffer.removeAll()
        subscriber.receive(completion: completion)
    }

    private func emitAsNeeded() {
        guard let subscriber else { return }

        while demand > .none, !buffer.isEmpty {
            demand -= .max(1)
            let nextDemand = subscriber.receive(buffer.removeFirst())
            if nextDemand != .none {
                demand += nextDemand
            }
        }

        if let completion {
            complete(with: completion)
        }
    }

    func request(_ demand: Subscribers.Demand) {
        if demand != .none {
            self.demand += demand
        }
        emitAsNeeded()
    }

    func cancel() {
        complete(with: .finished)
    }

}

extension ShareReplaySubscription {

    func receive(_ input: Output) {
        guard subscriber != nil else { return }

        buffer.append(input)

        if buffer.count > capacity {
            buffer.removeFirst()
        }

        emitAsNeeded()
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        guard let subscriber else { return }
        self.subscriber = nil
        buffer.removeAll()
        subscriber.receive(completion: completion)
    }
}

// MARK: - Publishers.ShareReplay

extension Publishers {

    final class ShareReplay<Upstream: Publisher>: Publisher {

        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure

        private let lock = NSRecursiveLock()

        private let upstream: Upstream

        private let capacity: Int

        private var replay = [Output]()

        private var subscriptions = [ShareReplaySubscription<Output, Failure>]()

        private var completion: Subscribers.Completion<Failure>? = nil

        init(upstream: Upstream, capacity: Int) {
            self.upstream = upstream
            self.capacity = capacity
        }

        private func relay(_ value: Output) {
            lock.lock()
            defer { lock.unlock() }

            guard completion == nil else { return }

            replay.append(value)
            if replay.count > capacity {
                replay.removeFirst()
            }

            subscriptions.forEach {
                $0.receive(value)
            }
        }

        private func complete(_ completion: Subscribers.Completion<Failure>) {
            lock.lock()
            defer { lock.unlock() }

            self.completion = completion

            subscriptions.forEach {
                $0.receive(completion: completion)
            }
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            lock.lock()
            defer { lock.unlock() }

            let subscription = ShareReplaySubscription(
                subscriber: subscriber,
                replay: replay,
                capacity: capacity,
                completion: completion)

            subscriptions.append(subscription)

            subscriber.receive(subscription: subscription)

            guard subscriptions.count == 1 else { return }

            let sink = AnySubscriber { subscription in
                subscription.request(.unlimited)
            } receiveValue: { [weak self] (value: Output) -> Subscribers.Demand in
                self?.relay(value)
                return .none
            } receiveCompletion: { [weak self] in
                self?.complete($0)
            }
            
            upstream.subscribe(sink)
        }
    }
}

extension Publisher {
    func shareReplay(capacity: Int) -> Publishers.ShareReplay<Self> {
        return Publishers.ShareReplay(upstream: self, capacity: capacity)
    }
}


var logger = TimeLogger(sinceOrigin: true)

let subject = PassthroughSubject<Int, Never>()

let publisher = subject
    .print("shareReplay")
    .shareReplay(capacity: 2)

subject.send(0)

let subscription1 = publisher.sink { print("Sub1: \($0)", to: &logger) }

subject.send(1)
subject.send(2)
subject.send(3)

let subscription2 = publisher.sink { print("Sub2: \($0)", to: &logger) }

subject.send(4)
subject.send(5)
subject.send(completion: .finished)

var subscription3: Cancellable? = nil

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
  print("Subscribing to shareReplay after upstream completed")
  subscription3 = publisher.sink(
    receiveCompletion: {
      print("subscription3 completed: \($0)", to: &logger)
    },
    receiveValue: {
      print("subscription3 received \($0)", to: &logger)
    }
  )
}
//: [Next](@next)
/// :
// Copyright (c) 2021 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
