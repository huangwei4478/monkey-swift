//
//  Object.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/4/28.
//

import Foundation

enum ObjectType: String {
    case integer_obj = "INTEGER"
    case boolean_obj = "BOOLEAN"
    case null_obj    = "NULL"
}


protocol Object {
    func type() -> ObjectType
    
    func inspect() -> String
}

struct Integer: Object {
    let value: Int64
    
    func type() -> ObjectType {
        return .integer_obj
    }
    
    func inspect() -> String {
        return String(format: "%d", value)
    }
}

struct Boolean: Object {
    let value: Bool
    
    func type() -> ObjectType {
        return .boolean_obj
    }
    
    func inspect() -> String {
        return "\(value)"
    }
}

struct Null: Object {
    func type() -> ObjectType {
        return .null_obj
    }
    
    func inspect() -> String {
        return "null"
    }
}
