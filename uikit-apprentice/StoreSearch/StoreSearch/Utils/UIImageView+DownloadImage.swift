//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/14/22.
//

import UIKit

extension UIImageView {
	func loadImage(url: URL) -> URLSessionDownloadTask {
		let session = URLSession.shared
		
		// [weak self] so if image is still downloading but parent view is closed,
		// it won't have retain cycle with UIImageView
		let downloadTask = session.downloadTask(with: url) { [weak self] url, _, error in
			if error == nil,
			   let url = url,
			   let data = try? Data(contentsOf: url),
			   let image = UIImage(data: data) {
				DispatchQueue.main.async {
					if let weakSelf = self {
						weakSelf.image = image
					}
				}
			}
		}
		
		downloadTask.resume()
		return downloadTask
	}
}
