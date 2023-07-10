//
//  AppSettings.swift
//  RabbleWabble
//
//  Created by Alex Scherbakov on 8/23/22.
//

private enum Keys {
	static let questionStrategy = "questionStrategy"
}

import Foundation

public class AppSettings {
	
	public static let shared = AppSettings()
	

	// MARK: - User Defaults
	
	private let userDefaults = UserDefaults.standard
	
	public var questionStrategyType: QuestionStrategyType {
		get {
			let rawValue = userDefaults.integer(forKey: Keys.questionStrategy)
			return QuestionStrategyType(rawValue: rawValue)!
		}
		set {
			userDefaults.set(newValue.rawValue, forKey: Keys.questionStrategy)
		}
	}
	
	
	private init() {}
	
	
	// MARK: - Instance methods
	
	public func questionStrategy(for questionGroupCaretaker: QuestionGroupCaretaker) -> QuestionStrategy {
		questionStrategyType.questionStrategy(for: questionGroupCaretaker)
	}
}

public enum QuestionStrategyType: Int, CaseIterable {
	
	case random
	case sequential
	
	public var title: String {
		switch self {
		case .random: return "Random"
		case .sequential: return "Sequential"
		}
	}
	
	public func questionStrategy(for questionGroupCaretaker: QuestionGroupCaretaker) -> QuestionStrategy {
		switch self {
		case .random:
			return RandomQuestionStrategy(questionGroupCaretaker: questionGroupCaretaker)
		case .sequential:
			return SequentialQuestionStrategy(questionGroupCaretaker: questionGroupCaretaker)
		}
	}
}
