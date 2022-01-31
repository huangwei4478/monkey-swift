//
//  TokenType.swift
//  monkey-swift
//
//  Created by huangwei on 2021/3/6.
//

import Foundation

public enum TokenType: String {
    case ILLEGAL = "ILLEGAL"
    case EOF = "EOF"
    
    // Identifiers + literals
    case IDENT = "IDENT"
    case INT = "INT"
    
    // Operators
    case ASSIGN = "="
    case PLUS = "+"
    case MINUS = "-"
    case BANG = "!"
    case ASTERISK = "*"
    case SLASH = "/"
    
    case LT = "<"
    case GT = ">"
	case LT_EQUAL = "<="
	case GT_EQUAL = ">="
    
    case EQ = "=="
    case NOT_EQ = "!="
	
	case AND = "&&"
	case OR  = "||"
    
    // Delimiters
    case COMMA = ","
    case SEMICOLON = ";"
    
    case LPAREN = "("
    case RPAREN = ")"
    case LBRACE = "{"
    case RBRACE = "}"
    case LBRACKET = "["
    case RBRACKET = "]"
    case COLON = ":"
    
    // Data Types
    case STRING = "STRING"
    
    // Keywords
    case FUNCTION = "FUNCTION"
    case LET = "LET"
    case TRUE = "TRUE"
    case FALSE = "FALSE"
    case IF = "IF"
    case ELSE = "ELSE"
    case RETURN = "RETURN"
	case WHILE = "WHILE"
    
    static let keywords: [String: TokenType] = [
        "fn": .FUNCTION,
        "let": .LET,
        "true": .TRUE,
        "false": .FALSE,
        "if": .IF,
        "else": .ELSE,
        "return": .RETURN,
		"while": .WHILE
    ]
    
    static func lookupIdentifier(identifier: String) -> TokenType {
        if let token = keywords[identifier] {
            return token
        } else {
            return .IDENT
        }
    }
}
