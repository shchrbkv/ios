import Combine
import Foundation

// MARK: - Pausable

protocol Pausable {
    var paused: Bool { get }
    func resume()
}

// MARK: - PausableSubscriber

final class PausableSubscriber<Input, Failure: Error>: Subscriber, Pausable, Cancellable {

    let combineIdentifier = CombineIdentifier()

    let receiveValue: (Input) -> Bool

    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    private var subscription: Subscription? = nil

    var paused = false

    init(
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        receiveValue: @escaping (Input) -> Bool) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        paused = receiveValue(input) == false
        return paused ? .none : .max(1)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        subscription = nil
    }

    func resume() {
        guard paused else { return }

        paused = false
        subscription?.request(.max(1))
    }

    func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}

extension Publisher {

    func pausableSink(
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        receiveValue: @escaping (Output) -> Bool)
        -> Pausable & Cancellable {
        let pausable = PausableSubscriber(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        subscribe(pausable)
        return pausable
    }
}

let subscription = [1, 2, 3, 4, 5, 6].publisher
    .pausableSink(
        receiveCompletion: { completion in
            print("Pausable sub completed")
        },
        receiveValue: { value -> Bool in
            print("Value \(value)")
            if value % 2 == 1 {
                print("Pausing")
                return false
            }
            return true
        })

let timer = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()
    .sink { _ in
        guard subscription.paused else { return }
        print("Resuming")
        subscription.resume()
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
