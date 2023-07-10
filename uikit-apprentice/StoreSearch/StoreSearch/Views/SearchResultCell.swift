//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/13/22.
//

import UIKit

class SearchResultCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var artworkImageView: UIImageView!
	
	var downloadTask: URLSessionDownloadTask?
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		let selectedView = UIView(frame: CGRect.zero)
		selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
		selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		downloadTask?.cancel()
		downloadTask = nil
	}
	
	// MARK: - Helper Methods
	
	func configure(for result: SearchResult) {
		nameLabel.text = result.name
		
		artistNameLabel.text = result.artist.isEmpty ? "Unknown" : "\(result.artist) · \(result.type)"
		
		artworkImageView.image = UIImage(systemName: "questionmark.square")
		if let smallURL = URL(string: result.imageSmall) {
			downloadTask = artworkImageView.loadImage(url: smallURL)
		}
	}


}
