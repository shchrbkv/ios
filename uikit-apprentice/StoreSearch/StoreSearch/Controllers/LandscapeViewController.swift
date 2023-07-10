//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Alex Scherbakov on 8/15/22.
//

import UIKit

class LandscapeViewController: UIViewController {
	
	var search: Search!
	private var firstTime = true
	private var downloads: [URLSessionDownloadTask] = []
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var pageControl: UIPageControl!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.removeConstraints(view.constraints)
		view.translatesAutoresizingMaskIntoConstraints = true
		
		scrollView.removeConstraints(scrollView.constraints)
		scrollView.translatesAutoresizingMaskIntoConstraints = true
		
		pageControl.removeConstraints(pageControl.constraints)
		pageControl.translatesAutoresizingMaskIntoConstraints = true
		
		view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
		
		pageControl.numberOfPages = 0
		
    }
    
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		let safeFrame = view.safeAreaLayoutGuide.layoutFrame
		scrollView.frame = safeFrame
		pageControl.frame = CGRect(
			x: safeFrame.origin.x,
			y: safeFrame.size.height - pageControl.frame.height,
			width: safeFrame.size.width,
			height: pageControl.frame.height)

		if firstTime {
			firstTime = false
			switch search.state {
			case .idle:
				break
			case .noResults:
				showNothingFoundLabel()
			case .loading:
				showSpinner()
			case .results(let results):
				tileButtons(results)
			}
		}
	}
	
	// MARK: - Helper Methods
	func searchResultsReceived() {
		hideSpinner()
		
		switch search.state {
		case .idle, .loading:
			break
		case .noResults:
			showNothingFoundLabel()
		case .results(let results):
			tileButtons(results)
		}
	}
	
	// MARK: - Actions
	
	@IBAction func pageChanged(_ sender: UIPageControl) {
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
			self.scrollView.contentOffset.x = self.scrollView.bounds.width * CGFloat(sender.currentPage)
		}, completion: nil)
	}
	
	// MARK: - Private Methods
	
	@objc private func buttonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "ShowDetail", sender: sender)
	}
	
	private func tileButtons(_ results: [SearchResult]) {
		
		let itemWidth: CGFloat = 94
		let itemHeight: CGFloat = 88
		var columnsPerPage = 0
		var rowsPerPage = 0
		var marginX: CGFloat = 0
		var marginY: CGFloat = 0
		let viewWidth = scrollView.bounds.width
		let viewHeight = scrollView.bounds.height
		
		columnsPerPage = Int(viewWidth / itemWidth)
		rowsPerPage = Int(viewHeight / itemHeight)
		
		marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
		marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
		
		let buttonWidth: CGFloat = 82
		let buttonHeight: CGFloat = 82
		let paddingH = (itemWidth - buttonWidth) / 2
		let paddingV = (itemHeight - buttonHeight) / 2
		
		var position = (column: 0, row: 0)
		var x = marginX
		var y = marginY

		for (index, result) in results.enumerated() {
			let button = UIButton(type: .custom)
			button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
			button.frame = CGRect(
				x: x + paddingH,
				y: y + paddingV,
				width: buttonWidth,
				height: buttonHeight)
			button.tag = 2000 + index
			button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
			downloadImage(for: result, andPlaceOn: button)
			scrollView.addSubview(button)

			position.row += 1
			y += itemHeight

			if position.row == rowsPerPage {
				position.row = 0
				position.column += 1
				x += itemWidth
				y = marginY
				
				if position.column == columnsPerPage {
					position.column = 0
					x += 2 * marginX
				}
			}
		}
		
		let buttonsPerPage = columnsPerPage * rowsPerPage
		let numPages = 1 + (results.count - 1) / buttonsPerPage

		scrollView.contentSize = CGSize(
			width: CGFloat(numPages) * viewWidth,
			height: scrollView.bounds.height)
		
		pageControl.numberOfPages = numPages
		pageControl.currentPage = 0
	}
	
	private func downloadImage(for result: SearchResult, andPlaceOn button: UIButton) {
		if let url = URL(string: result.imageSmall) {
			let task = URLSession.shared.downloadTask(with: url) {
				[weak button] url, _, error in
				if error == nil,
				   let url = url,
				   let data = try? Data(contentsOf: url),
				   let image = UIImage(data: data) {
					DispatchQueue.main.async {
						if let button = button {
							button.setImage(image, for: .normal)
						}
					}
				}
			}
			task.resume()
			downloads.append(task)
		}
	}
	
	private func showSpinner() {
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.center = CGPoint(
			x: scrollView.frame.midX + 0.5, // Large spinner is 37x37 pt, so
			y: scrollView.frame.midY + 0.5) // adding 0.5 evens it out
		spinner.tag = 1000
		view.addSubview(spinner)
		spinner.startAnimating()
	}
	
	private func hideSpinner() {
		view.viewWithTag(1000)?.removeFromSuperview()
	}
	
	private func showNothingFoundLabel() {
		let label = UILabel(frame: CGRect.zero)
		label.text = "Nothing found"
		label.textColor = .label
		label.backgroundColor = .clear
		
		label.sizeToFit()
		
		// Evenization
		var rect = label.frame
		rect.size.width = ceil(rect.width / 2) * 2
		rect.size.height = ceil(rect.height / 2) * 2
		label.frame = rect
		
		label.center = CGPoint(
			x: scrollView.frame.midX,
			y: scrollView.frame.midY)
		view.addSubview(label)
	}


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetail" {
			if case .results(let results) = search.state {
				let controller = segue.destination as! DetailViewController
				controller.result = results[(sender as! UIButton).tag - 2000]
			}
		}
    }

}

extension LandscapeViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let width = scrollView.bounds.width
		let page = Int((scrollView.contentOffset.x + width / 2) / width)
		pageControl.currentPage = page
	}
}
