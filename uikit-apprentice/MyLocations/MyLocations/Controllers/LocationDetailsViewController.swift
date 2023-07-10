//
//  TaglocationViewController.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/4/22.
//

import UIKit
import CoreLocation
import CoreData
import PhotosUI

// Global (lazy) init with configuration for date formatter
private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .medium
	formatter.timeStyle = .short
	return formatter
}()

class LocationDetailsViewController: UITableViewController {
	
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var categoryLabel: UILabel!
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var addPhotoLabel: UILabel!
	@IBOutlet var imageHeight: NSLayoutConstraint!
	
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	// Observer for entering background state
	var observer: Any!
	
	var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	var placemark: CLPlacemark?
	var category = "No Category"
	
	// Image handler that performs aspect-fill cropping and UIView configuration
	var image: UIImage? {
		didSet {
			if let image = image {
				imageView.image = image
				imageView.isHidden = false
				
				let imageAspect = image.size.height / image.size.width
				
				imageHeight.constant = floor(imageAspect * imageView.bounds.width)
				tableView.reloadData()
				
				addPhotoLabel.text = ""
			}
		}
	}
	
	var date = Date()
	
	var managedObjectContext: NSManagedObjectContext!
	
	// Prepare data properties after setting location to use in viewDidLoad
	var locationToEdit: Location? {
		didSet {
			if let location = locationToEdit {
				descriptionText = location.locationDescription
				category = location.category
				date = location.date
				coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
				placemark = location.placemark
			}
		}
	}
	var descriptionText = ""
	
	// MARK: - Navigation Actions
	
	@IBAction func done() {
		
		// Getting current wrapper navigation VC
		guard let mainView = navigationController?.parent?.view else {return}
		
		let hudView = HudView(inView: mainView, animated: true)
		
		let location: Location
		
		if let tmp = locationToEdit {
			hudView.text = "Updated"
			location = tmp
		} else {
			hudView.text = "Tagged"
			// Init CD object for location
			location = Location(context: managedObjectContext)
		}
		
		location.locationDescription = descriptionTextView.text
		location.category = category
		location.latitude = coordinate.latitude
		location.longitude = coordinate.longitude
		location.date = date
		location.placemark = placemark
		
		if let image = image {
			
			// Fetch next photo ID from User Defaults
			if !location.hasPhoto {
				location.photoID = Location.nextPhotoID() as NSNumber
			}
			
			// Save photo
			if let data = image.jpegData(compressionQuality: 0.5) {
				do {
					try data.write(to: location.photoURL, options: .atomic)
				} catch {
					print("Error saving file: \(error)")
				}
			}
		}
		
		// Save context and hide HUD after delay
		do {
			try managedObjectContext.save()
			afterDelay(0.6) {
				hudView.hide()
				self.navigationController?.popViewController(animated: true)
			}
		} catch {
			// Handle failed save with sigterm
			fatalCoreDataError(error)
		}
		
	}
	
	@IBAction func cancel() {
		navigationController?.popViewController(animated: true)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let location = locationToEdit {
			title = "Edit Location"
			if location.hasPhoto {
				if let theImage = location.photoImage {
					image = theImage
				}
			}
		}

		descriptionTextView.text = descriptionText
		categoryLabel.text = ""

		latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
		longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
		

		if let placemark = placemark {
			addressLabel.text = string(from: placemark)
		} else {
			addressLabel.text = "No address found"
		}

		dateLabel.text = dateFormatter.string(from: date)
		
		// Tap gesture recognizer for tapping outside keyboard and active field
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		// Don't prevent touches to happen if gesture is recognized
		gestureRecognizer.cancelsTouchesInView = false
		tableView.addGestureRecognizer(gestureRecognizer)
		
		listenForBackgroundNotification()
    }
	
	// Since iOS 15 footer and header became huge, so we counter that
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.0
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		
		// Enable interaction only for first two sections
		if indexPath.section == 0 || indexPath.section == 1 {
			return indexPath
		}
		
