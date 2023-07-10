import Combine
import Foundation

// MARK: - DispatchTimerConfiguration

/// Fun gimmick to pass common configuration between publisher and subscription
struct DispatchTimerConfiguration {
    
    /// Can be specified or `nil` to leave it for Dispatch to decide
    let queue: DispatchQueue?
    
    /// Time between consecutive fires
    let interval: DispatchTimeInterval
    
    /// Time span in which event has to fire
    let leeway: DispatchTimeInterval
    
    /// How many **total** times the publisher can fire no matter the demand
    let times: Subscribers.Demand
}

// MARK: - Publishers.DispatchTimer

extension Publishers {
    /// Publisher for timer
    struct DispatchTimer: Publisher {
        
        typealias Output = DispatchTime
        typealias Failure = Never

        /// Configuration passed through `init`
        let configuration: DispatchTimerConfiguration

        init(configuration: DispatchTimerConfiguration) {
            self.configuration = configuration
        }

        /// Method called by subscriber to get a new subscription
        /// Subscriber (e. g. `sink`) -> Publisher's `receive(subscriber:)` -> Subscriber's `receive(subscription:)`
        /// Subscription actually publishes events and handles all Subscriber's demands
        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = DispatchTimerSubscription(subscriber: subscriber, configuration: configuration)

            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - DispatchTimerSubscription

/// The logic part of the Publisher <-> Subscriber interaction
private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {
    /// Immutable configuration from `init()`
    let configuration: DispatchTimerConfiguration
    
    /// Total times from configuration
    var times: Subscribers.Demand
    
    /// Current demand counter. Decreases every time event fires until `.none`.
    /// Initialized so that it won't be needed in `init`. Will be rewritten by fiirst request's demand.
    var requested: Subscribers.Demand = .none
    
    /// Current timer reference. Needed for deinit and first run.
    var source: DispatchSourceTimer? = nil
    
    /// Reference to subscriber. Needed for deinit and responses through `receive()`.
    var subscriber: S?

    init(subscriber: S, configuration: DispatchTimerConfiguration) {
        self.configuration = configuration
        self.subscriber = subscriber
        
        times = configuration.times
    }

    func request(_ demand: Subscribers.Demand) {
        /// If first request has no room for execution —> short circuit `.finished`
        guard times > .none else {
            subscriber?.receive(completion: .finished)
            return
        }
        
        /// Rewrite requested counter by adding new demand. `unlimited` by default.
        requested += demand
        
        /// If it is the first run (so there's no source) and requested demand was not `.none`.
        if source == nil, requested > .none {
            
            /// Create a `DispatchSourceTimer` for particular (or any if `nil`) queue.
            let source = DispatchSource.makeTimerSource(queue: configuration.queue)

            /// Schedule fires from timer based on config. Starting immediately.
            source.schedule(
                deadline: .now(),
                repeating: configuration.interval,
                leeway: configuration.leeway)

            /// Closure to execute on each timer fire. Needs `[weak self]` to reference sub.
            source.setEventHandler { [weak self] in
                
                /// If there's still demand for new values
                guard let self,
                      requested > .none else { return }
                
                /// Lower total count and demand
                requested -= .max(1)
                times -= .max(1)

                /// Send current time, but skip it's new demand as we already lowered our `requested` value.
                /// NOTE: Receive usually returns a `max(0)` as there are no changes to demand.
                _ = subscriber?.receive(.now())

                /// If after this iteration encountered limit of total values -> complete.
                if times == .none {
                    subscriber?.receive(completion: .finished)
                }
            }

            /// Replace (set) subscription's source with this one
            self.source = source
            
            /// Start the timer
            source.activate()
        }
    }
    
    /// Cancel the subscription. Release strong references to `DispatchSourceTimer` and the subscriber to
    /// avoid retain cycles and `deinit` successfully.
    func cancel() {
        source = nil
        subscriber = nil
    }
}

extension Publishers {

    /// Shortcut to create a preinited `DispatchTimer`
    static func timer(
        queue: DispatchQueue? = nil,
        interval: DispatchTimeInterval,
        leeway: DispatchTimeInterval = .nanoseconds(0),
        times: Subscribers.Demand = .unlimited) -> Publishers.DispatchTimer {
        Publishers.DispatchTimer(configuration: .init(queue: queue, interval: interval, leeway: leeway, times: times))
    }

}

var logger = TimeLogger(sinceOrigin: true)

let publisher = Publishers.timer(interval: .seconds(1), times: .max(6))

let subscription = publisher.sink { time in
    print("Timer emits: \(time)", to: &logger)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
    subscription.cancel()
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
