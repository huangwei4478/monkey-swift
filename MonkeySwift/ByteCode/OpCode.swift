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

public extension Instructions {
	
	/// returns a human readable representations of this set of instructions
	var description: String {
		var output = ""
		var index = 0
		while index < self.count {
			guard let opCode = OpCodes(rawValue: self[index]) else {
				output += "Error: No Opcode for: \(self[index])\n"
				index += 1
				continue
			}
			
			guard let def = OperationDefinition[opCode] else {
				output += "Error: No definition for: \(self[index])"
				index += 1
				continue
			}
			
			let read = BytecodeTool.readOperands(def, instructions: Array(self[(index + 1)...]))
			
			let formatString = "%04d %@%@"
			let operandString = read.values.map{ $0.description }.joined(separator: "")
			let opName = operandString.isEmpty ? def.name : def.name.padding(toLength: 20, withPad: " ", startingAt: 0)
			
			output += String(format: formatString, index, opName, operandString)
			
			index += 1 + read.count
			
			if index < self.count {
				output += "\n"
			}
		}
		return output
	}
	
	/// Convert a number of bytes to `Int32` representation, the taken bytes must be
	/// between 1 and 4, and reinterpret an int in big endian coding
	/// - Parameter bytes: The number of bytes, represented by `Sizes` enum goes from 1 to 4 bytes
	/// - Returns: The `Int32` value
	func readInt(bytes: Sizes, startIndex: Int = 0) -> Int32? {
		return readInt(bytes: bytes.rawValue, startIndex: startIndex)
	}
	
	/// Converts a number of bytes to `Int32` representation, the taken bytes must be
	/// between 1 and 4, and reprent an int in big endian encoding
	/// - Parameter bytes: The number of bytes, Must be between 1 and 4
	/// - Returns: The `Int32` value
	func readInt(bytes: Int, startIndex: Int = 0) -> Int32? {
		guard bytes >= 1 && bytes <= 4 else { return nil }
		
		guard startIndex <= self.count - bytes else { return nil }
		
		var value: Int32 = 0
		
		for byte in self[startIndex ..< (startIndex + bytes)] {
			value = value << 8;
			value = value | Int32(byte)
		}
		
		return value
	}
}

