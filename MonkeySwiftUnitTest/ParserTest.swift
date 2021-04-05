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
        let parser = Parser(lexer: lexer)
        
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
        let parser = Parser(lexer: lexer)
        
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
        let parser = Parser(lexer: lexer)
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
    
    func testIntegerLiteralExpression() {
        let input = "5;"
        
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        if program.statements.count != 1 {
            XCTFail("program has not enough statements. got=\(program.statements.count)")
            return
        }
        
        guard let expressionStatement = program.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let literal = expressionStatement.expression as? Ast.IntegerLiteral else {
            XCTFail("expression is not Ast.IntegerLiteral, got=\(type(of: expressionStatement.expression))")
            return
        }
        
        if literal.value != 5 {
            XCTFail("literal.value not 5, got=\(literal.value)")
            return
        }
        
        if literal.tokenLiteral() != "5" {
            XCTFail("literal.tokenLiteral not 5, got=\(literal.tokenLiteral())")
        }
    }
    
    func testParsingPrefixExpressions() {
        struct PrefixTest {
            let input: String
            let `operator`: String
            let integerValue: Int64
        }
        
        let prefixTests: [PrefixTest] = [
            PrefixTest(input: "!5", operator: "!", integerValue: 5),
            PrefixTest(input: "-15", operator: "-", integerValue: 15)
        ]
        
        for (_, prefixTest) in prefixTests.enumerated() {
            let lexer = Lexer(input: prefixTest.input)
            let parser = Parser(lexer: lexer)
            let optionalProgram = parser.parseProgram()
            checkParserErrors(parser)
            
            guard let program = optionalProgram else {
                XCTFail("parser.parseProgram() is returning nil")
                return
            }
            
            if program.statements.count != 1 {
                XCTFail("program has not enough statements. got=\(program.statements.count)")
                return
            }
            
            guard let expressionStatement = program.statements[0] as? Ast.ExpressionStatement else {
                XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
                return
            }
            
            guard let expression = expressionStatement.expression as? Ast.PrefixExpression else {
                XCTFail("expression is not Ast.InfixExpression, got=\(type(of: expressionStatement.expression))")
                return
            }
            
            if expression.`operator` != prefixTest.`operator` {
                XCTFail("expression.operator is not \(prefixTest.`operator`), got=\(expression.`operator`)")
                return
            }
            
            if !testIntegerLiteral(expression.right, prefixTest.integerValue) {
                return
            }
        }
    }
    
    private func testIntegerLiteral(_ expression: Expression, _ value: Int64) -> Bool {
        guard let integer = expression as? Ast.IntegerLiteral else {
            XCTFail("expression is not Ast.IntegerLiteral. got=\(type(of: expression))")
            return false
        }
        
        if integer.value != value {
            XCTFail("integer.value not \(value). got=\(integer.value)")
            return false
        }
        
        if integer.tokenLiteral() != "\(value)" {
            XCTFail("integer.tokenLiteral() not \(value). got=\(integer.tokenLiteral())")
            return false
        }
        
        return true
    }
    
    private func checkParserErrors(_ parser: Parser) {
        let errors = parser.Errors()
        
        if errors.isEmpty {
            return
        }
        
        for error in errors {
            XCTFail("parser error: \(error)")
        }
        XCTFail("parser has \(errors.count) errors")
    }

}
