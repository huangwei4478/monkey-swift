//
//  BytecodeTool.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/11/27.
//

import Foundation

public enum BytecodeTool {
	/// Converts abstract representation into Hermes VM bytecode instructions
	/// - Parameters:
	///   - op: The instruction `OpCode`
	///   - operands: The operands values
	/// - Returns: The instruction bytes
	public static func make(_ op: OpCodes, _ operands: Int32...) -> Instructions {
		return BytecodeTool.make(op, operands: operands)
	}
	
	/// Converts abstract representation into Hermes VM bytecode instructions
	/// - Parameters:
	///   - op: The instruction `OpCode`
	///   - operands: The operands values
	/// - Returns: The instruction bytes
	public static func make(_ op: OpCodes, operands: [Int32] = []) -> Instructions {
		guard let definition = OperationDefinition[op] else {
			return []
		}
		
		let instructionLen = 1 + definition.operandWidths.reduce(0, { $0 + $1.rawValue })
		var output: Instructions = []
		output.reserveCapacity(instructionLen)
		output.append(op.rawValue)
		
		for index in 0 ..< operands.count {
			let operand = operands[index]
			let width = definition.operandWidths[index]

			// WTF?
			output.append(contentsOf: withUnsafeBytes(of: operand.bigEndian,
													  Array.init).suffix(width.rawValue))
		}
		
		
		return output
	}
}
