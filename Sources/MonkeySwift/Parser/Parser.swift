//
//  Parser.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/3/13.
//

import Foundation

private enum Precedence: Int, Comparable {
    case lowest = 1
	case condition			// OR or AND
	case assign
    case equals
    case lessgreater
    case sum
    case product
    case prefix
    case call
    case index
    
    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

private let precedences: [TokenType: Precedence] = [
	.ASSIGN:	.assign,
    .EQ:        .equals,
    .NOT_EQ:    .equals,
    .LT:        .lessgreater,
    .GT:        .lessgreater,
	.LT_EQUAL:	.lessgreater,
	.GT_EQUAL:	.lessgreater,
    .PLUS:      .sum,
    .MINUS:     .sum,
    .SLASH:     .product,
    .ASTERISK:  .product,
    .LPAREN:    .call,
	.AND:		.condition,
	.OR:		.condition,
    .LBRACKET:  .index
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
        self.registerPrefix(tokenType: .LPAREN, fn: parseGroupedExpression)
        self.registerPrefix(tokenType: .IF, fn: parseIfExpression)
		self.registerPrefix(tokenType: .WHILE, fn: parseWhileExpression)
        self.registerPrefix(tokenType: .FUNCTION, fn: parseFunctionLiteral)
		self.registerPrefix(tokenType: .DEFINE_FUNCTION, fn: parseFunctionDefinition)
        self.registerPrefix(tokenType: .STRING, fn: parseStringLiteral)
        self.registerPrefix(tokenType: .LBRACKET, fn: parseArrayLiteral)
        self.registerPrefix(tokenType: .LBRACE, fn: parseHashLiteral)
        
		self.registerInfix(tokenType: .AND, fn: parseInfixExpression)
		self.registerInfix(tokenType: .OR, fn: parseInfixExpression)
        self.registerInfix(tokenType: .PLUS, fn: parseInfixExpression)
		self.registerInfix(tokenType: .ASSIGN, fn: parseAssignExpression)
        self.registerInfix(tokenType: .MINUS, fn: parseInfixExpression)
        self.registerInfix(tokenType: .SLASH, fn: parseInfixExpression)
        self.registerInfix(tokenType: .ASTERISK, fn: parseInfixExpression)
        self.registerInfix(tokenType: .EQ, fn: parseInfixExpression)
        self.registerInfix(tokenType: .NOT_EQ, fn: parseInfixExpression)
        self.registerInfix(tokenType: .LT, fn: parseInfixExpression)
        self.registerInfix(tokenType: .GT, fn: parseInfixExpression)
		self.registerInfix(tokenType: .LT_EQUAL, fn: parseInfixExpression)
		self.registerInfix(tokenType: .GT_EQUAL, fn: parseInfixExpression)
        self.registerInfix(tokenType: .LPAREN, fn: parseCallExpression)
        self.registerInfix(tokenType: .LBRACKET, fn: parseIndexExpression)

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
		case .DEFINE_CLASS:
			return parseClassDefinitionStatement()
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
            
            leftExpression = infixFn(leftExpression)
        }
        
