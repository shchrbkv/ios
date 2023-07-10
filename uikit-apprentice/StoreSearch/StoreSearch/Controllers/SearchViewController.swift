//
//  ViewController.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/13/22.
//

import UIKit

class SearchViewController: UIViewController {
	
	private let search = Search()

	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	
	var landscapeVC: LandscapeViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		tableView.contentInset = UIEdgeInsets(top: 91, left: 0, bottom: 0, right: 0)
		
		let searchResultCellNib = UINib(nibName: "SearchResultCell", bundle: nil)
		tableView.register(searchResultCellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
		
		let nothingFoundCellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
		tableView.register(nothingFoundCellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
		
		let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
		tableView.register(loadingCellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
		
		searchBar.becomeFirstResponder()
	}
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		
		super.willTransition(to: newCollection, with: coordinator)
		
		switch newCollection.verticalSizeClass{
		case .compact:
			showLandscape(with: coordinator)
		case .regular, .unspecified:
			hideLandscape(with: coordinator)
		@unknown default:
			break
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ShowDetail" {
			if case let .results(results) = search.state {
				let controller = segue.destination as! DetailViewController
				controller.modalPresentationStyle = .overFullScreen
				let indexPath = sender as! IndexPath
				controller.result = results[indexPath.row]
			}
		}
		
	}
	
	// MARK: - Helper Methods
	
	func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
		
		guard landscapeVC == nil else { return }
		
		landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
		
		if let controller = landscapeVC {
			controller.search = search
			
			// Accesing view triggers viewDidLoad
			controller.view.frame = view.bounds
			controller.view.alpha = 0
			
			searchBar.resignFirstResponder()
			if presentedViewController != nil {
				dismiss(animated: true)
			}
			
			view.addSubview(controller.view)
			addChild(controller)
			
			coordinator.animate(
				alongsideTransition: { _ in
					controller.view.alpha = 1
				},
				completion: { _ in
					controller.didMove(toParent: self)
				})
			
		}
		
	}
	
	func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
		if let controller = landscapeVC {
			controller.willMove(toParent: nil)
			if self.presentedViewController != nil { dismiss(animated: true) }
			coordinator.animate(
				alongsideTransition: { _ in
					controller.view.alpha = 0
				},
				completion: { _ in
					controller.view.removeFromSuperview()
					controller.removeFromParent()
					self.landscapeVC = nil
				})
		}
	}
	
	func showNetworkError() {
		let alert = UIAlertController(title: "Network Error", message: "There was a problem accessing iTunes Store. Please try again.", preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default)
		alert.addAction(action)
		present(alert, animated: true)
	}
	
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		performSearch()
	}
	
	// MARK: - Constants
	
	enum TableView {
		enum CellIdentifiers {
			static let searchResultCell = "SearchResultCell"
			static let nothingFoundCell = "NothingFoundCell"
			static let loadingCell = "LoadingCell"
		}
	}
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		performSearch()
	}
	
	func performSearch() {
		
		guard let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) else { return }
		
		search.performSearch(
			for: searchBar.text!,
			category: category
		) { success in
			if !success {
				self.showNetworkError()
			}
			self.tableView.reloadData()
			self.landscapeVC?.searchResultsReceived()
		}
		
		tableView.reloadData()
		searchBar.resignFirstResponder()
	}
	
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch search.state {
			
		case .idle:
			fatalError("Should never get here")
			
		case .loading:
			let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
			let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
			spinner.startAnimating()
			return cell
			
		case .noResults:
			return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
			
		case .results(let results):
			let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
			
			let searchResult = results[indexPath.row]
			cell.configure(for: searchResult)
			
			return cell
		}
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch search.state {
		case .idle: return 0
		case .loading: return 1
		case .noResults: return 1
		case .results(let results): return results.count
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		performSegue(withIdentifier: "ShowDetail", sender: indexPath)
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		
		switch search.state {
		case .idle, .loading, .noResults:
			return nil
		case .results:
			return indexPath
		}
	}
}
