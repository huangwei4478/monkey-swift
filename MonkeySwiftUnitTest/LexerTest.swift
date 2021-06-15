//
//  LexerTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/3/13.
//

import XCTest

@testable import MonkeySwift

class LexerTest: XCTestCase {
    
    private struct ExpectedToken {
        let expectedType: TokenType
        let expectedLiteral: String
    }
    
    private func examine(with input: String, testTokens: [ExpectedToken]) {
        var lexer = Lexer(input: input)
        
        for (index, testToken) in testTokens.enumerated() {
            let token = lexer.nextToken()
            XCTAssertEqual(token.tokenType, testToken.expectedType, "test[\(index)] - tokentype wrong. expected=\(testToken.expectedType.rawValue), got=\(token.tokenType.rawValue).")
            XCTAssertEqual(token.literal, testToken.expectedLiteral, "test[\(index)] - tokenLiteral wrong. expected=\(testToken.expectedLiteral), got=\(token.literal)")
        }
    }
    
    func testNextToken01() throws {
        let input = """
            ;
        """
        
        let tests: [ExpectedToken] = [
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";")
        ]
        
        examine(with: input, testTokens: tests)
    }
    
    func testNextToken02() throws {
        let input = """
            10 == a;
        """
        
        let tests: [ExpectedToken] = [
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .EQ, expectedLiteral: "=="),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "a"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";")
        ]
        
        examine(with: input, testTokens: tests)
    }

    func testNextToken03() throws {
        let input = """
            let q = 4;
        """
        let tests: [ExpectedToken] = [
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "q"),
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
            ExpectedToken(expectedType: .INT, expectedLiteral: "4"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";")
        ]
        
        examine(with: input, testTokens: tests)
    }
    
    func testNextToken04() throws {
        
        let input = """
        let five = 5;
        let ten = 10;

        let add = fn(x, y) {
          x + y;
        };

        let result = add(five, ten);
        !-/*5;
        5 < 10 > 5;

        if (5 < 10) {
            return true;
        } else {
            return false;
        }

        10 == 10;
        10 != 9;
        "foobar"
        "foo bar"
        [1, 2];
        """
        
        let tests: [ExpectedToken] = [
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "five"),
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "ten"),
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "add"),
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
            ExpectedToken(expectedType: .FUNCTION, expectedLiteral: "fn"),
            ExpectedToken(expectedType: .LPAREN, expectedLiteral: "("),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "x"),
            ExpectedToken(expectedType: .COMMA, expectedLiteral: ","),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "y"),
            ExpectedToken(expectedType: .RPAREN, expectedLiteral: ")"),
            ExpectedToken(expectedType: .LBRACE, expectedLiteral: "{"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "x"),
            ExpectedToken(expectedType: .PLUS, expectedLiteral: "+"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "y"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .RBRACE, expectedLiteral: "}"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "result"),
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "add"),
            ExpectedToken(expectedType: .LPAREN, expectedLiteral: "("),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "five"),
            ExpectedToken(expectedType: .COMMA, expectedLiteral: ","),
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "ten"),
            ExpectedToken(expectedType: .RPAREN, expectedLiteral: ")"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .BANG, expectedLiteral: "!"),
            ExpectedToken(expectedType: .MINUS, expectedLiteral: "-"),
            ExpectedToken(expectedType: .SLASH, expectedLiteral: "/"),
            ExpectedToken(expectedType: .ASTERISK, expectedLiteral: "*"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
            ExpectedToken(expectedType: .LT, expectedLiteral: "<"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .GT, expectedLiteral: ">"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .IF, expectedLiteral: "if"),
            ExpectedToken(expectedType: .LPAREN, expectedLiteral: "("),
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
            ExpectedToken(expectedType: .LT, expectedLiteral: "<"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .RPAREN, expectedLiteral: ")"),
            ExpectedToken(expectedType: .LBRACE, expectedLiteral: "{"),
            ExpectedToken(expectedType: .RETURN, expectedLiteral: "return"),
            ExpectedToken(expectedType: .TRUE, expectedLiteral: "true"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .RBRACE, expectedLiteral: "}"),
            ExpectedToken(expectedType: .ELSE, expectedLiteral: "else"),
            ExpectedToken(expectedType: .LBRACE, expectedLiteral: "{"),
            ExpectedToken(expectedType: .RETURN, expectedLiteral: "return"),
            ExpectedToken(expectedType: .FALSE, expectedLiteral: "false"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .RBRACE, expectedLiteral: "}"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .EQ, expectedLiteral: "=="),
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
            ExpectedToken(expectedType: .NOT_EQ, expectedLiteral: "!="),
            ExpectedToken(expectedType: .INT, expectedLiteral: "9"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .STRING, expectedLiteral: "foobar"),
            ExpectedToken(expectedType: .STRING, expectedLiteral: "foo bar"),
            ExpectedToken(expectedType: .LBRACKET, expectedLiteral: "["),
            ExpectedToken(expectedType: .INT, expectedLiteral: "1"),
            ExpectedToken(expectedType: .COMMA, expectedLiteral: ","),
            ExpectedToken(expectedType: .INT, expectedLiteral: "2"),
            ExpectedToken(expectedType: .RBRACKET, expectedLiteral: "]"),
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
            ExpectedToken(expectedType: .EOF, expectedLiteral: "")
        ]
        
        examine(with: input, testTokens: tests)
    }
}
