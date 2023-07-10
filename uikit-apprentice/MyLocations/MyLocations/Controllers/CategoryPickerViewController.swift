//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/4/22.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
	
	let categories = [
		"No Category",
		"Apple Store",
		"Bar",
		"Bookstore",
		"Club",
		"Grocery Store",
		"Historic Building",
		"House",
		"Icecream Vendor",
		"Landmark",
		"Park"
	]
	
	// Selected category and index for edit
	var selectedCategoryName = ""
	var selectedIndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Finding a path for category provided by parent VC
		let selectedCategoryIndex = categories.firstIndex(of: selectedCategoryName)!
		selectedIndexPath = IndexPath(row: selectedCategoryIndex, section: 0)
    }

    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		categories.count
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let categoryName = categories[indexPath.row]
		cell.textLabel!.text = categoryName
		
		cell.accessoryType = categoryName == selectedCategoryName ? .checkmark : .none

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row != selectedIndexPath.row {
			if let newCell = tableView.cellForRow(at: indexPath) {
				newCell.accessoryType = .checkmark
			}
			if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
				oldCell.accessoryType = .none
			}
			selectedIndexPath = indexPath
		}
	}

    
    // MARK: - Navigation

	// Unwind segue for picked category with selected category name
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PickedCategory" {
			let cell = sender as! UITableViewCell
			if let indexPath = tableView.indexPath(for: cell) {
				selectedCategoryName = categories[indexPath.row]
			}
		}
    }

}
