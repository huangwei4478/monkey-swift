//
//  Ast.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/3/13.
//

import Foundation

protocol Node {
    func tokenLiteral() -> String
    func string() -> String
}

protocol Statement: Node {
    func statementNode()
}

protocol Expression: Node {
    func expressionNode()
}

public struct Ast {
    struct Program: Node {
        
        var statements: [Statement]
        
        func tokenLiteral() -> String {
            if statements.count > 0 {
                return statements[0].tokenLiteral()
            } else {
                return ""
            }
        }
        
        func string() -> String {
            return statements.reduce("") { (resultSoFar, statement) -> String in
                return resultSoFar + statement.string()
            }
        }
    }
    
    struct Identifier: Expression {
        let token: Token                    // the token.IDENT token
        
        let value: String
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return value
        }
    }
    
    struct LetStatement: Statement {
        let token: Token                    // the token.LET token
        
        let name: Identifier
        
        let value: Expression
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func statementNode() {}
        
        func string() -> String {
            return "\(tokenLiteral()) \(name.string()) = \(value.string());"
        }
    }
    
    struct ReturnStatement: Statement {
        let token: Token                    // the 'return' token
        
        let returnValue: Expression
        
        func statementNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return "\(tokenLiteral()) \(returnValue.string());"
        }
    }
    
    struct ExpressionStatement: Statement {
        let token: Token                    // the first token of the expression
        
        let expression: Expression
        
        func statementNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return expression.string()
        }
    }
}
