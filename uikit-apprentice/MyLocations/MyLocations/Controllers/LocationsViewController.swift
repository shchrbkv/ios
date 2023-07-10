//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Alex Scherbakov on 8/5/22.
//

import UIKit
import CoreData

class LocationsViewController: UITableViewController {
	
	var managedObjectContext: NSManagedObjectContext!
	
	// Lazy init preconfig for controller of fetch results
	lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
		
		// Fetch request for location
		let fetchRequest = NSFetchRequest<Location>()
		
		// Using Location as base type (entity) for results
		let entity = Location.entity()
		fetchRequest.entity = entity
		
		// Sorting options for fetch request
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(key: "category", ascending: true),
			NSSortDescriptor(key: "date", ascending: true)
		]
		
		fetchRequest.fetchBatchSize = 20
		
		// Init controller itself with current context and keypath for category
		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: self.managedObjectContext,
			sectionNameKeyPath: "category",
			cacheName: "Locations")
		
		fetchedResultsController.delegate = self
		return fetchedResultsController
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Fetch objects ans econfig edit button
        performFetch()
		navigationItem.rightBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

	// Using FRC to configure sections, their titles and cells
    override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections!.count
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return fetchedResultsController.sections![section].name
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
		
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
		
		let location = fetchedResultsController.object(at: indexPath)
		cell.configure(for: location)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			
			let location = fetchedResultsController.object(at: indexPath)
			
			// Removing photo file from Documents upon deletion
			location.removePhotoFile()
			managedObjectContext.delete(location)
			
			do {
				try managedObjectContext.save()
			} catch {
				fatalCoreDataError(error)
			}
			
        }
    }
	
	
	// MARK: - Helper Methods
	
	// Perform fetch on FRC
	func performFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalCoreDataError(error)
		}
	}

    
	// MARK: - Navigation
	
	// Prepare for editing with object from FRC
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditLocation" {
			let controller = segue.destination as! LocationDetailsViewController
			
			controller.managedObjectContext = managedObjectContext
			
			if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
				let location = fetchedResultsController.object(at: indexPath)
				controller.locationToEdit = location
			}
		}
	}
	
	// Remove delegate from FRC to stop getting notifications (though it works
	// fine without it) as controller's delegate is unowned
	deinit {
		fetchedResultsController.delegate = nil
	}
}

// MARK: - FRC Delegate Methods

extension LocationsViewController: NSFetchedResultsControllerDelegate {
	
	// Starts CRUD opeartions sequence on tableView
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	// Handle cells updates
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange anObject: Any,
		at indexPath: IndexPath?,
		for type: NSFetchedResultsChangeType,
		newIndexPath: IndexPath?
	) {
		// Switch based on FRC change type
		switch type {
			
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .fade)
			
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .fade)
			
		case .update:
			if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
				let location = controller.object(at: indexPath!) as! Location
				cell.configure(for: location)
			}
			
		case .move:
			tableView.deleteRows(at: [indexPath!], with: .fade)
			tableView.insertRows(at: [newIndexPath!], with: .fade)
			
		@unknown default:
			return
		}
	}
	
	// Handle section updates
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		
		switch type {
		
		// Use IndexSet for insert/delete ops as it is more optimized than Int
		case .insert:
			tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
			
		case .delete:
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
			
		case .update:
			return
			
		case .move:
			return
			
		@unknown default:
			return
		}
	}
	
	// Close commit session after FRC fetch
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}
