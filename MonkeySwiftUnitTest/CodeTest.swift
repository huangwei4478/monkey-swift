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
	
	func testInstructionsString() {
		let instructions = [
			BytecodeTool.make(.constant, operands: [1]),
			BytecodeTool.make(.constant, operands: [2]),
			BytecodeTool.make(.constant, operands: [65535])
		]
		
		let expected =
  		"0000 OpConstant 1\n0003 OpConstant 2\n0006 OpConstant 65535"
		
		let concatted = instructions.reduce([], +) as Instructions
		guard concatted.string == expected else {
			XCTFail("instructions wrongly formatted.\nwant=\(expected)\ngot=\(concatted.string)")
			return
		}
		
	}
}
