//
//  monkey_testing.swift
//  monkey-testing
//
//  Created by huangwei on 2021/3/6.
//

import XCTest

@testable import monkey_swift

class monkey_testing: XCTestCase {
    
    func testNextToken() throws {
        
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
        """
        
        let lexer = Lexer(input: input, position: 0, readPosition: 0, ch: Character.init(""))
        
        struct ExpectedToken {
            let expectedType: TokenType
            let expectedLiteral: String
        }
        
        let tests: [ExpectedToken] = [
//            {token.LET, "let"},
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
//                    {token.IDENT, "five"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "five"),
//                    {token.ASSIGN, "="},
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
//                    {token.INT, "5"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.LET, "let"},
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
//                    {token.IDENT, "ten"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "ten"),
//                    {token.ASSIGN, "="},
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
//                    {token.INT, "10"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.LET, "let"},
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
//                    {token.IDENT, "add"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "add"),
//                    {token.ASSIGN, "="},
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
//                    {token.FUNCTION, "fn"},
            ExpectedToken(expectedType: .FUNCTION, expectedLiteral: "fn"),
//                    {token.LPAREN, "("},
            ExpectedToken(expectedType: .LPAREN, expectedLiteral: "("),
//                    {token.IDENT, "x"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "x"),
//                    {token.COMMA, ","},
            ExpectedToken(expectedType: .COMMA, expectedLiteral: ","),
//                    {token.IDENT, "y"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "y"),
//                    {token.RPAREN, ")"},
            ExpectedToken(expectedType: .RPAREN, expectedLiteral: ")"),
//                    {token.LBRACE, "{"},
            ExpectedToken(expectedType: .LBRACE, expectedLiteral: "{"),
//                    {token.IDENT, "x"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "x"),
//                    {token.PLUS, "+"},
            ExpectedToken(expectedType: .PLUS, expectedLiteral: "+"),
//                    {token.IDENT, "y"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "y"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.RBRACE, "}"},
            ExpectedToken(expectedType: .RBRACE, expectedLiteral: "}"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.LET, "let"},
            ExpectedToken(expectedType: .LET, expectedLiteral: "let"),
//                    {token.IDENT, "result"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "result"),
//                    {token.ASSIGN, "="},
            ExpectedToken(expectedType: .ASSIGN, expectedLiteral: "="),
//                    {token.IDENT, "add"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "add"),
//                    {token.LPAREN, "("},
            ExpectedToken(expectedType: .LPAREN, expectedLiteral: "("),
//                    {token.IDENT, "five"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "five"),
//                    {token.COMMA, ","},
            ExpectedToken(expectedType: .COMMA, expectedLiteral: ","),
//                    {token.IDENT, "ten"},
            ExpectedToken(expectedType: .IDENT, expectedLiteral: "ten"),
//                    {token.RPAREN, ")"},
            ExpectedToken(expectedType: .RPAREN, expectedLiteral: ")"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.BANG, "!"},
            ExpectedToken(expectedType: .BANG, expectedLiteral: "!"),
//                    {token.MINUS, "-"},
            ExpectedToken(expectedType: .MINUS, expectedLiteral: "-"),
//                    {token.SLASH, "/"},
            ExpectedToken(expectedType: .SLASH, expectedLiteral: "/"),
//                    {token.ASTERISK, "*"},
            ExpectedToken(expectedType: .ASTERISK, expectedLiteral: "*"),
//                    {token.INT, "5"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.INT, "5"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
//                    {token.LT, "<"},
            ExpectedToken(expectedType: .LT, expectedLiteral: "<"),
//                    {token.INT, "10"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
//                    {token.GT, ">"},
            ExpectedToken(expectedType: .GT, expectedLiteral: ">"),
//                    {token.INT, "5"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.IF, "if"},
            ExpectedToken(expectedType: .IF, expectedLiteral: "if"),
//                    {token.LPAREN, "("},
            ExpectedToken(expectedType: .LPAREN, expectedLiteral: "("),
//                    {token.INT, "5"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "5"),
//                    {token.LT, "<"},
            ExpectedToken(expectedType: .LT, expectedLiteral: "<"),
//                    {token.INT, "10"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
//                    {token.RPAREN, ")"},
            ExpectedToken(expectedType: .RPAREN, expectedLiteral: ")"),
//                    {token.LBRACE, "{"},
            ExpectedToken(expectedType: .LBRACE, expectedLiteral: "{"),
//                    {token.RETURN, "return"},
            ExpectedToken(expectedType: .RETURN, expectedLiteral: "return"),
//                    {token.TRUE, "true"},
            ExpectedToken(expectedType: .TRUE, expectedLiteral: "true"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.RBRACE, "}"},
            ExpectedToken(expectedType: .RBRACE, expectedLiteral: "}"),
//                    {token.ELSE, "else"},
            ExpectedToken(expectedType: .ELSE, expectedLiteral: "else"),
//                    {token.LBRACE, "{"},
            ExpectedToken(expectedType: .LBRACE, expectedLiteral: "{"),
//                    {token.RETURN, "return"},
            ExpectedToken(expectedType: .RETURN, expectedLiteral: "return"),
//                    {token.FALSE, "false"},
            ExpectedToken(expectedType: .FALSE, expectedLiteral: "false"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.RBRACE, "}"},
            ExpectedToken(expectedType: .RBRACE, expectedLiteral: "}"),
//                    {token.INT, "10"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
//                    {token.EQ, "=="},
            ExpectedToken(expectedType: .EQ, expectedLiteral: "=="),
//                    {token.INT, "10"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.INT, "10"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "10"),
//                    {token.NOT_EQ, "!="},
            ExpectedToken(expectedType: .NOT_EQ, expectedLiteral: "!="),
//                    {token.INT, "9"},
            ExpectedToken(expectedType: .INT, expectedLiteral: "9"),
//                    {token.SEMICOLON, ";"},
            ExpectedToken(expectedType: .SEMICOLON, expectedLiteral: ";"),
//                    {token.EOF, ""},
            ExpectedToken(expectedType: .EOF, expectedLiteral: "")
        ]
        
        for (index, testToken) in tests.enumerated() {
            let token = lexer.nextToken()
            
            XCTAssertEqual(token.tokenType, testToken.expectedType, "testes[\(index)] - tokentype wrong. expected=\(testToken.expectedType.rawValue), got=\(token.tokenType.rawValue).")
            
            XCTAssertEqual(token.literal, ,testToken.expectedLiteral, "test[\(index)] - tokenLiteral wrong. expected=\(testToken.expectedLiteral), got=\(token.literal)")
        }
    }

}
