//
//  OpCode.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/11/24.
//

import Foundation

/// A byte mapping to one of the operations supported by the VM
public typealias OpCode = UInt8

/// Make code clear
public typealias Byte = UInt8

/// A list of bytes representing one or several or part of a VM instruction
public typealias Instructions = [Byte]

/// The Operation Codes supported by the VM
public enum OpCodes: OpCode {
	/// Stores a constant vbalue in the constants pool
	case constant
	
	/// Pops the top two values in the stack
	case pop
}

/// For a clear control on the operands byte sizes
public enum Sizes: Int {
	/// 8 bits
	case byte = 1
	
	/// 16 bits
	case word = 2
	
	/// 32 bits
	case dword = 4
	
	/// 64 bits
	case qword = 8
}

/// Metadata `struct` to tell the compiler how the VM instructions are composed
public struct OperationDefinition {
	/// The human readable name of the operation
	public let name: String
	
	/// The size in bytes of each operand this operation requires
	let operandWidths: [Sizes]
	
	/// Return the definition associated to a given `OpCodes`
	public static subscript(_ code: OpCodes) -> OperationDefinition? {
		return definitions[code]
	}

	private static let definitions: [OpCodes: OperationDefinition] = [
		.constant: OperationDefinition(name: "OpConstant", operandWidths: [.word])
	]
}

extension Instructions {
	var string: String {
		return ""
	}
}

