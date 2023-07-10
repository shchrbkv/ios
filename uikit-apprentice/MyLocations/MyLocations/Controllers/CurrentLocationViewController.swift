//
//  ViewController.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/2/22.
//

import UIKit
import CoreLocation
import CoreData
import PhotosUI
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
	
	// Used for first load animation
	var logoVisible = false
	
	// Lazy load for embedded customization of logo button
	lazy var logoButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
		button.sizeToFit()
		// Using main method as action for the logo button
		button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
		button.center.x = self.view.bounds.midX
		button.center.y = 220
		return button
	}()
	
	// Outlets to storyboard elements
	@IBOutlet var containerView: UIView!
	@IBOutlet var latitudeTextLabel: UILabel!
	@IBOutlet var longitudeTextLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var tagButton: UIButton!
	@IBOutlet weak var getButton: UIButton!
	
	// Core Location manager for the app
	let locationManager = CLLocationManager()
	
	var location: CLLocation?
	var updatingLocation = false
	var lastLocationError: Error?
	
	let geocoder = CLGeocoder()
	var placemark: CLPlacemark?
	var performingReverseGeocoding = false
	var lastGeocodingError: Error?
	var timer: Timer?
	
	// Core Data managed context
	var managedObjectContext: NSManagedObjectContext!
	
	// MARK: - Actions
	
	// Perform initial location services configuration and start location
	// search afterwards for [Get My Location] button
	@IBAction func getLocation() {
		
		// Check current auth status for location services
		let authStatus = locationManager.authorizationStatus
		
		if authStatus == .notDetermined {
			// Ask permission for location if first time
			locationManager.requestWhenInUseAuthorization()
			return
		}
		
		if authStatus == .denied || authStatus == .restricted {
			// Alert that app needs location to work
			showLocationServicesDeniedAlert()
			return
		}
		
		// Animate logo if first load
		if logoVisible {
			hideLogoView()
		}
		
		// Toggle [Get My Location] and [Stop]
		if updatingLocation {
			stopLocationManager()
		} else {
			// Reset previous results
			location = nil
			lastLocationError = nil
			lastGeocodingError = nil
			startLocationManager()
		}
		
		updateLabels()
	}
	
	// MARK: - Location Manager
	func startLocationManager() {
//		if CLLocationManager.locationServicesEnabled() {
		
			// Configure location manager
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
			updatingLocation = true
			
			// Timeout if longer than 30 secs (doesn't depend on CLErrors)
			timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
//		}
	}
	
	func stopLocationManager() {
		if updatingLocation {
			locationManager.stopUpdatingLocation()
			locationManager.delegate = nil
			updatingLocation = false
			
			// Reset timer if set
			if let timer = timer {
				timer.invalidate()
			}
		}
	}
	
	// MARK: - CLLocationManagerDelegate
	
	// Location search failed with error
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		
		// If location is undefinable by CL continue until timer runs out
		if (error as NSError).code == CLError.locationUnknown.rawValue {
			return
		}
		
		lastLocationError = error
		stopLocationManager()
		updateLabels()
	}
	
	// On update location
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		// Get new location from updated locations
		let newLocation = locations.last!
		
		// Don't execute if locations didn't changed in last 5 secs
		if newLocation.timestamp.timeIntervalSinceNow < -5 {
			return
		}
		
		// If location is invalid (less than zero), skip execution
		if newLocation.horizontalAccuracy < 0 {
			return
		}
		
		// Max possible distance for initial run
		var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
		
		// Distance from previous location (or inf in the beginning)
		if let location = location {
			distance = newLocation.distance(from: location)
		}
		
		// First fetched location or new location is more accurate than last
		if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
			
			// Last location becomes current
			location = newLocation
			lastLocationError = nil
			
			// If current location is accurate enough — end
			if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {

				stopLocationManager()
				
				// If current location differs from last (distance),
				// force retask geocoder with current location
				if distance > 0 {
					performingReverseGeocoding = false
				}
			}
			
			// Perform geocoding if coder is available
			if !performingReverseGeocoding {
				
				performingReverseGeocoding = true
				
				geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
					
					self.lastGeocodingError = error
					
					// No errors, places found and array is not empty
					if error == nil, let places = placemarks, !places.isEmpty {
						
						// Play sound if found placemark
						if self.placemark == nil {
							self.playSoundEffect()
						}
						
						// Choose last placemark as in majority of cases it is
						// the only one or most accurate
						self.placemark = places.last!
						
					} else {
						
						// No placemark found
						self.placemark = nil
					}
					
					self.performingReverseGeocoding = false
					self.updateLabels()
				}
			}
			
			updateLabels()
			
		// If locations differ for less than one meter without improvement
		// in accuracy and measurement
		} else if distance < 1 {
			
			let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
			
			// If 10 seconds spent after last improving update — stop
			if timeInterval > 10 {
				stopLocationManager()
				updateLabels()
			}
		}
	}
	
	// MARK: - Helper Methods
	
	/// Pop-up alert if location services are diabled or restricted
	func showLocationServicesDeniedAlert() {
		let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		
		alert.addAction(okAction)
		
		present(alert, animated: true, completion: nil)
	}
	
	func updateLabels() {
		if let location = location {
			latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
			longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
			
			latitudeTextLabel.isHidden = false
			longitudeTextLabel.isHidden = false
			tagButton.isHidden = false
			messageLabel.text = " "
			
			// Placemark conditional fallthrough
			if let placemark = placemark {
				addressLabel.text = string(from: placemark)
			} else if performingReverseGeocoding {
				addressLabel.text = "Searching for address.."
			} else if lastGeocodingError != nil {
				addressLabel.text = "Error finding address"
			} else {
				addressLabel.text = "No address found"
			}
			
		} else {
			latitudeLabel.text = " "
			longitudeLabel.text = " "
			addressLabel.text = " "
			
			tagButton.isHidden = true
			latitudeTextLabel.isHidden = true
			longitudeTextLabel.isHidden = true
			
			let statusMessage: String
			
			if let error = lastLocationError as NSError? {
				// Check for CL Error domain
				if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
					statusMessage = "Location Services Disabled"
				} else {
					statusMessage = "Error Getting Location"
				}
			} else if !CLLocationManager.locationServicesEnabled() {
				statusMessage = "Location Services Disabled"
			} else if updatingLocation {
				statusMessage = "Searching..."
			} else {
				statusMessage = " "
				
				// First run, so show logo
				showLogoView()
			}
			
			messageLabel.text = statusMessage
		}
		
		configureGetButton()
	}
	
	
	func showLogoView() {
		if !logoVisible {
			logoVisible = true
			containerView.isHidden = true
			view.addSubview(logoButton)
		}
	}
	
	func configureGetButton() {
		
		// Add tag for spinner so it can be accesed lin both cases
		let spinnerTag = 1000
		
		if updatingLocation {
			getButton.setTitle("Stop", for: .normal)
			
			if view.viewWithTag(spinnerTag) == nil {
				// Create a spinner for message label
				let spinner = UIActivityIndicatorView(style: .medium)
				spinner.center = messageLabel.center
				spinner.center.y += spinner.bounds.size.height / 2 + 25
				spinner.startAnimating()
				spinner.tag = spinnerTag
				containerView.addSubview(spinner)
			}
		} else {
			getButton.setTitle("Get My Location", for: .normal)
			
			// If spinner exists remove it from container
			if let spinner = view.viewWithTag(spinnerTag) {
				spinner.removeFromSuperview()
			}
		}
	}
	
	// Configure address text from placemark
	func string(from placemark: CLPlacemark) -> String {
		var line = ""
		line.add(text: placemark.subThoroughfare)
		line.add(text: placemark.thoroughfare, separatedBy: " ")
		line.add(text: placemark.locality, separatedBy: "\n")
		line.add(text: placemark.administrativeArea, separatedBy: ", ")
		line.add(text: placemark.postalCode, separatedBy: " ")
		return line
	}
	
	// Can't access location for 30 seconds (from timer)
	@objc func didTimeOut() {
		if location == nil {
			stopLocationManager()
			lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
			updateLabels()
		}
	}
	
	// MARK: - View
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateLabels()
		loadSoundEffect("Sound.caf")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Hide navbar
		navigationController?.isNavigationBarHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// Show navbar before segue to another VC
		navigationController?.isNavigationBarHidden = false
	}
	
	// Transfer current data to Tag VC
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "TagLocation" {
			let controller = segue.destination as! LocationDetailsViewController
			controller.coordinate = location!.coordinate
			controller.placemark = placemark
			controller.managedObjectContext = managedObjectContext
		}
	}
	
	// MARK: - Sound Effects
	
	// Sound ID for "found" sound
	var soundID: SystemSoundID = 0
	
	// Loads sound from bundle and creates a system sound ID for it
	func loadSoundEffect(_ name: String) {
		if let path = Bundle.main.path(forResource: name, ofType: nil) {
			let fileURL = URL(fileURLWithPath: path, isDirectory: false)
			
			// Put system sound into soundID through pointer
			let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
			
			if error != kAudioServicesNoError {
//				print("Sound error \(error)")
			}
		}
	}
	
	// Releases soundID and memory from the sound
	func unloadSoundEffect() {
		AudioServicesDisposeSystemSoundID(soundID)
		soundID = 0
	}
	
	func playSoundEffect() {
		AudioServicesPlaySystemSound(soundID)
	}
}


