//
//  BaseQuestionStrategy.swift
//  RabbleWabble
//
//  Created by Alex Scherbakov on 8/23/22.
//

public class BaseQuestionStrategy: QuestionStrategy {
	
	// MARK: - Properties
	
	public var correctCount: Int {
		get { return questionGroup.score.correctCount }
		set { questionGroup.score.correctCount = newValue }
	}
	public var incorrectCount: Int {
		get { return questionGroup.score.incorrectCount }
		set { questionGroup.score.incorrectCount = newValue }
	}
	private var questionGroupCaretaker: QuestionGroupCaretaker
	
	private var questionGroup: QuestionGroup {
		return questionGroupCaretaker.selectedQuestionGroup
	}
	private var questionIndex = 0
	private let questions: [Question]
	
	// MARK: - Object Lifecycle
	
	public init(questionGroupCaretaker: QuestionGroupCaretaker,
				questions: [Question]) {
		self.questionGroupCaretaker = questionGroupCaretaker
		self.questions = questions
		
		// 4
		self.questionGroupCaretaker.selectedQuestionGroup.score.reset()
	}
	
	// MARK: - QuestionStrategy
	
	public var title: String {
		return questionGroup.title
	}
	
	public var currentQuestion: Question {
		questions[questionIndex]
	}
	public var questionIndexTitle: String {
		return "\(questionIndex + 1)/" + "\(questions.count)"
	}
	
	public func advanceToNextQuestion() -> Bool {
		try? questionGroupCaretaker.save()
		guard questionIndex + 1 < questions.count else {
			return false
		}
		questionIndex += 1
		return true
	}
	
	public func markQuestionCorrect(_ question: Question) {
		correctCount += 1
	}
	
	public func markQuestionIncorrect(_ question: Question) {
		incorrectCount += 1
	}
}
