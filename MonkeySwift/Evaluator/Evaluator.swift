//
//  Evaluator.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/5/9.
//

import Foundation

func Eval(_ node: Node) -> Object {
    switch node {
    
    // Statements
    case let node as Ast.Program:
        return evalStatements(statements: node.statements)
    
    case let node as Ast.ExpressionStatement:
        return Eval(node.expression)
    
    // Expressions
    case let node as Ast.IntegerLiteral:
        return Object_t.Integer(value: node.value)
    
    default:
        return Object_t.Null()
    }
}

fileprivate func evalStatements(statements: [Statement]) -> Object {
    var result: Object = Object_t.Null()
    
    for (_, statement) in statements.enumerated() {
        result = Eval(statement)
    }
    
    return result
}
