//
//  TimeoutTask.swift
//  BlabberTests
//
//  Created by Alex Scherbakov on 7/7/23.
//

import Foundation

// MARK: - TimeoutTask

class TimeoutTask<Success> {
  let duration: Duration
  let operation: @Sendable () async throws -> Success
  
  init(duration: Duration, operation: @escaping @Sendable () async throws -> Success) {
    self.duration = duration
    self.operation = operation
  }
  
  private var continuation: CheckedContinuation<Success, Error>?
  
  var value: Success {
    get async throws {
      try await withCheckedThrowingContinuation { continuation in
        self.continuation = continuation
        Task {
          try await Task.sleep(for: duration)
          self.continuation?.resume(throwing: TimeoutError())
          self.continuation = nil
        }
        Task {
          let result = try await operation()
          self.continuation?.resume(returning: result)
          self.continuation = nil
        }
      }
    }
  }
  
  func cancel() {
    continuation?.resume(throwing: CancellationError())
    continuation = nil
  }
}

// MARK: TimeoutTask.TimeoutError

extension TimeoutTask {
  struct TimeoutError: LocalizedError {
    var errorDescription: String? { return "The operation timed out." }
  }
}
