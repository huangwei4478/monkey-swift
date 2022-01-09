//
//  AstTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/3/28.
//

import XCTest

class AstTest: XCTestCase {
    func testString() {
        let program = Ast.Program(statements: [
            Ast.LetStatement(token: Token(tokenType: .LET, literal: "let"),
                             name: Ast.Identifier(token: Token(tokenType: .IDENT,
                                                               literal: "myVar"),
                                                  value: "myVar"),
                             value: Ast.Identifier(token: Token(tokenType: .IDENT,
                                                                literal: "anotherVar"),
                                                   value: "anotherVar"))
        ])
        
        XCTAssertEqual(program.string(), "let myVar = anotherVar;",
                       String(format: "program.string() wrong. got=%q", program.string()))
    }
}
