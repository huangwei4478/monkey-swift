//
//  CodeTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/11/24.
//

import XCTest
@testable import MonkeySwift

class CodeTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testMake() {
		struct TestCase {
			let op: Opcode
			let operands: [Int]
			let expected: [Byte]
			
			init(_ op: Opcode, _ operands: [Int], _ expected: [Byte]) {
				self.op = op
				self.operands = operands
				self.expected = expected
			}
		}
		
		let testCases: [TestCase] = [
			TestCase(OpcodeEnum.OpConstant.rawValue, [65534],
					 [Byte(OpcodeEnum.OpConstant.rawValue),
					  Byte(bitPattern: 255),
					  Byte(bitPattern: 254)
					 ]
					)
		]
		
		for testCase in testCases {
			let instruction = make(op: testCase.op, operands: testCase.operands)
			
			guard instruction.count == testCase.expected.count else {
				XCTFail("instruction has wrong length. want=\(testCase.expected.count), got=\(instruction.count)")
				return
			}
			
			for (index, byte) in testCase.expected.enumerated() {
				guard instruction[index] == byte else {
					XCTFail("wrong byte at pos \(index). want=\(byte), got=\(instruction[index])")
					return
				}
			}
		}
	}
}
