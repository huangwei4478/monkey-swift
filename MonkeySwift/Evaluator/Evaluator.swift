//
//  Evaluator.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/5/9.
//

import Foundation

struct Evaluator {
    static func eval(_ node: Node, _ environment: Environment) -> Object? {
        switch node {
        
        // Statements
        case let node as Ast.Program:
            return evalProgram(program: node, environment: environment)
        
        case let node as Ast.ExpressionStatement:
            return eval(node.expression, environment)
            
        case let node as Ast.BlockStatement:
            return evalBlockStatement(block: node, environment: environment)
            
        case let node as Ast.ReturnStatement:
            guard let value = eval(node.returnValue, environment) else { return nil }
            if isError(object: value) { return value }
            return Object_t.ReturnValue(value: value)
            
        case let node as Ast.LetStatement:
            guard let value = eval(node.value, environment) else { return nil }
            if isError(object: value) { return value }
            return environment.set(name: node.name.value, value: value)
            
        // Expressions
        case let node as Ast.IntegerLiteral:
            return Object_t.Integer(value: node.value)
            
        case let node as Ast.FunctionLiteral:
            return Object_t.Function(parameters: node.parameters,
                                     body: node.body,
                                     env: environment)
            
        case let node as Ast.StringLiteral:
            return Object_t.string(value: node.value)
            
        case let node as Ast.ArrayLiteral:
            let elements = evalExpressions(expressions: node.elements, environment: environment)
            if elements.count == 1 && isError(object: elements[0]) {
                return elements[0]
            }
            return Object_t.Array(elements: elements)
            
        case let node as Ast.HashLiteral:
            return evalHashLiteral(node: node, environment: environment)
            
        case let node as Ast.CallExpression:
            guard let function = eval(node.function, environment) else { return nil }
            if isError(object: function) {
                return function
            }
            
            let args = evalExpressions(expressions: node.arguments,
                                       environment: environment)
            if args.count == 1 && isError(object: args.first!) {
                return args[0]
            }
            
            return applyFunction(function, args)
            
        case let node as Ast.IndexExpression:
            guard let left = eval(node.left, environment) else { return nil }
            if isError(object: left) {
                return left
            }
            
            guard let index = eval(node.index, environment) else { return nil }
            if isError(object: index) {
                return index
            }
            
            return evalIndexExpression(left: left, index: index)
            
        case let node as Ast.Boolean:
            return nativeBoolToBooleanObject(input: node.value)
            
        case let node as Ast.PrefixExpression:
            guard let right = eval(node.right, environment) else { return nil }
            if isError(object: right) { return right }
            return evalPrefixExpression(operator: node.operator, right: right)
            
        case let node as Ast.InfixExpression:
            guard let left = eval(node.left, environment) else { return nil }
            guard let right = eval(node.right, environment) else { return nil }
            if isError(object: left) { return left }
            if isError(object: right) { return right }
            return evalInfixExpression(operator: node.operator, left: left, right: right)
            
        case let node as Ast.IfExpression:
            return evalIfExpression(ifExpression: node, environment: environment)
            
        case let node as Ast.Identifier:
            return evalIdentifier(node: node, environment: environment)
            
        default:
            return nil
        }
    }
    
    private static func evalProgram(program: Ast.Program, environment: Environment) -> Object {
        var result: Object = Object_t.Null()
        
        for (_, statement) in program.statements.enumerated() {
            guard let evaluated = eval(statement, environment) else { continue }
            
            switch evaluated {
            case let node as Object_t.ReturnValue:
                return node.value
            case let node as Object_t.Error:
                return node
            default:
                result = evaluated
            }
        }
        
        return result
    }
    
    private static func evalBlockStatement(block: Ast.BlockStatement, environment: Environment) -> Object {
        var result: Object = Object_t.Null()
        
        for (_, statement) in block.statements.enumerated() {
            guard let evaluated = eval(statement, environment) else { continue }
            
            if evaluated.type() == .return_value_obj ||
                evaluated.type() == .error_obj {
                // stop the evaluation
                return evaluated
            } else {
                result = evaluated
            }
        }
        
        return result
    }
    
