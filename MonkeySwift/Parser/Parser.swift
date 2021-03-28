//
//  Parser.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/3/13.
//

import Foundation

struct Parser {
    var lexer: Lexer
    
    var curToken: Token
    var peekToken: Token
    
    var errors: [String]
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.curToken = Token(tokenType: .ILLEGAL, literal: "")
        self.peekToken = Token(tokenType: .ILLEGAL, literal: "")
        self.errors = []
        
        // read two tokens, so curToken and peekToken are both set
        self.nextToken()
        self.nextToken()
    }
    
    private mutating func nextToken() {
        curToken = peekToken
        peekToken = lexer.nextToken()
    }
    
    mutating func parseProgram() -> Ast.Program? {
        var program = Ast.Program(statements: [])
        
        while curToken.tokenType != .EOF {
            if let statement = parseStatement() {
                program.statements.append(statement)
            }
            nextToken()
        }
        
        return program
    }
    
    private mutating func parseStatement() -> Statement? {
        switch curToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        default:
            return nil
        }
    }
    
    // TODO: just to sooth the compiler; expression is a to-do
    private struct ExpressionPlaceholder: Expression {
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return "Error, do not use me; just a placeholder"
        }
        
        func string() -> String {
            return "Error, do not use me; just a placeholder"
        }
    }
    
    private mutating func parseLetStatement() -> Ast.LetStatement? {
        let prevToken = curToken                    // the LET token
        
        if !expectPeek(TokenType.IDENT) {
            return nil
        }
        
        let name = Ast.Identifier(token: curToken, value: curToken.literal)
        
        let statement = Ast.LetStatement(token: prevToken, name: name, value: ExpressionPlaceholder())
        
        if !expectPeek(TokenType.ASSIGN) {
            return nil
        }
        
        // TODO: we're skipping the expression until we encounter a semicolon
        while !curTokenIs(TokenType.SEMICOLON) {
            nextToken()
        }
        
        return statement
    }
    
    private mutating func parseReturnStatement() -> Ast.ReturnStatement? {
        let statement = Ast.ReturnStatement(token: curToken, returnValue: ExpressionPlaceholder())
        
        nextToken()
        
        // TODO: we're skipping the expression until we encounter a semicolon
        while !curTokenIs(TokenType.SEMICOLON) {
            nextToken()
        }
        
        return statement
    }
    
    private func curTokenIs(_ tokenType: TokenType) -> Bool {
        return curToken.tokenType == tokenType
    }
    
    private func peekTokenIs(_ tokenType: TokenType) -> Bool {
        return peekToken.tokenType == tokenType
    }
    
    private mutating func expectPeek(_ tokenType: TokenType) -> Bool {
        if peekTokenIs(tokenType) {
            nextToken()
            return true
        } else {
            peekError(tokenType)
            return false
        }
    }
    
    func Errors() -> [String] {
        return errors
    }
    
    private mutating func peekError(_ tokenType: TokenType) {
        errors.append("expected next token to be \(tokenType), got \(peekToken.tokenType) instead")
    }
}

