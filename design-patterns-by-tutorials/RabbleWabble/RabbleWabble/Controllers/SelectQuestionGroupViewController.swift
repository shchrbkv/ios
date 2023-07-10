//
//  SelectQuestionGroupViewController.swift
//  RabbleWabble
//
//  Created by Alex Scherbakov on 8/22/22.
//

import UIKit

public class SelectQuestionGroupViewController: UIViewController {
	
	// MARK: - Outlets
	@IBOutlet internal var tableView: UITableView! {
		didSet {
			tableView.tableFooterView = UIView()
		}
	}
	
	
	// MARK: - Properties
	
	private var questionGroupCaretaker = QuestionGroupCaretaker()
	public var questionGroups: [QuestionGroup] {
		questionGroupCaretaker.questionGroups
	}
	private var selectedQuestionGroup: QuestionGroup! {
		get { questionGroupCaretaker.selectedQuestionGroup}
		set { questionGroupCaretaker.selectedQuestionGroup = newValue}
	}
	public var appSettings = AppSettings.shared
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		questionGroups.forEach {
			print("\($0.title): " +
				  "correctCount \($0.score.correctCount), " +
				  "incorrectCount \($0.score.incorrectCount)"
			)
		}
	}
	
}

extension SelectQuestionGroupViewController: QuestionViewControllerDelegate {
	
	public func questionViewController(_ viewController: QuestionViewController, didCancel questionGroup: QuestionStrategy, at questionIndex: Int) {
		navigationController?.popToViewController(self, animated: true)
	}
	
	public func questionViewController(_ viewController: QuestionViewController, didComplete questionGroup: QuestionStrategy) {
		navigationController?.popToViewController(self, animated: true)
	}
	
}

extension SelectQuestionGroupViewController: UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return questionGroups.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionGroupCell") as! QuestionGroupCell
		let questionGroup = questionGroups[indexPath.row]
		cell.titleLabel.text = questionGroup.title
		cell.percentageSubscriber = questionGroup.score.$runningPercentage
			.receive(on: DispatchQueue.main)
			.map { "\(Int(100 * $0))%"}
			.assign(to: \.text, on: cell.percentageLabel)
		return cell
	}
	
}

extension SelectQuestionGroupViewController: UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		selectedQuestionGroup = questionGroups[indexPath.row]
		return indexPath
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let controller = segue.destination as? QuestionViewController {
			
			controller.questionStrategy = appSettings.questionStrategy(for: questionGroupCaretaker)
			controller.delegate = self
			return
			
		}
		
		if let navController = segue.destination as? UINavigationController,
		   let controller = navController.topViewController as? CreateQuestionGroupViewController {
			
			controller.delegate = self
			return
			
		}
	}
	
}

extension SelectQuestionGroupViewController: CreateQuestionGroupViewControllerDelegate {
	
	public func createQuestionGroupViewController(_ viewController: CreateQuestionGroupViewController, created questionGroup: QuestionGroup) {
		
		questionGroupCaretaker.questionGroups.append(questionGroup)
		try? questionGroupCaretaker.save()
		
		dismiss(animated: true)
		tableView.reloadData()
		
	}
	
	public func createQuestionGroupViewControllerDidCancel(_ viewController: CreateQuestionGroupViewController) {
		dismiss(animated: true)
	}
	
}