    private static func evalPrefixExpression(operator: String, right: Object) -> Object {
        switch `operator` {
        case "!":
            return evalBangOperatorExpression(right: right)
        case "-":
            return evalMinusPrefixOperatorExpression(right: right)
        default:
            return Object_t.Error(message: "unknown operator: \(`operator`)\(right.type().rawValue)")
        }
    }
    
    private static func evalInfixExpression(operator: String, left: Object, right: Object) -> Object {
        switch (`operator`, left, right) {
        case let (_, left, right) where left.type() == .integer_obj && right.type() == .integer_obj:
            return evalIntegerInfixExpression(operator: `operator`, left: left, right: right)
        case let (`operator`, _, _) where `operator` == "==":
            return nativeBoolToBooleanObject(input: left == right)
        case let (`operator`, _, _) where `operator` == "!=":
            return nativeBoolToBooleanObject(input: left != right)
        case let (`operator`, left, right) where left.type() == .string_obj && right.type() == .string_obj:
            return evalStringInfixExpression(operator: `operator`, left: left as! Object_t.string, right: right as! Object_t.string)
        case let (_, left, right) where left.type() != right.type():
            return Object_t.Error(message: "type mismatch: \(left.type().rawValue) \(`operator`) \(right.type().rawValue)")
        default:
            return Object_t.Error(message: "unknown operator: \(left.type().rawValue) \(`operator`) \(right.type().rawValue)")
        }
    }
    
    private static func evalBangOperatorExpression(right: Object) -> Object {
        switch right {
        case let object as Object_t.Boolean:
            return Object_t.Boolean(value: !object.value)
        case _ as Object_t.Null:
            return Object_t.Boolean(value: true)
        default:
            return Object_t.Boolean(value: false)
        }
    }
    
    private static func evalMinusPrefixOperatorExpression(right: Object) -> Object {
        guard right.type() == .integer_obj else {
            return Object_t.Error(message: "unknown operator: -\(right.type().rawValue)")
        }
        guard let integer = right as? Object_t.Integer else { return Object_t.Null() }
        return Object_t.Integer(value: -integer.value)
    }
    
    private static func evalIntegerInfixExpression(operator: String, left: Object, right: Object) -> Object {
        guard let left = left as? Object_t.Integer else { return Object_t.Null() }
        guard let right = right as? Object_t.Integer else { return Object_t.Null() }
        
        let leftValue = left.value
        let rightValue = right.value
        
        switch `operator` {
        case "+":
            return Object_t.Integer(value: leftValue + rightValue)
        case "-":
            return Object_t.Integer(value: leftValue - rightValue)
        case "*":
            return Object_t.Integer(value: leftValue * rightValue)
        case "/":
            return Object_t.Integer(value: leftValue / rightValue)
        case "<":
            return nativeBoolToBooleanObject(input: leftValue < rightValue)
        case ">":
            return nativeBoolToBooleanObject(input: leftValue > rightValue)
        case "==":
            return nativeBoolToBooleanObject(input: leftValue == rightValue)
        case "!=":
            return nativeBoolToBooleanObject(input: leftValue != rightValue)
        default:
            return Object_t.Error(message: "unknown operator: \(left.type().rawValue) \(`operator`) \(right.type().rawValue)")
        }
    }
    
    private static func evalExpressions(expressions: [Expression],
                                        environment: Environment) -> [Object] {
        var result:[Object] = []
        
        for expression in expressions {
            guard let evaluated = eval(expression, environment) else {
                return [Object_t.Error(message: "eval nothing")]
            }
            
            result += [evaluated]
        }
        
        return result
    }
    
