//
//  Lexer.swift
//  monkey-swift
//
//  Created by huangwei on 2021/3/6.
//

import Foundation

public struct Lexer {
    let input: String           // the whole input source code
    var position: Int           // current position in input
    var readPosition: Int       // current reading position in input (after current character)
    var ch : Character          // current character under examination
    
    public init(input: String) {
        self.input = input
        position = 0
        readPosition = 0
        ch = Character(Unicode.Scalar(0))
        readChar()
    }
    
    public mutating func readChar() {
        if readPosition >= input.count {
            ch = Character(Unicode.Scalar(0))
        } else {
            let readPositionIndex = input.index(input.startIndex, offsetBy: readPosition)
            ch = input[readPositionIndex]
        }
        position = readPosition
        readPosition += 1
    }
    
    public mutating func nextToken() -> Token {
        let token: Token
        
        skipWhitespace()
        
        switch (ch) {
            case "=":
                if peekCharacter() == "=" {
                    let prevCh = ch
                    readChar()
                    let literal = String(prevCh) + String(ch)
                    token = Token(tokenType: .EQ, literal: literal)
                } else {
                    token = Token(tokenType: .ASSIGN, literal: String(ch))
                }
            case ";":
                token = Token(tokenType: .SEMICOLON, literal: String(ch))
            case "(":
                token = Token(tokenType: .LPAREN, literal: String(ch))
            case ")":
                token = Token(tokenType: .RPAREN, literal: String(ch))
            case ",":
                token = Token(tokenType: .COMMA, literal: String(ch))
            case "+":
                token = Token(tokenType: .PLUS, literal: String(ch))
            case "{":
                token = Token(tokenType: .LBRACE, literal: String(ch))
            case "}":
                token = Token(tokenType: .RBRACE, literal: String(ch))
            case "[":
                token = Token(tokenType: .LBRACKET, literal: String(ch))
            case "]":
                token = Token(tokenType: .RBRACKET, literal: String(ch))
            case "-":
                token = Token(tokenType: .MINUS, literal: String(ch))
            case "!":
                if peekCharacter() == "=" {
                    let prevCh = ch
                    readChar()
                    let literal = String(prevCh) + String(ch)
                    token = Token(tokenType: .NOT_EQ, literal: literal)
                } else {
                    token = Token(tokenType: .BANG, literal: String(ch))
                }
            case "/":
                token = Token(tokenType: .SLASH, literal: String(ch))
            case "*":
                token = Token(tokenType: .ASTERISK, literal: String(ch))
            case "<":
                token = Token(tokenType: .LT, literal: String(ch))
            case ">":
                token = Token(tokenType: .GT, literal: String(ch))
            case "\"":
                token = Token(tokenType: .STRING, literal: readString())
            case Character(Unicode.Scalar(0)):
                token = Token(tokenType: .EOF, literal: "")
            default:
                if ch.isLetter() {
                    let literal = readIdentifier()
                    token = Token(tokenType: TokenType.lookupIdentifier(identifier: literal), literal: literal)
                    // be careful! return token early on! just in case the last component won't get detected!
                    return token
                } else if ch.isDigit() {
                    let literal = readNumber()
                    token = Token(tokenType: .INT, literal: literal)
                    // be careful! return token early on! just in case the last component won't get detected!
                    return token
                } else {
                    token = Token(tokenType: .ILLEGAL, literal: String(ch))
                }
        }
        
        readChar()
        return token
    }
    
    mutating func readIdentifier() -> String {
        let prevPosition = position
        
        while ch.isLetter() {
            readChar()
        }
        
        let startIndex = input.index(input.startIndex, offsetBy: prevPosition)
        let endIndex = input.index(input.startIndex, offsetBy: position)
        
        return String(input[startIndex ..< endIndex])
    }
    
    mutating func readNumber() -> String {
        let prevPosition = position
        
        while ch.isDigit() {
            readChar()
        }
        
        let startIndex = input.index(input.startIndex, offsetBy: prevPosition)
        let endIndex = input.index(input.startIndex, offsetBy: position)
        
        return String(input[startIndex ..< endIndex])
    }
    
    mutating func readString() -> String {
        let prevPosition = position + 1
        
        repeat {
            readChar()
        } while ch != "\"" && ch != Character(Unicode.Scalar(0))
        
        let startIndex = input.index(input.startIndex, offsetBy: prevPosition)
        let endIndex = input.index(input.startIndex, offsetBy: position)
        
        return String(input[startIndex ..< endIndex])
    }
    
    mutating func skipWhitespace() {
        while ch == " " || ch == "\t" || ch == "\n" || ch == "\r" {
            readChar()
        }
    }
    
    func peekCharacter() -> Character {
        if readPosition >= input.count {
            return Character(Unicode.Scalar(0))
        } else {
            let index = input.index(input.startIndex, offsetBy: readPosition)
            return input[index]
        }
    }
}

extension Character {
    func isLetter() -> Bool {
        return ("a" <= self && self <= "z") || ("A" <= self && self <= "Z") || self == "_"
    }
    
    func isDigit() -> Bool {
        return ("0" <= self && self <= "9")
    }
}
