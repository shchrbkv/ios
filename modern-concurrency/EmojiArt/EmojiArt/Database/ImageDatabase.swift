/// Copyright (c) 2023 Razeware LLC
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

import OSLog
import UIKit

private let logger = Logger(subsystem: "EmojiArt", category: "ImageDatabase")

// MARK: - ImageDatabase

@globalActor
actor ImageDatabase {
  static let shared = ImageDatabase()
  private init() { }

  let imageLoader = ImageLoader.shared

  private var storage: DiskStorage!
  private var storedImagesIndex = Set<String>()

  // On disk access stream
  @MainActor private(set) var onDiskAccess: AsyncStream<Int>?

  private var onDiskAccessContinuation: AsyncStream<Int>.Continuation?
  private var onDiskAccessCount = 0 {
    didSet { onDiskAccessContinuation?.yield(onDiskAccessCount) }
  }

  // Setup
  func setup() async throws {
    storage = await DiskStorage()

    let onDiskAccessStream = AsyncStream<Int> { continuation in
      onDiskAccessContinuation = continuation
    }
    await MainActor.run { onDiskAccess = onDiskAccessStream }

    await imageLoader.setup()
    
    for fileURL in try await storage.persistedFiles() {
      storedImagesIndex.insert(fileURL.lastPathComponent)
      logger.notice("Loaded image: \(fileURL.lastPathComponent)")
    }
  }
  
  deinit { onDiskAccessContinuation?.finish()}

  func store(image: UIImage, forKey key: String) async throws {
    guard let data = image.pngData() else {
      throw "Could not save image \(key)"
    }
    let fileName = DiskStorage.fileName(for: key)
    try await storage.write(data, name: fileName)
    storedImagesIndex.insert(fileName)
  }

  func image(_ key: String) async throws -> UIImage {
    // Image in memory
    let keys = await imageLoader.cache.keys // Local copy as cache concurrently changes
    if keys.contains(key) {
      logger.notice("\(key) is cached in-memory")
      return try await imageLoader.image(key)
    }

    // Image on disk
    do {
      let fileName = DiskStorage.fileName(for: key)
      if !storedImagesIndex.contains(fileName) {
        throw "Image \(fileName) not persisted"
      }

      let data = try await storage.read(name: fileName)
      onDiskAccessCount += 1
      
      guard let image = UIImage(data: data) else {
        throw "Invalid image data for \(fileName)"
      }

      logger.notice("Cached on disk")

      await imageLoader.add(image, forKey: key)
      return image
    } catch {
      logger.error("\(error.localizedDescription)")
    }

    // Else download from server
    let image = try await imageLoader.image(key)
    try await store(image: image, forKey: key)
    return image
  }

  func clear() async {
    for name in storedImagesIndex {
      try? await storage.remove(name: name)
    }
    storedImagesIndex.removeAll()
  }

  func clearInMemoryAssets() async {
    await imageLoader.clear()
  }
}