    private static func nativeBoolToBooleanObject(input: Bool) -> Object_t.Boolean {
        return input ? Object_t.Boolean(value: true) :
            Object_t.Boolean(value: false)
    }
    
    private static func evalIfExpression(ifExpression: Ast.IfExpression, environment: Environment) -> Object {
        guard let condition = eval(ifExpression.condition, environment) else {
            return Object_t.Null()
        }
        if isError(object: condition) { return condition }
        
        if isTruthy(object: condition) {
            guard let consequence = eval(ifExpression.consequence, environment) else {
                return Object_t.Null()
            }
            return consequence
        } else if ifExpression.alternative != nil {
            guard let alternative = eval(ifExpression.alternative!, environment) else {
                return Object_t.Null()
            }
            return alternative
        } else {
            return Object_t.Null()
        }
    }
    
    private static func evalIdentifier(node: Ast.Identifier, environment: Environment) -> Object {
        if let value = environment.get(name: node.value) {
            return value
        } else if let builtin = builtins[node.value] {
            return builtin
        } else {
            return Object_t.Error(message: "identifier not found: \(node.value)")
        }
    }
    
    private static func evalStringInfixExpression(`operator`: String, left: Object_t.string, right: Object_t.string) -> Object {
        guard `operator` == "+" else {
            return Object_t.Error(message: "unknown operator: \(left.type().rawValue) \(`operator`) \(right.type().rawValue)")
        }
        
        return Object_t.string(value: left.value + right.value)
    }
    
    private static func evalIndexExpression(left: Object, index: Object) -> Object {
        switch (left, index) {
        case (let left, let index) where left.type() == .array_obj && index.type() == .integer_obj:
            return evalArrayIndexExpression(array: left, index: index)
        case (let left, let index) where left.type() == .hash_obj:
            return evalHashIndexExpression(hash: left, index: index)
        default:
            return Object_t.Error(message: "index operator not supported: \(left.type())")
        }
    }
    
    private static func evalArrayIndexExpression(array: Object, index: Object) -> Object {
        guard let arrayObject = array as? Object_t.Array else {
            return Object_t.Error(message: "\(array) is not an Array type")
        }
        
        guard let index = index as? Object_t.Integer else {
            return Object_t.Error(message: "\(index) is not an Integer type")
        }
        
        let max = arrayObject.elements.count - 1
        
        // edge cases
        if index.value < 0 || index.value > max {
            return Object_t.Null()
        }
        
        return arrayObject.elements[Int(index.value)]
    }
    
    private static func evalHashIndexExpression(hash: Object, index: Object) -> Object {
        guard let hashObject = hash as? Object_t.Hash else {
            return Object_t.Error(message: "unusable as hash type: \(hash.type().rawValue) ")
        }
        
        guard let key = index as? Object_t_Hashable else {
            return Object_t.Error(message: "unusable as hash key: \(index.type().rawValue)")
        }
        
        guard let pair = hashObject.pairs[key.hashKey()] else {
            return Object_t.Null()
        }
        
        return pair.value
    }
    
    private static func evalHashLiteral(node: Ast.HashLiteral, environment: Environment) -> Object {
        var pairs: [HashKey: Object_t.HashPair] = [:]
        
        for (keyNode, valueNode) in node.pairs {
            guard let key = eval(keyNode, environment) else { return Object_t.Error(message: "eval function key error: \(keyNode.string())") }
            if isError(object: key) {
                return key
            }
            
            guard let hashKey = key as? Object_t_Hashable else {
                return Object_t.Error(message: "unusable as hash key: \(1111)")
            }
            
            guard let value = eval(valueNode, environment) else {
                return Object_t.Error(message: "eval function value error: \(valueNode.string())")
            }
            
            if isError(object: value) {
                return value
            }
            
            let hashed = hashKey.hashKey()
            pairs[hashed] = Object_t.HashPair(key: key, value: value)
        }
        
        return Object_t.Hash(pairs: pairs)
    }
    
