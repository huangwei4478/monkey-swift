//
//  ParserTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/3/13.
//

import XCTest

@testable import MonkeySwift

class ParserTest: XCTestCase {
    
    struct Expected {
        let identifier: String
    }
    
    func testLetStatement() {
        let input = """
            let x = 5;
            let y = 10;
            let foobar = 898989;
        """
        
        let lexer = Lexer(input: input)
        var parser = Parser(lexer: lexer)
        
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parsedProgram() returned nil")
            return
        }
        
        guard program.statements.count == 3 else {
            XCTFail("program.statements does not contain 3 statements. got=\(program.statements.count)")
            return
        }
        
        let tests: [Expected] = [
            Expected(identifier: "x"),
            Expected(identifier: "y"),
            Expected(identifier: "foobar")
        ]
        
        for (index, test) in tests.enumerated() {
            let statement = program.statements[index]
            if !letStatementTestHelper(statement: statement, name: test.identifier) {
                return
            }
        }
    }
    
    private func letStatementTestHelper(statement: Statement, name: String) -> Bool {
        if statement.tokenLiteral() != "let" {
            XCTFail("s.Tokenliteral not 'let'. got=\(statement.tokenLiteral())")
            return false
        }
        
        guard let letStatement = statement as? Ast.LetStatement else {
            XCTFail("s not Ast.LetStatement. got=\(statement)")
            return false
        }
        
        if letStatement.name.value != name {
            XCTFail("letStatement.name.value not \(name). got=\(letStatement.name.value)")
            return false
        }
        
        if letStatement.name.tokenLiteral() != name {
            XCTFail("letStatement.name.tokenLiteral not \(name), got=\(letStatement.name.tokenLiteral())")
            return false
        }
        
        return true
    }
    
    func testReturnStatement() {
        let input = """
            return 5;
            return 10;
            return 993322;
        """
        
        let lexer = Lexer(input: input)
        var parser = Parser(lexer: lexer)
        
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        guard program.statements.count == 3 else {
            XCTFail("program.Statements does not contain 3 statements. got=\(program.statements.count)")
            return
        }
        
        for (_, statement) in program.statements.enumerated() {
            guard let returnStatement = statement as? Ast.ReturnStatement else {
                XCTFail("statement is not Ast.ReturnStatement. got=\(statement)")
                continue
            }
            
            guard returnStatement.tokenLiteral() == "return" else {
                XCTFail("returnStatement.tokenLiteral not 'return', got=\(returnStatement.tokenLiteral())")
                continue
            }
        }
    }
    
    func testIdentifierExpression() {
        let input = "foobar;"
        
        let lexer = Lexer(input: input)
        var parser = Parser(lexer: lexer)
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        if program.statements.count != 1 {
            XCTFail(String(format: "program has not enough statements. got=%d", program.statements.count))
            return
        }
        
        guard let expressionStatement = program.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let identifier = expressionStatement.expression as? Ast.Identifier else {
            XCTFail("expression not Ast.Identifier. got=\(type(of: expressionStatement.expression))")
            return
        }
        
        guard identifier.value == "foobar" else {
            XCTFail("identifier.value not \("foobar"). got=\(identifier.value)")
            return
        }
        
        guard identifier.tokenLiteral() == "foobar" else {
            XCTFail("identifier.tokenLiteral() not \("foobar"). got=\(identifier.tokenLiteral())")
            return
        }
    }
    
    private func checkParserErrors(_ parser: Parser) {
        let errors = parser.errors
        
        if errors.isEmpty {
            return
        }
        
        for error in errors {
            XCTFail("parser error: \(error)")
        }
        XCTFail("parser has \(errors.count) errors")
    }

}
