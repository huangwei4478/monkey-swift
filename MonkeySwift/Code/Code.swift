//
//  Code.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/11/24.
//

import Foundation

typealias Byte = UInt8

typealias Instructions = [Byte]

typealias Opcode = Byte

enum OpcodeEnum: Opcode {
	case OpConstant = 0
}

struct Definition {
	let name: String
	
	let operandWidths: [Int16]	// up to 65536 kinds of instructions
	
	init(_ name: String, _ operandWidths: [Int16]) {
		self.name = name
		self.operandWidths = operandWidths
	}
	
	func lookup(op: Byte) throws -> Definition {
		guard let definition = definitions[op] else {
			throw "opcode \(op) undefined"
		}
		
		return definition
	}
}

let definitions: [Opcode: Definition] = [
	OpcodeEnum.OpConstant.rawValue: Definition("OpConstant", [2])
]