    private static func applyFunction(_ function: Object, _ arguments: [Object]) -> Object {
        switch function {
        case let function as Object_t.Function:
            let extendedEnvironment = extendFunctionEnvironment(function: function,
                                                                args: arguments)
            guard let evaluated = eval(function.body, extendedEnvironment) else {
                return Object_t.Error(message: "eval function body error: \(function.body)")
            }
            return unwrapReturnValue(object: evaluated)
            
        case let function as Object_t.Builtin:
            return function.function(arguments)
        default:
            return Object_t.Error(message: "not a function: \(function.type().rawValue)")
        }
    }
    
    private static func extendFunctionEnvironment(function: Object_t.Function, args: [Object]) -> Environment {
        let environment = Environment(outer: function.env)
        
        for (paramIndex, param) in function.parameters.enumerated() {
            let _ = environment.set(name: param.value, value: args[paramIndex])
        }
        
        return environment
    }
    
    private static func unwrapReturnValue(object: Object) -> Object {
        if let returnValue = object as? Object_t.ReturnValue {
            return returnValue.value
        } else {
            return object
        }
    }
    
    private static func isTruthy(object: Object) -> Bool {
        switch object {
        case is Object_t.Null:
            return false
        case let object as Object_t.Boolean:
            return object.value
        default:
            return true
        }
    }
    
    private static func isError(object: Object) -> Bool {
        return object.type() == .error_obj
    }
}

let builtins: [String: Object_t.Builtin] = [
    "len":
        Object_t.Builtin(function: { args in
            guard args.count == 1 else {
                return Object_t.Error(message: "wrong number of arguments. got=\(args.count), want=1")
            }
            switch args[0] {
            case let arg as Object_t.string:
                return Object_t.Integer(value: Int64(arg.value.count))
            case let arg as Object_t.Array:
                return Object_t.Integer(value: Int64(arg.elements.count))
            default:
                return Object_t.Error(message: "argument to `len` not supported, got=\(args[0].type().rawValue)")
            }
    }),
    "first":
        Object_t.Builtin(function: { args in
            guard args.count == 1 else {
                return Object_t.Error(message: "wrong number of arguments. got=\(args.count), want=1")
            }
            switch args[0] {
            case let arg as Object_t.Array:
                return arg.elements.first ?? Object_t.Null()
            default:
                return Object_t.Error(message: "argument to `first` must be ARRAY, got=\(args[0].type().rawValue)")
            }
        }),
    "last":
        Object_t.Builtin(function: { args in
            guard args.count == 1 else {
                return Object_t.Error(message: "wrong number of arguments. got=\(args.count), want=1")
            }
            switch args[0] {
            case let arg as Object_t.Array:
                return arg.elements.last ?? Object_t.Null()
            default:
                return Object_t.Error(message: "argument to `last` must be ARRAY, got=\(args[0].type().rawValue)")
            }
        }),
    "rest":
        Object_t.Builtin(function: { args in
            guard args.count == 1 else {
                return Object_t.Error(message: "wrong number of arguments. got=\(args.count), want=1")
            }
            switch args[0] {
            case let arg as Object_t.Array:
                return Object_t.Array(elements: Array(arg.elements.dropFirst()))
            default:
                return Object_t.Error(message: "argument to `rest` must be ARRAY, got=\(args[0].type().rawValue)")
            }
        }),
    "push":
        Object_t.Builtin(function: { args in
            guard args.count == 2 else {
                return Object_t.Error(message: "wrong number of arguments. got=\(args.count), want=2")
            }
            
            switch args[0] {
            case let arg as Object_t.Array:
                return Object_t.Array(elements: arg.elements + [args[1]])
            default:
                return Object_t.Error(message: "argument to `push` must be ARRAY, got=\(args[0].type().rawValue)")
            }
        }),
    "puts":
        Object_t.Builtin(function: { args in
                            for arg in args {
                                print(arg.inspect())
                            }
            return Object_t.Null()
        })
]