		return nil
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// If selected description field's cell — respond to field
		if indexPath.section == 0, indexPath.row == 0 {
			descriptionTextView.becomeFirstResponder()
		} else if indexPath.section == 1, indexPath.row == 0 {
			tableView.deselectRow(at: indexPath, animated: true)
			pickPhoto()
		}
	}

	// MARK: - Helper Methods
	
	func string(from placemark: CLPlacemark) -> String {
		var line = ""
		line.add(text: placemark.subThoroughfare)
		line.add(text: placemark.thoroughfare, separatedBy: " ")
		line.add(text: placemark.locality, separatedBy: ", ")
		line.add(text: placemark.administrativeArea, separatedBy: ", ")
		line.add(text: placemark.postalCode, separatedBy: " ")
		line.add(text: placemark.country, separatedBy: ", ")
		return line
	}
	
	// Action to hide keyboard called by gesture recognizer
	@objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
		
		// Point tapped and row for this point
		let point = gestureRecognizer.location(in: tableView)
		let indexPath = tableView.indexPathForRow(at: point)
		
		// If cell tapped, but it is a description filed cell — exit
		if indexPath != nil, indexPath!.section == 0, indexPath!.row == 0 {
			return
		}
		
		// Deactivate keyboard
		descriptionTextView.resignFirstResponder()
	}
	
    // MARK: - Navigation

	// Unwind segue action for retrieving category name
	@IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
		let controller = segue.source as! CategoryPickerViewController
		category = controller.selectedCategoryName
		categoryLabel.text = category
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PickCategory" {
			let controller = segue.destination as! CategoryPickerViewController
			controller.selectedCategoryName = category
		}
    }
	
	// Function that listens for app going into background mode
	func listenForBackgroundNotification() {
		observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
			
			// Unwrap self from weak state
			guard let self = self else { return }
			
			// If this view is presented — exit on background for UX purposes
			if self.presentationController != nil {
				self.dismiss(animated: false)
			}
			
			// Hide keyboard if opened
			self.descriptionTextView.resignFirstResponder()
		}
	}
	
	// Clear observer to avoid reatin cycle
	deinit {
		NotificationCenter.default.removeObserver(observer!)
	}

}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
	
	// MARK: - Image Helper Methods
	
	// Use image picker API to take a photo
	func takePhotoWithCamera() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
	
	// Use PHPicker API with conf for images to get a photo from library
	func choosePhotoFromLibrary() {
		var configuration = PHPickerConfiguration()
		configuration.filter = .images
		
		let imagePicker = PHPickerViewController(configuration: configuration)
		imagePicker.delegate = self
		present(imagePicker, animated: true)
	}
	
	// Pick way to get photo (camera + library vs only library)
	func pickPhoto() {
		if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
			showPhotoMenu()
		} else {
			choosePhotoFromLibrary()
		}
	}
	
	// Action sheet alert to choose photo action: camera / library / cancel
	func showPhotoMenu() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let actCancel = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(actCancel)
		
		let actPhoto = UIAlertAction(title: "Take Photo", style: .default) { _ in
			self.takePhotoWithCamera()
		}
		alert.addAction(actPhoto)
		
		let actLibrary = UIAlertAction(title: "Choose From Library", style: .default) { _ in
			self.choosePhotoFromLibrary()
		}
		alert.addAction(actLibrary)
		
		present(alert, animated: true)
	}
	
	
	// MARK: - Image Picker Delegates
	
	// Delegate for image picker controller
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		// Dismiss image picker view
		dismiss(animated: true)
		
		// Retireve image from dictionary
		image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
		if let theImage = image {
			image = theImage
		}
	}
	
	// Image picker cancel
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true)
	}
	
	// PHPicker delegate
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		dismiss(animated: true)
		
		// Check for image's item provider and its ability to load UIImages
		if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
			
			// Hold previously selected (current) image for closure
			let previousImage = imageView.image
			
			itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
				// Getting the image asyncly and setting view's image
				DispatchQueue.main.async {
					guard let self = self, let theImage = image as? UIImage, self.imageView.image == previousImage else { return }
					
					self.image = theImage
				}
			}
		}
	}
	
}
