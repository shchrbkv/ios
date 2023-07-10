//
//  MapViewController.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/7/22.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
	
	@IBOutlet var mapView: MKMapView!
	
	// Locations array for manual CD interaction
	var locations = [Location]()
	
	// Managed context with observer for changes
	var managedObjectContext: NSManagedObjectContext! {
		didSet {
			NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main
			)
			{ [unowned self] notification in
				
				if !self.isViewLoaded { return }
				
				// User Info Dictionary
				guard let dictionary = notification.userInfo else { return }
				
				// Add location and annotation on insert
				if let inserts = dictionary[NSInsertedObjectsKey] as? Set<NSManagedObject> {
					if let insert = inserts.first as? Location {
						
						locations.append(insert)
						
						let annotation = insert as MKAnnotation
						
						mapView.addAnnotation(annotation)
					}
				}
				
				// Update location and annotation on update
				if let updates = dictionary[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
					if let update = updates.first as? Location {
						
						let annotation = update as MKAnnotation
						
						let wasSelected = mapView.selectedAnnotations.contains {$0 === annotation}
						
						// There's no way to update existing annotation, so
						// you have to remove it and add again
						mapView.removeAnnotation(annotation)
						mapView.addAnnotation(annotation)
						
						// Reselect after update
						if wasSelected {
							mapView.selectAnnotation(annotation, animated: false)
						}
						
					}
				}
				
				if let deletes = dictionary[NSDeletedObjectsKey] as? Set<NSManagedObject> {
					if let delete = deletes.first as? Location {
						if let index = locations.firstIndex(where: {$0.objectID == delete.objectID}) {
							
							locations.remove(at: index)
							
							let annotation = delete as MKAnnotation
							mapView.removeAnnotation(annotation)
						}
					}
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateLocations()
		if !locations.isEmpty {
			showLocations()
		}
	}
	
	// MARK: - Actions
	
	// Setting map region 1x1 km around user location
	@IBAction func showUser() {
		let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
		
		mapView.setRegion(region, animated: true)
	}
	
	@IBAction func showLocations() {
		let theRegion = region(for: locations)
		mapView.setRegion(theRegion, animated: true)
	}
	
	// MARK: - Helper Methods
	
	// Fetch locations to add annotations
	func updateLocations() {
		mapView.removeAnnotations(locations)
		
		let entity = Location.entity()
		
		let fetchRequest = NSFetchRequest<Location>()
		fetchRequest.entity = entity
		
		locations = try! managedObjectContext.fetch(fetchRequest)
		mapView.addAnnotations(locations)
	}
	
	// Determine region based on number of locations
	func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
		let region: MKCoordinateRegion
		
		switch annotations.count {
		case 0:
			region = MKCoordinateRegion(
				center: mapView.userLocation.coordinate,
				latitudinalMeters: 1000,
				longitudinalMeters: 1000)
			
		case 1:
			let annotation = annotations.first!
			region = MKCoordinateRegion(
				center: annotation.coordinate,
				latitudinalMeters: 1000,
				longitudinalMeters: 1000)
			
		default:
			var topLeft = CLLocationCoordinate2D(
				latitude: -90,
				longitude: 180)
			var bottomRight = CLLocationCoordinate2D(
				latitude: 90,
				longitude: -180)
			
			// Starting from bound lat/long values to widen region
			// for all annotations
			for annotation in annotations {
				topLeft.latitude = max(topLeft.latitude,
									   annotation.coordinate.latitude)
				topLeft.longitude = min(topLeft.longitude,
										annotation.coordinate.longitude)
				bottomRight.latitude = min(bottomRight.latitude,
										   annotation.coordinate.latitude)
				bottomRight.longitude = max(
					bottomRight.longitude,
					annotation.coordinate.longitude)
			}
			
			// Center based on result region
			let center = CLLocationCoordinate2D(
				latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
				longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
			
			// Getting desired zoom for region with extra space around
			let extraSpace = 1.5
			let span = MKCoordinateSpan(
				latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
				longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
			
			region = MKCoordinateRegion(center: center, span: span)
		}
		
		// Focus map on chosen region
		return mapView.regionThatFits(region)
	}
	
	// Move to location details as action for custom pins
	@objc func showLocationDetails(_ sender: UIButton) {
		performSegue(withIdentifier: "EditLocation", sender: sender)
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditLocation" {
			let controller = segue.destination as! LocationDetailsViewController
			controller.managedObjectContext = managedObjectContext
			
			let button = sender as! UIButton
			// Get location based on set tag
			let location = locations[button.tag]
			controller.locationToEdit = location
		}
	}
	
	
}

extension MapViewController: MKMapViewDelegate {
	
	func mapView(
		_ mapView: MKMapView,
		viewFor annotation: MKAnnotation
	) -> MKAnnotationView? {
		// Check if annotation is Location
		guard annotation is Location else {
			return nil
		}

		let identifier = "Location"
		var annotationView = mapView.dequeueReusableAnnotationView(
			withIdentifier: identifier)
		
		// Create a new pin view with callout
		if annotationView == nil {
			let pinView = MKPinAnnotationView(
				annotation: annotation,
				reuseIdentifier: identifier)
			pinView.isEnabled = true
			pinView.canShowCallout = true
			pinView.animatesDrop = false
			pinView.pinTintColor = UIColor(
				red: 0.32,
				green: 0.82,
				blue: 0.4,
				alpha: 1)
			
			// Configure right callout button to perform segue
			let rightButton = UIButton(type: .detailDisclosure)
			rightButton.addTarget(
				self,
				action: #selector(showLocationDetails(_:)),
				for: .touchUpInside)
			pinView.rightCalloutAccessoryView = rightButton
			
			annotationView = pinView
		}
		
		// If annotation view was dequeued change its button tag to location id
		if let annotationView = annotationView {
			annotationView.annotation = annotation
			
			// 5
			let button = annotationView.rightCalloutAccessoryView as! UIButton
			if let index = locations.firstIndex(of: annotation as! Location) {
				button.tag = index
			}
		}
		
		return annotationView
	}
}
