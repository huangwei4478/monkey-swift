//
//  Errors.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/11/27.
//

import Foundation

struct StringError: Swift.Error {
	let description: String
	init(_ description: String) {
		self.description = description
	}
}
