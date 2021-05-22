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
}




