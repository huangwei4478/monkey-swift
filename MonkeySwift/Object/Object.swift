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
    case return_value_obj = "RETURN_VALUE"
}


protocol Object {
    func type() -> ObjectType
    
    func inspect() -> String
}

// TODO: maybe Applicative could help?
func == (lhs: Object, rhs: Object) -> Bool {
    switch (lhs, rhs) {
    case let (lhs, rhs) where lhs is Object_t.Integer && rhs is Object_t.Integer:
        return (lhs as! Object_t.Integer).value == (rhs as! Object_t.Integer).value
    case let (lhs, rhs) where lhs is Object_t.Boolean && rhs is Object_t.Boolean:
        return (lhs as! Object_t.Boolean).value == (rhs as! Object_t.Boolean).value
    case let (lhs, rhs) where lhs is Object_t.Null && rhs is Object_t.Null:
        return true
    default:
        return false
    }
}

func != (lhs: Object, rhs: Object) -> Bool {
    return !(lhs == rhs)
}

struct Object_t {
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
    
    struct ReturnValue: Object {
        let value: Object
        
        func type() -> ObjectType {
            return .return_value_obj
        }
        
        func inspect() -> String {
            return value.inspect()
        }
    }
}

