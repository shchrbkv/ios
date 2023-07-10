/// Copyright (c) 2020 Razeware LLC
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

import UIKit

class CAEmitterLayerViewController: UIViewController {
  @IBOutlet weak var viewForEmitterLayer: UIView!

  @objc var emitterLayer = CAEmitterLayer()
  @objc var emitterCell = CAEmitterCell()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setUpEmitterCell()
    setUpEmitterLayer()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "DisplayEmitterControls" {
      (segue.destination as? CAEmitterLayerControlsViewController)?.emitterLayerViewController = self
    }
  }
}

// MARK: - Layer setup
extension CAEmitterLayerViewController {
  func setUpEmitterLayer() {
		resetEmitterCells()
		emitterLayer.frame = viewForEmitterLayer.bounds
		viewForEmitterLayer.layer.addSublayer(emitterLayer)
		
		emitterLayer.seed = UInt32(Date().timeIntervalSince1970)
		
		emitterLayer.emitterPosition = CGPoint(
			x: viewForEmitterLayer.bounds.midX * 1.5,
			y: viewForEmitterLayer.bounds.midY)
		
		emitterLayer.renderMode = .additive
  }

  func setUpEmitterCell() {
		// 1
		emitterCell.contents = UIImage(named: "smallStar")?.cgImage
				
		// 2
		emitterCell.velocity = 50.0
		emitterCell.velocityRange = 500.0
				
		// 3
		emitterCell.color = UIColor.black.cgColor

		// 4
		emitterCell.redRange = 1.0
		emitterCell.greenRange = 1.0
		emitterCell.blueRange = 1.0
		emitterCell.alphaRange = 0.0
		emitterCell.redSpeed = 0.0
		emitterCell.greenSpeed = 0.0
		emitterCell.blueSpeed = 0.0
		emitterCell.alphaSpeed = -0.5
		emitterCell.scaleSpeed = 0.1
				
		// 5
		let zeroDegreesInRadians = degreesToRadians(0.0)
		emitterCell.spin = degreesToRadians(130.0)
		emitterCell.spinRange = zeroDegreesInRadians
		emitterCell.emissionLatitude = zeroDegreesInRadians
		emitterCell.emissionLongitude = zeroDegreesInRadians
		emitterCell.emissionRange = degreesToRadians(360.0)
				
		// 6
		emitterCell.lifetime = 1.0
		emitterCell.birthRate = 250.0

		// 7
		emitterCell.xAcceleration = -800
		emitterCell.yAcceleration = 1000

  }

  func resetEmitterCells() {
    emitterLayer.emitterCells = nil
    emitterLayer.emitterCells = [emitterCell]
  }
}

// MARK: - Triggered actions
extension CAEmitterLayerViewController {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: viewForEmitterLayer) {
      emitterLayer.emitterPosition = location
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: viewForEmitterLayer) {
      emitterLayer.emitterPosition = location
    }
  }
}
