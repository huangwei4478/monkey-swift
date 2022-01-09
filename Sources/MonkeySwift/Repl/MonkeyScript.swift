//
//  MonkeyScript.swift
//  MonkeySwift
//
//  Created by huangwei on 2022/1/9.
//

import Foundation

struct MonkeyScript {
	static func runScript(scriptPath: String) {
		guard let script = try? String(contentsOfFile: scriptPath, encoding: .utf8) else {
			printParserErrors(errors: ["failed to open file \(scriptPath)"])
			return
		}
		
		let lexer = Lexer(input: script)
		let parser = Parser(lexer: lexer)
		
		let optionalProgram = parser.parseProgram()
		if !parser.Errors().isEmpty {
			printParserErrors(errors: parser.Errors())
			return
		}
		
		guard let program = optionalProgram else {
			printParserErrors(errors: ["Ast.Program is nil"])
			return
		}
		guard let evaluated = Evaluator.eval(program, Environment()) else {
			printParserErrors(errors: ["Ast.Program eval failed"])
			return
		}
		
		ConsoleIO.shared.writeMessage(evaluated.inspect())
		ConsoleIO.shared.writeMessage("\n")
	}
	
	private static func printParserErrors(errors: [String]) {
		for message in errors {
			ConsoleIO.shared.writeMessage(message)
		}
	}
}
