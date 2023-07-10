//
//  QuestionStrategy.swift
//  RabbleWabble
//
//  Created by Alex Scherbakov on 8/23/22.
//

public protocol QuestionStrategy: AnyObject {
	
	var title: String { get }
	
	var correctCount: Int { get }
	var incorrectCount: Int { get }
	
	var currentQuestion: Question { get }
	var questionIndexTitle: String { get }
	
	func advanceToNextQuestion() -> Bool
	
	func markQuestionCorrect(_ question: Question)
	func markQuestionIncorrect(_ question: Question)
	
}