// MARK: - Animations

extension CurrentLocationViewController: CAAnimationDelegate {
	func hideLogoView() {
		if !logoVisible { return }
		
		logoVisible = false
		containerView.isHidden = false
		containerView.center.x = view.bounds.size.width * 2
		containerView.center.y = 40 + containerView.bounds.size.height / 2
		
		let centerX = view.bounds.midX
		
		let panelMover = CABasicAnimation(keyPath: "position")
		panelMover.isRemovedOnCompletion = false
		panelMover.fillMode = CAMediaTimingFillMode.forwards
		panelMover.duration = 0.6
		panelMover.fromValue = NSValue(cgPoint: containerView.center)
		panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
		panelMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		panelMover.delegate = self
		containerView.layer.add(panelMover, forKey: "panelMover")
		
		let logoMover = CABasicAnimation(keyPath: "position")
		logoMover.isRemovedOnCompletion = false
		logoMover.fillMode = CAMediaTimingFillMode.forwards
		logoMover.duration = 0.5
		logoMover.fromValue = NSValue(cgPoint: logoButton.center)
		logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
		logoMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
		logoButton.layer.add(logoMover, forKey: "logoMover")
		
		let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
		logoRotator.isRemovedOnCompletion = false
		logoRotator.fillMode = CAMediaTimingFillMode.forwards
		logoRotator.duration = 0.5
		logoRotator.fromValue = 0.0
		logoRotator.toValue = -2 * Double.pi
		logoRotator.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
		logoButton.layer.add(logoRotator, forKey: "logoRotator")
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		containerView.layer.removeAllAnimations()
		containerView.center.x = view.bounds.size.width / 2
		containerView.center.y = 40 + containerView.bounds.size.height / 2
		logoButton.layer.removeAllAnimations()
		logoButton.removeFromSuperview()
	}
	
}
