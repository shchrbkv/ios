//
//  Functions.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/4/22.
//

import Foundation

let applicationDocumentDirectory: URL = {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}()

// Execute after delay in main thread
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(
		deadline: .now() + seconds,
		execute: run)
}

let dataSaveFailedNotification = Notification.Name("DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
	print("Fatal error: \(error)")
	NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}
