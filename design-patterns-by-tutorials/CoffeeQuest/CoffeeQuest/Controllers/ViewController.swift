/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MapKit
import YelpAPI

public class ViewController: UIViewController {
	
	// MARK: - Properties
	private var businesses: [Business] = []
	public let client: BusinessSearchClient = YLPClient(apiKey: YelpAPIKey)
	private let locationManager = CLLocationManager()
	public let annotationfactory = AnnotationFactory()
	private var filter = Filter.identity()
	
	// MARK: - Outlets
	@IBOutlet public var mapView: MKMapView! {
		didSet {
			mapView.showsUserLocation = true
		}
	}
	
	// MARK: - View Lifecycle
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.requestWhenInUseAuthorization()
	}
	
	// MARK: - Actions
	@IBAction func businessFilterToggleChanged(_ sender: UISwitch) {
		
		filter = sender.isOn ?
		Filter.starRating(atLeast: 4.0) :
		Filter.identity()
		
		filter.businesses = businesses
		
		addAnnotations()
	}
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
	
	public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		centerMap(on: userLocation.coordinate)
	}
	
	private func centerMap(on coordinate: CLLocationCoordinate2D) {
		let regionRadius: CLLocationDistance = 3000
		let coordinateRegion = MKCoordinateRegion(center: coordinate,
																							latitudinalMeters: regionRadius,
																							longitudinalMeters: regionRadius)
		mapView.setRegion(coordinateRegion, animated: true)
		searchForBusinesses()
	}
	
	private func searchForBusinesses() {
		let coordinate = mapView.userLocation.coordinate
		guard coordinate.latitude != 0,
					coordinate.longitude != 0 else {
			return
		}
		
		client.search(with: coordinate,
									term: "coffee",
									limit: 35,
									offset: 0,
									success: { [weak self] businesses in
			
			guard let self = self else { return }
			
			self.businesses = businesses
			self.filter.businesses = businesses
			
			DispatchQueue.main.async {
				self.addAnnotations()
			}
		}, failure: { error in
			print(error)
		})
		
	}
	
	private func addAnnotations() {
		
		mapView.removeAnnotations(mapView.annotations)
		
		for business in filter {
			let annotation = annotationfactory.createBusinessViewModel(for: business)
			mapView.addAnnotation(annotation)
		}
		
	}
	
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard let viewModel = annotation as? BusinessMapViewModel else { return nil }
		
		let identifier = "business"
		let annotationView: MKAnnotationView
		if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
			annotationView = existingView
		} else {
			annotationView = MKAnnotationView(annotation: viewModel, reuseIdentifier: identifier)
		}
		
		annotationView.image = viewModel.image
		annotationView.canShowCallout = true
		return annotationView
	}
	
}
