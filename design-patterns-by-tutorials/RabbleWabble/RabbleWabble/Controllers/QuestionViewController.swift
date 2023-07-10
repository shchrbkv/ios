//
//  ViewController.swift
//  RabbleWabble
//
//  Created by Alex Scherbakov on 8/21/22.
//

import UIKit

public protocol QuestionViewControllerDelegate: AnyObject {
	
	func questionViewController(
	_ viewController: QuestionViewController,
	didCancel questionGroup: QuestionStrategy,
	at questionIndex: Int)
	
	func questionViewController(
	_ viewController: QuestionViewController,
	didComplete questionGroup: QuestionStrategy
	)
	
}

public class QuestionViewController: UIViewController {
	
	public weak var delegate: QuestionViewControllerDelegate?
	
	public var questionStrategy: QuestionStrategy! {
		didSet {
			navigationItem.title = questionStrategy.title
		}
	}
	
	public var questionIndex = 0
	
	public var correctCount = 0
	public var incorrectCount = 0
	
	public var questionView: QuestionView! {
		guard isViewLoaded else { return nil }
		return (view as! QuestionView)
	}
	
	private lazy var questionIndexItem: UIBarButtonItem = {
		let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		item.tintColor = .black
		navigationItem.rightBarButtonItem = item
		return item
	}()

	override public func viewDidLoad() {
		super.viewDidLoad()
		setupCancelButton()
		showQuestion()
	}
	
	private func setupCancelButton() {
		let image = UIImage(named: "ic_menu")
		let button = UIBarButtonItem(
			image: image,
			landscapeImagePhone: nil,
			style: .plain,
			target: self,
			action: #selector(handleCancelPressed(sender:))
		)
		navigationItem.leftBarButtonItem = button
	}
	
	@objc private func handleCancelPressed(sender: UIBarButtonItem) {
		delegate?.questionViewController(
			self,
			didCancel: questionStrategy,
			at: questionIndex
		)
	}
	
	private func showQuestion() {
		let question = questionStrategy.currentQuestion
		
		questionView.answerLabel.text = question.answer
		questionView.promptLabel.text = question.prompt
		questionView.hintLabel.text = question.hint
		
		questionView.answerLabel.isHidden = true
		questionView.hintLabel.isHidden = true
		
		questionIndexItem.title = questionStrategy.questionIndexTitle
	}
	
	// MARK: Actions
	@IBAction func toggleAnswerLabels(_ sender: Any) {
		questionView.answerLabel.isHidden.toggle()
		questionView.hintLabel.isHidden.toggle()
	}
	
	@IBAction func handleCorrect(_ sender: Any) {
		let question = questionStrategy.currentQuestion
		questionStrategy.markQuestionCorrect(question)
		
		questionView.correctCountLabel.text = String(questionStrategy.correctCount)
		showNextQuestion()
	}
	
	@IBAction func handleIncorrect(_ sender: Any) {
		let question = questionStrategy.currentQuestion
		questionStrategy.markQuestionIncorrect(question)
		
		questionView.correctCountLabel.text = String(questionStrategy.incorrectCount)
		showNextQuestion()
	}
	
	private func showNextQuestion() {
		questionIndex += 1
		guard questionStrategy.advanceToNextQuestion() else {
			delegate?.questionViewController(
				self,
				didComplete: questionStrategy
			)
			return
		}
		showQuestion()
	}
}

