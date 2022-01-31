//
//  Object.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/4/28.
//

import Foundation

enum ObjectType: String {
    case integer_obj        = "INTEGER"
    case boolean_obj        = "BOOLEAN"
    case null_obj           = "NULL"
    case return_value_obj   = "RETURN_VALUE"
    case function_obj       = "FUNCTION"
    case string_obj         = "STRING"
    case builtin_obj        = "BUILTIN"
    case array_obj          = "ARRAY"
    case hash_obj           = "HASH"
	case class_obj			= "CLASS"
	case instance_obj       = "INSTANCE"
    case error_obj          = "ERROR"
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
    
    typealias BuiltinFunction = (_ args: [Object]) -> Object
    
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
    
    struct Function: Object {
        let parameters: [Ast.Identifier]
        
        let body: Ast.BlockStatement
        
        let env: Environment
        
        func type() -> ObjectType {
            .function_obj
        }
        
        func inspect() -> String {
            return """
                    fn(\(parameters.map{ $0.string() }.joined(separator: ", "))){
                        \(body.string())
                    }
                    """
        }
    }
    
    struct Array: Object {
        let elements: [Object]
        
        func type() -> ObjectType {
            return .array_obj
        }
        
        func inspect() -> String {
            let elements = elements.map { $0.inspect() }.joined(separator: ", ")
            return "[\(elements)]"
        }
    }
    
    struct string: Object {
        let value: String
        
        func type() -> ObjectType {
            return .string_obj
        }
        
        func inspect() -> String {
            return value
        }
    }
    
    struct Builtin: Object {
        let function: BuiltinFunction
        
        func type() -> ObjectType {
            return .builtin_obj
        }
        
        func inspect() -> String {
            return "builtin function"
        }
        
    }
    
    struct HashPair {
        let key: Object
        
        let value: Object
    }
    
    struct Hash: Object {
        let pairs: [HashKey: HashPair]
        
        func type() -> ObjectType {
            .hash_obj
        }
        
        func inspect() -> String {
            let keyValues = pairs.map({ "\($1.key.inspect()): \($1.value.inspect())" })
            return "{\(keyValues.joined(separator: ", "))}"
        }
    }
	
	// OOP stuff
	
	/// runtime representation of a class
	struct Class: Object {
		let name: String
		// TODO: super class name
		
		/// instantiate a new instance of this class
		func instantiate() -> Instance {
			return Instance(class: self)
		}
		
		func type() -> ObjectType {
			.class_obj
		}
		
		func inspect() -> String {
			return "class \(name)"
		}
	}
	
	/// runtime representation of an instance
	struct Instance: Object {
		let `class`: Class
		
		func type() -> ObjectType {
			return .instance_obj
		}
		
		func inspect() -> String {
			return "\(`class`.name) instance"
		}
	}
    
    struct Error: Object {
        let message: String
        
        func type() -> ObjectType {
            return .error_obj
        }
        
        func inspect() -> String {
            return "ERROR: \(message)"
        }
    }
}

struct HashKey: Hashable {
    let type: ObjectType
    
    let value: UInt64
}

protocol Object_t_Hashable {
    func hashKey() -> HashKey
}

extension Object_t.Boolean: Object_t_Hashable {
    func hashKey() -> HashKey {
        let value: UInt64
        
        if self.value {
            value = 1
        } else {
            value = 0
        }
        
        return HashKey(type: self.type(), value: value)
    }
}

extension Object_t.Integer: Object_t_Hashable {
    func hashKey() -> HashKey {
        return HashKey(type: self.type(), value: UInt64(self.value))
    }
    
}

// Swift 4.2+: Swift hashvalue is not stable
// https://www.hackingwithswift.com/articles/115/swift-4-2-improves-hashable-with-a-new-hasher-struct
// use abs() to fix the negative issue
extension Object_t.string: Object_t_Hashable {
    func hashKey() -> HashKey {
        return HashKey(type: self.type(), value: UInt64(abs(self.value.hashValue)))
    }
}
