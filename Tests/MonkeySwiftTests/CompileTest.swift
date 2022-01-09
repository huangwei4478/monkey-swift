//
//  CompileTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/11/28.
//

import XCTest

class CompileTest: XCTestCase {

	struct TestCase {
		let input: String
		
		let expectedConstants: [Any]
		
		let expectedInstructions: [Instructions]
	}

	func testIntegerArithmetic() throws {
		let tests = [
			TestCase(input: "1 + 2",
					 expectedConstants: [1, 2],
					 expectedInstructions: [
						BytecodeTool.make(.constant, 0),
						BytecodeTool.make(.constant, 1)
					 ])
		]
		
		try runCompilerTest(tests: tests)
	}
	
	private func runCompilerTest(tests: [TestCase]) throws {
		for test in tests {
			let program = parse(input: test.input)
			
			let compiler = Compiler()
			
			try compiler.compile(node: program)
			
			let bytecode = compiler.bytecode()
			
			try testInstructions(expected: test.expectedInstructions, actual: bytecode.instructions)
			
			try testConstants(expected: test.expectedConstants, actual: bytecode.constants)
		}
	}
	
	private func testInstructions(expected: [Instructions], actual: Instructions) throws {
		let concatted = concatInstructions(instructions: expected)
		
		guard actual.count == concatted.count else {
			throw StringError("wrong instruction length.\nwant=\(concatted.count)\ngot=\(actual.count)")
		}
		
		for (i, instruction) in concatted.enumerated() {
			guard actual[i] == instruction else {
				throw StringError("wrong instruction at \(i).\nwant=\(concatted)\nactual=\(concatted)")
			}
		}
	}
	
	private func testConstants(expected: [Any], actual: [Object]) throws {
		guard expected.count == actual.count else {
			throw StringError("wrong number of constants. got=\(actual.count), want=\(expected.count)")
		}
		
		for (i, constant) in expected.enumerated() {
			switch constant {
			case let integerConstant as Int:
				try testIntegerObject(expected: integerConstant, actual: actual[i])
			default:
				break
			}
		}
	}
	
	private func testIntegerObject(expected: Int, actual: Object) throws {
		guard let result = actual as? Object_t.Integer else {
			throw StringError("object is not Integer. got=\(type(of: actual))")
		}
		
		guard result.value == expected else {
			throw StringError("object has wrong value. got=\(result.value), want=\(expected)")
		}
	}
	
	
	private func concatInstructions(instructions: [Instructions]) -> Instructions {
		return instructions.reduce([], +)
	}
	
	private func parse(input: String) -> Ast.Program {
		let lexer = Lexer(input: input)
		let parser = Parser(lexer: lexer)
		guard let program = parser.parseProgram() else {
			XCTFail("Failed to create program")
			return Ast.Program(statements: [])
		}
		
		return program
	}
}
