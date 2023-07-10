//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/5/22.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
	
	public var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2DMake(latitude, longitude)
	}
	
	
	public var title: String? {
		if locationDescription.isEmpty {
			return "(No Description)"
		} else {
			return locationDescription
		}
	}
	
	public var subtitle: String? {
		return category
	}
	
	public var hasPhoto: Bool {
		return photoID != nil
	}
	
	// Get url with placeholder name to save image based on ID
	public var photoURL: URL {
		assert(photoID != nil, "No photoID set!")
		let filename = "Photo-\(photoID!.intValue).jpg"
		return applicationDocumentDirectory.appendingPathComponent(filename)
	}
	
	// Load to UIImage from photoURL
	public var photoImage: UIImage? {
		return UIImage(contentsOfFile: photoURL.path)
	}
	
	// Get photo ID based on current in user defaults
	public class func nextPhotoID() -> Int {
		let userDefaults = UserDefaults.standard
		let currentID = userDefaults.integer(forKey: "PhotoID") + 1
		userDefaults.set(currentID, forKey: "PhotoID")
		return currentID
	}
	
	// Remove file for photo
	public func removePhotoFile() {
		do {
			try FileManager.default.removeItem(at: photoURL)
		} catch {
			print("Error removing file: \(error)")
		}
	}
}
