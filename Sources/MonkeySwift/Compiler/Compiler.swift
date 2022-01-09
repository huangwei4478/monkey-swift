//
//  Compiler.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/11/28.
//

import Foundation

struct Compiler {
	let instructions: Instructions
	
	let constants: [Object]
	
	init() {
		self.instructions = Instructions()
		self.constants = []
	}
	
	func compile(node: Node) throws {
		throw StringError("compile error")
	}
	
	func bytecode() -> Bytecode {
		return Bytecode(instructions: instructions, constants: constants)
	}
}

struct Bytecode {
	let instructions: Instructions
	
	let constants: [Object]
}
