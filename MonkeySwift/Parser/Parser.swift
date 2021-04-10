//
//  Parser.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/3/13.
//

import Foundation

private enum Precedence: Int, Comparable {
    case lowest = 1
    case equals
    case lessgreater
    case sum
    case product
    case prefix
    case call
    
    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

private let precedences: [TokenType: Precedence] = [
    .EQ:        .equals,
    .NOT_EQ:    .equals,
    .LT:        .lessgreater,
    .GT:        .lessgreater,
    .PLUS:      .sum,
    .MINUS:     .sum,
    .SLASH:     .product,
    .ASTERISK:  .product,
]

final class Parser {
    
    /// () -> Expression
    private typealias PrefixParseFn = () -> Expression

    /// (Expression) -> Expression
    private typealias InfixParseFn = (Expression) -> Expression
    
    var lexer: Lexer
    
    private var curToken: Token
    private var peekToken: Token
    
    private var errors: [String]
    
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
        self.registerPrefix(tokenType: .INT, fn: parseIntegerLiteral)
        self.registerPrefix(tokenType: .BANG, fn: parsePrefixExpression)
        self.registerPrefix(tokenType: .MINUS, fn: parsePrefixExpression)
        self.registerPrefix(tokenType: .TRUE, fn: parseBoolean)
        self.registerPrefix(tokenType: .FALSE, fn: parseBoolean)
        
        self.registerInfix(tokenType: .PLUS, fn: parseInfixExpression)
        self.registerInfix(tokenType: .MINUS, fn: parseInfixExpression)
        self.registerInfix(tokenType: .SLASH, fn: parseInfixExpression)
        self.registerInfix(tokenType: .ASTERISK, fn: parseInfixExpression)
        self.registerInfix(tokenType: .EQ, fn: parseInfixExpression)
        self.registerInfix(tokenType: .NOT_EQ, fn: parseInfixExpression)
        self.registerInfix(tokenType: .LT, fn: parseInfixExpression)
        self.registerInfix(tokenType: .GT, fn: parseInfixExpression)

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
    
    private func noPrefixParseFnError(tokenType: TokenType) {
        errors.append("no prefix parse function for \(tokenType.rawValue) found")
    }
    
    // The heart of Pratt Parser!
    private func parseExpression(precedence: Precedence) -> Expression? {
        guard let prefixFn = prefixParseFns[curToken.tokenType] else {
            noPrefixParseFnError(tokenType: curToken.tokenType)
            return nil
        }
        
        var leftExpression = prefixFn()
        
        while !peekTokenIs(.SEMICOLON) && precedence < peekPrecedence() {
            guard let infixFn = infixParseFns[peekToken.tokenType] else {
                return leftExpression
            }
            
            nextToken()
            
            // What the hell?
            leftExpression = infixFn(leftExpression)
        }
        
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
    
    private func parseIntegerLiteral() -> Expression {
        guard let value = Int64(curToken.literal) else {
            errors.append("could not parse \(curToken.literal) as integer")
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "illegal token parsed as Integer"), value: curToken.literal)
        }
        return Ast.IntegerLiteral(token: curToken, value: value)
    }
    
    private func parsePrefixExpression() -> Expression {
        let prevToken = curToken
        
        nextToken()
        
        // recursive here!
        guard let rightExpression = parseExpression(precedence: .prefix) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse right expression for prefix expression"), value: curToken.literal)
        }
        return Ast.PrefixExpression(token: prevToken,
                                    operator: prevToken.literal,
                                    right: rightExpression)
    }
    
    private func parseInfixExpression(left: Expression) -> Expression {
        let prevToken = curToken // curToken: the operator of the infix expression
        let prevPrecedence = curPrecedence()    // the precedence of the operator
        
        nextToken()
        
        // recursive here!
        guard let rightExpression = parseExpression(precedence: prevPrecedence) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse right expression for infix expression"), value: curToken.literal)
        }
        return Ast.InfixExpression(token: prevToken, left: left, operator: prevToken.literal, right: rightExpression)
    }
    
    private func parseBoolean() -> Expression {
        return Ast.Boolean(token: curToken, value: curTokenIs(.TRUE))
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
    
    private func peekPrecedence() -> Precedence {
        guard let precedence = precedences[peekToken.tokenType] else {
            return .lowest
        }
        return precedence
    }
    
    private func curPrecedence() -> Precedence {
        guard let precedence = precedences[curToken.tokenType] else {
            return .lowest
        }
        return precedence
    }
    
    private func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = fn
    }
    
    private func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFn) {
        infixParseFns[tokenType] = fn
    }
}

