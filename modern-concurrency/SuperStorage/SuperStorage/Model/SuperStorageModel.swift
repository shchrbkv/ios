/// Copyright (c) 2023 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Observation

// MARK: - SuperStorageModel

/// The download model.
@Observable
class SuperStorageModel {
  /// The list of currently running downloads.
  var downloads: [DownloadInfo] = []

  @TaskLocal static var supportsPartialDownloads = false

  /// Downloads a file and returns its content.
  func download(file: DownloadFile) async throws -> Data {
    guard let url = URL(string: "http://localhost:8080/files/download?\(file.name)") else {
      throw "Could not create the URL."
    }
    await addDownload(name: file.name)

    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    await updateDownload(name: file.name, progress: 1.0)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }

    return data
  }

  /// Downloads a file, returns its data, and updates the download progress in ``downloads``.
  func downloadWithProgress(file: DownloadFile) async throws -> Data {
    try await downloadWithProgress(fileName: file.name, name: file.name, size: file.size)
  }

  /// Downloads a file, returns its data, and updates the download progress in ``downloads``.
  private func downloadWithProgress(fileName: String, name: String, size: Int, offset: Int? = nil) async throws -> Data {
    guard let url = URL(string: "http://localhost:8080/files/download?\(fileName)") else {
      throw "Could not create the URL."
    }

    await addDownload(name: name)

    let result: (downloadStream: URLSession.AsyncBytes, response: URLResponse)

    if let offset {
      let urlRequest = URLRequest(url: url, offset: offset, length: size)
      result = try await URLSession.shared.bytes(for: urlRequest)

      guard (result.response as? HTTPURLResponse)?.statusCode == 206 else {
        throw "The server responded with an error."
      }
    } else {
      result = try await URLSession.shared.bytes(from: url)

      guard (result.response as? HTTPURLResponse)?.statusCode == 200 else {
        throw "The server responded with an error."
      }
    }

    var asyncDownloadIterator = result.downloadStream.makeAsyncIterator()

    var accumulator = ByteAccumulator(name: name, size: size)

    // await as stopDownloads isolated to main actor
    while await !stopDownloads, !accumulator.checkCompleted() {
      while !accumulator.isBatchCompleted,
            let byte = try await asyncDownloadIterator.next() {
        accumulator.append(byte)
      }

      let progress = accumulator.progress
      print(accumulator.description)

      Task.detached(priority: .medium) {
        await self.updateDownload(name: name, progress: progress)
      }
    }

    if await stopDownloads, !Self.supportsPartialDownloads {
      throw CancellationError()
    }

    return accumulator.data
  }

  /// Downloads a file using multiple concurrent connections, returns the final content, and updates the download progress.
  func multiDownloadWithProgress(file: DownloadFile) async throws -> Data {
    typealias PartInfo = (offset: Int, size: Int, name: String)

    func partInfo(index: Int, of count: Int) -> PartInfo {
      let standardPartSize = Int((Double(file.size) / Double(count)).rounded(.up))
      let partOffset = index * standardPartSize
      let partSize = min(standardPartSize, file.size - partOffset)
      let partName = "\(file.name) (part \(index + 1))"
      return PartInfo(offset: partOffset, size: partSize, name: partName)
    }
    let total = 4
    let parts = (0 ..< total).map { partInfo(index: $0, of: total) }

    return try await withThrowingTaskGroup(of: (Int, Data).self) { group in
      for (id, part) in parts.enumerated() {
        group.addTask {
          try await (id, self.downloadWithProgress(fileName: file.name, name: part.name, size: part.size, offset: part.offset))
        }
      }
      
      var parts = [Data](repeating: Data(), count: total)
      
      for try await (id, result) in group {
        parts[id] = result
      }
      
      return parts.reduce(Data(), +)
    }
  }

  /// Flag that stops ongoing downloads.
  @MainActor @ObservationIgnored var stopDownloads = false

  @MainActor
  func reset() {
    stopDownloads = false
    downloads.removeAll()
  }

  func availableFiles() async throws -> [DownloadFile] {
    guard let url = URL(string: "http://localhost:8080/files/list") else {
      throw "Could not create the URL."
    }
    let (data, response) = try await URLSession.shared.data(from: url)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }

    guard let list = try? JSONDecoder().decode([DownloadFile].self, from: data) else {
      throw "The server response was not recognized."
    }
    return list
  }

  func status() async throws -> String {
    guard let url = URL(string: "http://localhost:8080/files/status") else {
      throw "Could not create the URL."
    }
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }
    return String(decoding: data, as: UTF8.self)
  }
}

extension SuperStorageModel {
  /// Adds a new download.
  @MainActor
  func addDownload(name: String) {
    let downloadInfo = DownloadInfo(id: UUID(), name: name, progress: 0.0)
    downloads.append(downloadInfo)
  }

  /// Updates a the progress of a given download.
  @MainActor
  func updateDownload(name: String, progress: Double) {
    if let index = downloads.firstIndex(where: { $0.name == name }) {
      var info = downloads[index]
      info.progress = progress
      downloads[index] = info
    }
  }
}
