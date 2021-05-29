//
//  Evaluator.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/5/9.
//

import Foundation

struct Evaluator {
    static func eval(_ node: Node) -> Object? {
        switch node {
        
        // Statements
        case let node as Ast.Program:
            return evalProgram(program: node)
        
        case let node as Ast.ExpressionStatement:
            return eval(node.expression)
            
        case let node as Ast.BlockStatement:
            return evalBlockStatement(block: node)
            
        case let node as Ast.ReturnStatement:
            guard let value = eval(node.returnValue) else { return nil }
            if isError(object: value) { return value }
            return Object_t.ReturnValue(value: value)
            
        // Expressions
        case let node as Ast.IntegerLiteral:
            return Object_t.Integer(value: node.value)
            
        case let node as Ast.Boolean:
            return nativeBoolToBooleanObject(input: node.value)
            
        case let node as Ast.PrefixExpression:
            guard let right = eval(node.right) else { return nil }
            if isError(object: right) { return right }
            return evalPrefixExpression(operator: node.operator, right: right)
            
        case let node as Ast.InfixExpression:
            guard let left = eval(node.left) else { return nil }
            guard let right = eval(node.right) else { return nil }
            if isError(object: left) { return left }
            if isError(object: right) { return right }
            return evalInfixExpression(operator: node.operator, left: left, right: right)
            
        case let node as Ast.IfExpression:
            return evalIfExpression(ifExpression: node)
            
        default:
            return nil
        }
    }
    
    private static func evalProgram(program: Ast.Program) -> Object {
        var result: Object = Object_t.Null()
        
        for (_, statement) in program.statements.enumerated() {
            guard let evaluated = eval(statement) else { continue }
            
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
    
    private static func evalBlockStatement(block: Ast.BlockStatement) -> Object {
        var result: Object = Object_t.Null()
        
        for (_, statement) in block.statements.enumerated() {
            guard let evaluated = eval(statement) else { continue }
            
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
    
    private static func nativeBoolToBooleanObject(input: Bool) -> Object_t.Boolean {
        return input ? Object_t.Boolean(value: true) :
            Object_t.Boolean(value: false)
    }
    
    private static func evalIfExpression(ifExpression: Ast.IfExpression) -> Object {
        guard let condition = eval(ifExpression.condition) else {
            return Object_t.Null()
        }
        if isError(object: condition) { return condition }
        
        if isTruthy(object: condition) {
            guard let consequence = eval(ifExpression.consequence) else {
                return Object_t.Null()
            }
            return consequence
        } else if ifExpression.alternative != nil {
            guard let alternative = eval(ifExpression.alternative!) else {
                return Object_t.Null()
            }
            return alternative
        } else {
            return Object_t.Null()
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
    
    private static func isError(object: Object?) -> Bool {
        if let object = object {
            return object.type() == .error_obj
        } else {
            return false
        }
    }
}




