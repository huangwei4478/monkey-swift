//
//  Parser.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/3/13.
//

import Foundation

/// () -> Expression
private typealias PrefixParseFn = () -> Expression

/// (Expression) -> Expression
private typealias InfixParseFn = (Expression) -> Expression

private enum Precedence: Int {
    case lowest = 1
    case equals
    case lessgreater
    case sum
    case product
    case prefix
    case call
}

class Parser {
    var lexer: Lexer
    
    private var curToken: Token
    private var peekToken: Token
    
    var errors: [String]
    
    private var prefixParseFns: [TokenType: PrefixParseFn]
    private var infixParseFns: [TokenType: InfixParseFn]
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.curToken = Token(tokenType: .ILLEGAL, literal: "")
        self.peekToken = Token(tokenType: .ILLEGAL, literal: "")
        self.errors = []
        self.prefixParseFns = [:]
        self.infixParseFns = [:]

        self.registerPrefix(tokenType: .IDENT, fn: parseIdentifier)

        // read two tokens, so curToken and peekToken are both set
        self.nextToken()
        self.nextToken()
    }
    
    private func nextToken() {
        curToken = peekToken
        peekToken = lexer.nextToken()
    }
    
    func parseProgram() -> Ast.Program? {
        var program = Ast.Program(statements: [])
        
        while curToken.tokenType != .EOF {
            if let statement = parseStatement() {
                program.statements.append(statement)
            }
            nextToken()
        }
        
        return program
    }
    
    /// Monkey has only two types of statements: let and return; the others are Expression Statements
    private func parseStatement() -> Statement? {
        switch curToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETURN:
            return parseReturnStatement()
        default:
            return parseExpressionStatement()
        }
    }
    
    private func parseExpression(precedence: Precedence) -> Expression? {
        guard let prefixFn = prefixParseFns[curToken.tokenType] else {
            return nil
        }
        
        let leftExpression = prefixFn()
        return leftExpression
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
    
    private func parseLetStatement() -> Ast.LetStatement? {
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
    
    private func parseReturnStatement() -> Ast.ReturnStatement? {
        let statement = Ast.ReturnStatement(token: curToken, returnValue: ExpressionPlaceholder())
        
        nextToken()
        
        // TODO: we're skipping the expression until we encounter a semicolon
        while !curTokenIs(TokenType.SEMICOLON) {
            nextToken()
        }
        
        return statement
    }
    
    private func parseExpressionStatement() -> Ast.ExpressionStatement? {
        guard let expression = parseExpression(precedence: .lowest) else {
            return nil
        }
        
        let statement = Ast.ExpressionStatement(token: curToken,
                                                expression: expression)
        
        if peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return statement
    }
    
    private func parseIdentifier() -> Expression {
        return Ast.Identifier(token: curToken, value: curToken.literal)
    }
    
    private func curTokenIs(_ tokenType: TokenType) -> Bool {
        return curToken.tokenType == tokenType
    }
    
    private func peekTokenIs(_ tokenType: TokenType) -> Bool {
        return peekToken.tokenType == tokenType
    }
    
    private func expectPeek(_ tokenType: TokenType) -> Bool {
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
    
    private func peekError(_ tokenType: TokenType) {
        errors.append("expected next token to be \(tokenType), got \(peekToken.tokenType) instead")
    }
    
    private func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = fn
    }
    
    private func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFn) {
        infixParseFns[tokenType] = fn
    }
}

