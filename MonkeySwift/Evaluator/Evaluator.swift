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
            return evalStatements(statements: node.statements)
        
        case let node as Ast.ExpressionStatement:
            return eval(node.expression)
        
        // Expressions
        case let node as Ast.IntegerLiteral:
            return Object_t.Integer(value: node.value)
        case let node as Ast.Boolean:
            return node.value ? Object_t.Boolean(value: true) :
                Object_t.Boolean(value: false)
        case let node as Ast.PrefixExpression:
            guard let right = eval(node.right) else { return nil }
            return evalPrefixExpression(operator: node.operator, right: right)
        default:
            return nil
        }
    }
    
    private static func evalStatements(statements: [Statement]) -> Object {
        var result: Object = Object_t.Null()
        
        for (_, statement) in statements.enumerated() {
            guard let evaluated = eval(statement) else { continue }
            result = evaluated
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
            return Object_t.Null()
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
        guard right.type() == .integer_obj else { return Object_t.Null() }
        guard let integer = right as? Object_t.Integer else { return Object_t.Null() }
        return Object_t.Integer(value: -integer.value)
    }
}




