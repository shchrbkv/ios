//
//  LocationCell.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/5/22.
//

import UIKit

class LocationCell: UITableViewCell {
	
	@IBOutlet var photoImageView: UIImageView!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		// Circle images and offset for separators
		photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
		photoImageView.clipsToBounds = true
		separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }
	
	// Support default select action
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	// UIImage resized for thumbnail
	func thumbnail(for location: Location) -> UIImage {
		if location.hasPhoto, let image = location.photoImage {
			return image.resized(withBounds: CGSize(width: 52, height: 52))
		}
		return UIImage(named: "No Photo")!
	}
	
	// Configure cell for location
	func configure(for location: Location) {
		
		if !location.locationDescription.isEmpty {
			descriptionLabel.text = location.locationDescription
		} else {
			descriptionLabel.text = "(No Description)"
		}
		
		if let placemark = location.placemark {
			var text = ""
			text.add(text: placemark.subThoroughfare)
			text.add(text: placemark.thoroughfare, separatedBy: " ")
			text.add(text: placemark.locality, separatedBy: ", ")
			addressLabel.text = text
		} else {
			addressLabel.text = String(
				format: "Lat: %.8f, Long: %.8f",
				location.latitude,
				location.longitude)
		}
		
		photoImageView.image = thumbnail(for: location)
	}
}
