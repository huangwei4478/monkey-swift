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
			let instructions = Bytecode.make(test.opCode, operands: test.operands)
			XCTAssertEqual(instructions.count, test.expected.count)
			for index in 0 ..< test.expected.count {
				XCTAssertEqual(instructions[index], test.expected[index])
			}
		}
	}
}