        return leftExpression
    }
    
    private func parseExpressionList(endTokenType: TokenType) -> [Expression] {
        var list: [Expression] = []
        
        if peekTokenIs(endTokenType) {
            nextToken()
            return list
        }
        
        nextToken()
        
        // recursive here
        if let expression = parseExpression(precedence: .lowest) {
            list.append(expression)
        }
        
        while peekTokenIs(.COMMA) {
            nextToken()
            nextToken()
            
            // recursive here
            if let expression = parseExpression(precedence: .lowest) {
                list.append(expression)
            }
        }
        
        if !expectPeek(endTokenType) {
            return [Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse expression list, next token not \(endTokenType), got=\(peekToken)"), value: peekToken.literal)]
        }
        
        return list
    }
    
    private func parseLetStatement() -> Ast.LetStatement? {
        let letToken = curToken                    // the LET token
        
        if !expectPeek(TokenType.IDENT) {
            return nil
        }
        
        let nameToken = curToken
                
        if !expectPeek(TokenType.ASSIGN) {
            return nil
        }
        
        nextToken()
        
        guard let value = parseExpression(precedence: .lowest) else {
            return nil
        }
        
        if peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return Ast.LetStatement(token: letToken,
                                name: Ast.Identifier(token: nameToken, value: nameToken.literal),
                                value: value)
    }
    
    private func parseReturnStatement() -> Ast.ReturnStatement? {        
        let returnToken = curToken
        
        nextToken()
        
        guard let returnValue = parseExpression(precedence: .lowest) else {
            return nil
        }
        
        if peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return Ast.ReturnStatement(token: returnToken,
                                   returnValue: returnValue)
    }
	
	private func parseClassDefinitionStatement() -> Ast.ClassDefineStatement? {
		nextToken()						// skip the 'class' token
		
		let classNameToken = curToken	// the class name identifier token

		guard expectPeek(.LBRACE) else {
			return nil					// TODO: return parsing error
		}
		
		nextToken()						// skip the "{" token
		
		var methods: [Ast.FunctionDefineLiteral] = []
		
		while !curTokenIs(.RBRACE) && !curTokenIs(.EOF) {
			if let functionDefinition = parseMethodDefinition() as? Ast.FunctionDefineLiteral {
				methods.append(functionDefinition)
			}
			nextToken()
		}
		
		return Ast.ClassDefineStatement(token: classNameToken, methods: methods)
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
    
    private func parseBlockStatement() -> Ast.BlockStatement {
        let prevToken = curToken
        
        var statements: [Statement] = []
        
        nextToken()
        
        while !curTokenIs(.RBRACE) && !curTokenIs(.EOF) {
            if let statement = parseStatement() {
                statements.append(statement)
            }
            nextToken()
        }
        
        return Ast.BlockStatement(token: prevToken, statements: statements)
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
        
        // recursive here
        guard let rightExpression = parseExpression(precedence: prevPrecedence) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse right expression for infix expression"), value: curToken.literal)
        }
        return Ast.InfixExpression(token: prevToken, left: left, operator: prevToken.literal, right: rightExpression)
    }
	
	/// parse a bare assignment, without a `let`
	private func parseAssignExpression(left: Expression) -> Expression {
		let prevToken = curToken; // curToken: the '=' token
		
		guard let name = left as? Ast.Identifier else {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
											   literal: "failed to parse assign expression: left is not an identifier"),
								  value: curToken.literal)
		}
		
		nextToken()
		
		/**
		 	An assignment is generally:
		 		
		 		variable = value
		 */
		
		guard let value = parseExpression(precedence: .lowest) else {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
											   literal: "failed to parse value expression for assign expression"),
								  value: curToken.literal)
		}
		
		return Ast.AssignStatement(token: prevToken, name: name, value: value)
	}
    
    private func parseBoolean() -> Expression {
        return Ast.Boolean(token: curToken, value: curTokenIs(.TRUE))
    }
    
    private func parseGroupedExpression() -> Expression {
        nextToken()
                
        guard let expression = parseExpression(precedence: .lowest) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                               literal: "failed to parse expression for grouped expression"), value: curToken.literal)
        }
        
        if !expectPeek(.RPAREN) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                               literal: "failed to parse expression for grouped expression, next token not .RPAREN"), value: curToken.literal)
        }
        
        return expression
    }
    
    private func parseIfExpression() -> Expression {
        let prevToken = curToken

        if !expectPeek(.LPAREN) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                               literal: "failed to parse if expression. next Token not .LPAREN, got=\(peekToken)"), value: peekToken.literal)
        }

        nextToken()

        guard let condition = parseExpression(precedence: .lowest) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                               literal: "failed to parse condition expression for ifExpression"), value: curToken.literal)
        }

        if !expectPeek(.RPAREN) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                               literal: "failed to parse if expression. next token not .RPAREN, got=\(peekToken)"), value: peekToken.literal)
        }
        
        if !expectPeek(.LBRACE) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse if expression. next token not .LBRACE, got=\(peekToken)"), value: peekToken.literal)
        }

        let consequence = parseBlockStatement()
        
        let alternative: Ast.BlockStatement?
        if peekTokenIs(.ELSE) {
            nextToken()
            
            if !expectPeek(.LBRACE) {
                return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse if expression. next token not .LBRACE, got=\(peekToken)"), value: peekToken.literal)
            }
            
            alternative = parseBlockStatement()
        } else {
            alternative = nil
        }
        
        return Ast.IfExpression(token: prevToken,
                                condition: condition,
                                consequence: consequence,
                                alternative: alternative)
    }
	
	private func parseWhileExpression() -> Expression {
		let prevToken = curToken
		
		if !expectPeek(.LPAREN) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
											   literal: "failed to parse while expression. next Token not .LPAREN, got=\(peekToken)"), value: peekToken.literal)
		}
		
		nextToken()
		
		guard let condition = parseExpression(precedence: .lowest) else {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
											   literal: "failed to parse condition expression for whileExpression"), value: curToken.literal)
		}
		
		if !expectPeek(.RPAREN) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
											   literal: "failed to parse while expression. next token not .RPAREN, got=\(peekToken)"), value: peekToken.literal)
		}
		
		if !expectPeek(.LBRACE) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse while expression. next token not .LBRACE, got=\(peekToken)"), value: peekToken.literal)
		}
		
		let consequence = parseBlockStatement()
		
		return Ast.WhileExpression(token: prevToken,
								   condition: condition,
								   consequence: consequence)
	}
    
    private func parseIndexExpression(left: Expression) -> Expression {
        let prevToken = curToken
        
        nextToken()
        
        guard let index = parseExpression(precedence: .lowest) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse index expression"), value: peekToken.literal)
        }
        
        guard expectPeek(.RBRACKET) else {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse index expression, end token not .RBRACKET, got=\(peekToken)"), value: peekToken.literal)
        }
        
        return Ast.IndexExpression(token: prevToken, left: left, index: index)
    }
    
    private func parseFunctionLiteral() -> Expression {
        let prevToken = curToken
        
        if !expectPeek(.LPAREN) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function literal, next token not .LPAREN, got=\(peekToken)"), value: peekToken.literal)
        }
        
        let parameters = parseFunctionParameters()
        
        if !expectPeek(.LBRACE) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function literal, next token not .LBRACE, got=\(peekToken)"), value: peekToken.literal)
        }
        
        let body = parseBlockStatement()
        
        return Ast.FunctionLiteral(token: prevToken,
                                   parameters: parameters,
                                   body: body)
    }
	
	private func parseFunctionDefinition() -> Expression {
		nextToken()					// skip the 'function' keyword,
									// now the current token is the function name
		
		let prevToken = curToken	// the function name identifier
		
		if !expectPeek(.LPAREN) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function definition, next token not .LPAREN, got=\(peekToken)"), value: peekToken.literal)
		}
		
		let parameters = parseFunctionParameters()
		
		if !expectPeek(.LBRACE) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function definition, next token not .LBRACE, got=\(peekToken)"), value: peekToken.literal)
		}
		
		let body = parseBlockStatement()
		
		return Ast.FunctionDefineLiteral(token: prevToken,
										 parameters: parameters,
										 body: body)
	}
	
	/// only in use of parseClassDefinitionStatement
	/// for parsing method inside a class definition
	/// i.e. the function without the `function` keyword, inside a class
	private func parseMethodDefinition() -> Expression {
		
		let prevToken = curToken	// the method name identifier
		
		if !expectPeek(.LPAREN) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function definition, next token not .LPAREN, got=\(peekToken)"), value: peekToken.literal)
		}
		
		let parameters = parseFunctionParameters()
		
		if !expectPeek(.LBRACE) {
			return Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function definition, next token not .LBRACE, got=\(peekToken)"), value: peekToken.literal)
		}
		
		let body = parseBlockStatement()
		
		return Ast.FunctionDefineLiteral(token: prevToken,
										 parameters: parameters,
										 body: body)
	}
    
    private func parseStringLiteral() -> Expression {
        return Ast.StringLiteral(token: curToken, value: curToken.literal)
    }
    
    private func parseArrayLiteral() -> Expression {
        let array = Ast.ArrayLiteral(token: curToken, elements: parseExpressionList(endTokenType: .RBRACKET))
        return array
    }
    
    private func parseHashLiteral() -> Expression {
        let prevToken = curToken
        
        var pairs = [Ast.HashLiteral.HashPair]()
        
        while !peekTokenIs(.RBRACE) {
            nextToken()
            guard let key = parseExpression(precedence: .lowest) else {
                return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                                   literal: "failed to parse expression for the key of hash literal"), value: curToken.literal)
            }
            
            if !expectPeek(.COLON) {
                return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                                   literal: "failed to parse expression for hash literal, next token not colon"), value: curToken.literal)
            }
            
            nextToken()
            
            guard let value = parseExpression(precedence: .lowest) else {
                return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                                   literal: "failed to parse expression for the value of hash literal"), value: curToken.literal)
            }
            
            pairs.append((key: key, value: value))
            
            if !peekTokenIs(.RBRACE) && !expectPeek(.COMMA) {
                return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                                   literal: "failed to parse expression for the hash literal, wrong terminator at the end of the key-value pair"), value: curToken.literal)
            }
        }
        
        if !expectPeek(.RBRACE) {
            return Ast.Identifier(token: Token(tokenType: .ILLEGAL,
                                               literal: "failed to parse expression for the hash literal, wrong terminator at the end hash literal"), value: curToken.literal)
        }
        
        return Ast.HashLiteral(token: prevToken, pairs: pairs)
    }
    
    private func parseFunctionParameters() -> [Ast.Identifier] {
        var identifiers: [Ast.Identifier] = []
        
        if peekTokenIs(.RPAREN) {
            nextToken()
            return identifiers
        }
        
        nextToken()
        
        let identifier = Ast.Identifier(token: curToken, value: curToken.literal)
        identifiers.append(identifier)
        
        while peekTokenIs(.COMMA) {
            nextToken()
            nextToken()
            
            let identifier = Ast.Identifier(token: curToken, value: curToken.literal)
            identifiers.append(identifier)
        }
        
        if !expectPeek(.RPAREN) {
            return [Ast.Identifier(token: Token(tokenType: .ILLEGAL, literal: "failed to parse function literald  next token not .RPAREN, got=\(peekToken)"), value: peekToken.literal)]
        }
        
        return identifiers
    }
    
    private func parseCallExpression(function: Expression) -> Expression {
        let prevToken = curToken
        let arguments = parseExpressionList(endTokenType: .RPAREN)
        return Ast.CallExpression(token: prevToken,
                                  function: function,
                                  arguments: arguments)
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

