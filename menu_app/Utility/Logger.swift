//
//  Logger.swift
//  menu_app
//
//  Created by Захар Литвинчук on 20.01.2026.
//

import Foundation

enum Logger {
	enum LogLevel {
		case info, token, warning, error(Error? = nil)
		fileprivate var prefix: String {
			switch self {
			case .info: return "INFO ℹ️"
			case .token: return "Token 🔑"
			case .warning: return "WARN ⚠️"
			case .error: return "ERROR ❌"
			}
		}
	}

	struct Context {
		let file: String
		let function: String
		let line: Int
		var description: String {
			let fileName = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
			return "\(fileName).\(function):\(line)"
		}
	}

	static func log(
		level: LogLevel,
		_ str: String,
		shouldLogContext: Bool = true,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		#if DEBUG
		let context = Context(file: file, function: function, line: line)
		handleLog(
			level: level, str: str.description,
			shouldLogContext: shouldLogContext, context: context)
		#endif
	}

	fileprivate static func handleLog(
		level: LogLevel, str: String, shouldLogContext: Bool, context: Context
	) {
		#if DEBUG
		var messageParts = [String]()
		
		messageParts.append("[\(level.prefix)]")
		
		if shouldLogContext {
			messageParts.append("[\(context.description)]")
		}
		
		messageParts.append(str)
		
		var logMessage = messageParts.joined(separator: " ")

		if shouldLogContext, case .error(let error) = level, let unwrappedError = error {
			logMessage += " // Error: \(unwrappedError.localizedDescription)"
		}
		
		print(logMessage)
		#endif
	}
}
