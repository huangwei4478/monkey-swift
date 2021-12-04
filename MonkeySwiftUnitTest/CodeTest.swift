//
//  CodeTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/11/24.
//

import XCTest
@testable import MonkeySwift

class CodeTest: XCTestCase {

	typealias Test = (opCode: OpCodes, operands: [Int32], expected: [Byte])
		
	func testMake() {
		let tests: [Test] = [
			(OpCodes.constant, [65534], [OpCodes.constant.rawValue, 255, 254])
		]
		
		for test in tests {
			let instructions = BytecodeTool.make(test.opCode, operands: test.operands)
			XCTAssertEqual(instructions.count, test.expected.count)
			for index in 0 ..< test.expected.count {
				XCTAssertEqual(instructions[index], test.expected[index])
			}
		}
	}
	
	func testInstructionsDescription() {
		var instructions: Instructions = []
		instructions.append(contentsOf: BytecodeTool.make(.constant, 1))
		instructions.append(contentsOf: BytecodeTool.make(.constant, 2))
		instructions.append(contentsOf: BytecodeTool.make(.constant, 65535))
		
		let expected = """
		0000 OpConstant          1
		0003 OpConstant          2
		0006 OpConstant          65535
		"""
		
		print(instructions.description)
		XCTAssertEqual(instructions.description, expected)
	}
	
	func testReadOperands() {
		let tests: [(OpCodes, [Int32], Int)] = [
			(.constant, [65535], 2)
		]
		
		for test in tests {
			let instruction = BytecodeTool.make(test.0, operands: test.1)
			let definition = OperationDefinition[test.0]
			XCTAssertNotNil(definition)
			
			let operandsRead = BytecodeTool.readOperands(definition!, instructions: Instructions(instruction[1...]))
			XCTAssertEqual(operandsRead.count, test.2)
			XCTAssertEqual(operandsRead.values, test.1)
		}
	}
}
