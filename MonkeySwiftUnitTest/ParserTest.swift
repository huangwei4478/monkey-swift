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
            let value: Any
            
            init(_ input: String, _ `operator`: String, _ value: Any) {
                self.input = input
                self.`operator` = `operator`
                self.value = value
            }
        }
        
        let prefixTests: [PrefixTest] = [
            PrefixTest("!5", "!", 5),
            PrefixTest("-15", "-", 15),
            PrefixTest("!true;", "!", true),
            PrefixTest("!false;", "!", false)
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
                XCTFail("expression is not Ast.PrefixExpression, got=\(type(of: expressionStatement.expression))")
                return
            }
            
            if expression.`operator` != prefixTest.`operator` {
                XCTFail("expression.operator is not \(prefixTest.`operator`), got=\(expression.`operator`)")
                return
            }
            
            if !testLiteralExpression(expression: expression.right, expected: prefixTest.value) {
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
    
    func testParsingInfixExpressions() {
        struct InfixTest {
            let input: String
            let leftValue: Any
            let `operator`: String
            let rightValue: Any
            
            init(_ input: String, _ leftValue: Any, _ `operator`: String, _ rightValue: Any) {
                self.input = input
                self.leftValue = leftValue
                self.`operator` = `operator`
                self.rightValue = rightValue
            }
        }
        
        let infixTests: [InfixTest] = [
            InfixTest("5 + 5;", 5, "+", 5),
            InfixTest("5 - 5;", 5, "-", 5),
            InfixTest("5 * 5;", 5, "*", 5),
            InfixTest("5 / 5;", 5, "/", 5),
            InfixTest("5 > 5;", 5, ">", 5),
            InfixTest("5 < 5;", 5, "<", 5),
            InfixTest("5 == 5;", 5, "==", 5),
            InfixTest("5 != 5;", 5, "!=", 5),
            InfixTest("true == true", true, "==", true),
            InfixTest("true != false", true, "!=", false),
            InfixTest("false == false", false, "==", false)
        ]
        
        for (_, infixTest) in infixTests.enumerated() {
            let lexer = Lexer(input: infixTest.input)
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
            
            guard let expression = expressionStatement.expression as? Ast.InfixExpression else {
                XCTFail("expression is not Ast.InfixExpression, got=\(type(of: expressionStatement.expression))")
                return
            }
            
            if !testInfixExpression(expression: expression, left: infixTest.leftValue, operator: infixTest.`operator`, right: infixTest.rightValue) {
                return
            }
        }
    }
    
    func testOperatorPrecedenceParsing() {
        struct Test {
            let input: String
            let expected: String
            
            init(_ input: String, _ expected: String) {
                self.input = input
                self.expected = expected
            }
        }
        
        let tests: [Test] = [
            Test("-a * b","((-a) * b)"),
            Test("!-a","(!(-a))"),
            Test("a + b + c","((a + b) + c)"),
            Test("a + b - c", "((a + b) - c)"),
            Test("a * b * c", "((a * b) * c)"),
            Test("a * b / c", "((a * b) / c)"),
            Test("a + b / c","(a + (b / c))"),
            Test("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
            Test("3 + 4; -5 * 5","(3 + 4)((-5) * 5)"),
            Test("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
            Test("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
            Test("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
            Test("true", "true"),
            Test("false", "false"),
            Test("3 > 5 == false", "((3 > 5) == false)"),
            Test("3 < 5 == true", "((3 < 5) == true)"),
            Test("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
            Test("2 / (5 + 5)", "(2 / (5 + 5))"),
            Test("- (5 + 5)", "(-(5 + 5))"),
            Test("!(true == true)", "(!(true == true))"),
            Test("a + add(b * c) + d", "((a + add((b * c))) + d)"),
            Test("add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
            Test("add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))")
        ]
        
        for (_, test) in tests.enumerated() {
            let lexer = Lexer(input: test.input)
            let parser = Parser(lexer: lexer)
            let optionalProgram = parser.parseProgram()
            checkParserErrors(parser)
            
            guard let program = optionalProgram else {
                XCTFail("parser.parseProgram() is returning nil")
                return
            }
            
            let actual = program.string()
            if actual != test.expected {
                XCTFail("expected=\(test.expected), got=\(actual)")
            }
        }
    }
    
    func testBooleanExpression() {
        struct Test {
            let input: String
            
            let expectedBoolean: Bool
            
            init(_ input: String, _ expectedBoolean: Bool) {
                self.input = input
                self.expectedBoolean = expectedBoolean
            }
        }
        
        let tests: [Test] = [
            Test("true;", true),
            Test("false;", false)
        ]
        
        for (_, test) in tests.enumerated() {
            let lexer = Lexer(input: test.input)
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
            
            guard let boolean = expressionStatement.expression as? Ast.Boolean else {
                XCTFail("expression not Ast.Boolean. got=\(type(of: expressionStatement.expression))")
                return
            }
            
            if boolean.value != test.expectedBoolean {
                XCTFail("boolean value not \(test.expectedBoolean). got=\(boolean.value)")
                return
            }
        }
        
        
    }
    
    func testIfExpression() {
        let input = "if (x < y) { x }"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        guard let expressionStatement = program.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let ifExpression = expressionStatement.expression as? Ast.IfExpression else {
            XCTFail("expression not Ast.IfExpression. got=\(type(of: expressionStatement.expression))")
            return
        }
        
        if !testInfixExpression(expression: ifExpression.condition, left: "x", operator: "<", right: "y") {
            return
        }
        
        if ifExpression.consequence.statements.count != 1 {
            XCTFail("consequence is not 1 statements. got=\(ifExpression.consequence.statements.count)")
            return
        }
        
        guard let consequence = ifExpression.consequence.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("statements[0] is not Ast.ExpressionStatement. got=\(type(of: ifExpression.consequence.statements[0]))")
            return
        }
        
        if !testIdentifier(expression: consequence.expression, value: "x") {
            return
        }
        
        if let _ = ifExpression.alternative {
            XCTFail("ifExpression.Alternative was not nil. got=\(String(describing: ifExpression.alternative))")
            return
        }
    }
    
    func testIfElseExpression() {
        let input = "if (x < y) { x } else { y }"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        guard let expressionStatement = program.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let ifExpression = expressionStatement.expression as? Ast.IfExpression else {
            XCTFail("expression not Ast.IfExpression. got=\(type(of: expressionStatement.expression))")
            return
        }
        
        if !testInfixExpression(expression: ifExpression.condition, left: "x", operator: "<", right: "y") {
            return
        }
        
        if ifExpression.consequence.statements.count != 1 {
            XCTFail("consequence is not 1 statements. got=\(ifExpression.consequence.statements.count)")
            return
        }
        
        guard let consequence = ifExpression.consequence.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("consequence.statements[0] is not Ast.ExpressionStatement. got=\(type(of: ifExpression.consequence.statements[0]))")
            return
        }
        
        if !testIdentifier(expression: consequence.expression, value: "x") {
            return
        }
        
        guard let alternative = ifExpression.alternative?.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("alternative.statements[0] is not Ast.ExpressionStatement. got=\(type(of: String(describing: ifExpression.alternative?.statements[0])))")
            return
        }
        
        if !testIdentifier(expression: alternative.expression, value: "y") {
            return
        }
    }
    
    private func testIdentifier(expression: Expression, value: String) -> Bool {
        guard let identifier = expression as? Ast.Identifier else {
            XCTFail("expression not Ast.Expression. got=\(type(of: expression))")
            return false;
        }
        
        if identifier.value != value {
            XCTFail("identifier.value not \(value). got=\(identifier.value)")
            return false
        }
        
        if identifier.tokenLiteral() != value {
            XCTFail("identifier.tokenLiteral() not \(value). got=\(identifier.tokenLiteral())")
            return false
        }
        
        return true
    }
    
    private func testBooleanLiteral(expression: Expression, value: Bool) -> Bool {
        guard let boolean = expression as? Ast.Boolean else {
            XCTFail("expression not Ast.Boolean. got=\(type(of: expression))")
            return false
        }
        
        if boolean.value != value {
            XCTFail("boolean.value not \(value). got=\(boolean.value)")
            return false
        }
        
        if boolean.tokenLiteral() != "\(value)" {
            XCTFail("boolean.tokenLiteral() not \(value). got=\(boolean.tokenLiteral())")
            return false
        }
        
        return true
    }
    
    private func testLiteralExpression(expression: Expression, expected: Any) -> Bool {
        switch expected {
        case let intValue as Int:           return testIntegerLiteral(expression, Int64(intValue))
        case let int64Value as Int64:       return testIntegerLiteral(expression, int64Value)
        case let stringValue as String:     return testIdentifier(expression: expression, value: stringValue)
        case let boolValue as Bool:         return testBooleanLiteral(expression: expression, value: boolValue)
        default:
            XCTFail("type of expression not handled. got=\(type(of: expected))")
            return false
        }
    }
    
    private func testInfixExpression(expression: Expression, left: Any, operator: String, right: Any) -> Bool {
        guard let infixExpression = expression as? Ast.InfixExpression else {
            XCTFail("expression is not Ast.InfixExpression. got=\(type(of: expression))(\(expression))")
            return false
        }
        
        if !testLiteralExpression(expression: infixExpression.left, expected: left) { return false; }
        
        if infixExpression.`operator` != `operator` {
            XCTFail("infixExpression.operator not \(`operator`). got=\(infixExpression.`operator`)")
            return false
        }
        
        if !testLiteralExpression(expression: infixExpression.right, expected: right) { return false; }
        
        return true;
    }
    
    func testFunctionLiteralParsing() {
        let input = "fn(x, y) { x + y; }"
        
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        guard let expressionStatement = program.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let function = expressionStatement.expression as? Ast.FunctionLiteral else {
            XCTFail("expressionStatement.expression is not Ast.FunctionLiteral. got=\(type(of: expressionStatement.expression))")
            return
        }
        
        if function.parameters.count != 2 {
            XCTFail("function literal parameters wrong. want 2, got=\(function.parameters.count)")
            return
        }
        
        let _ = testLiteralExpression(expression: function.parameters[0], expected: "x")
        let _ = testLiteralExpression(expression: function.parameters[1], expected: "y")
        
        if function.body.statements.count != 1 {
            XCTFail("function.body.statements has not 1 statement. got=\(function.body.statements.count)")
            return
        }
        
        guard let bodyStatement = function.body.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("function body statement is not Ast.ExpressionStatement. got=\(type(of: function.body.statements[0]))")
            return
        }
        
        if !testInfixExpression(expression: bodyStatement.expression, left: "x", operator: "+", right: "y") {
            return
        }
    }
    
    func testFunctionParameterParsing() {
        struct Test {
            let input: String
            let expectedParams: [String]
        }
        
        let tests: [Test] = [
            Test(input: "fn() {};", expectedParams: []),
            Test(input: "fn(x) {};", expectedParams: ["x"]),
            Test(input: "fn(x, y, z) {};", expectedParams: ["x", "y", "z"])
        ]
        
        for test in tests {
            let lexer = Lexer(input: test.input)
            let parser = Parser(lexer: lexer)
            let optionalProgram = parser.parseProgram()
            
            guard let program = optionalProgram else {
                XCTFail("parser.parseProgram() is returning nil")
                return
            }
            
            guard let statement = program.statements[0] as? Ast.ExpressionStatement else {
                XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
                return
            }
            
            guard let function = statement.expression as? Ast.FunctionLiteral else {
                XCTFail("statement.expression is not Ast.FunctionLiteral. got=\(type(of: statement.expression))")
                return
            }
            
            if function.parameters.count != test.expectedParams.count {
                XCTFail("length parameter wrong. want \(test.expectedParams.count), got=\(function.parameters.count)")
                return
            }
            
            for (index, identifier) in test.expectedParams.enumerated() {
                let _ = testLiteralExpression(expression: function.parameters[index], expected: identifier)
            }
        }
    }
    
    func testCallExpressionParsing() {
        let input = "add(1, 2 * 3, 4 + 5);"
        
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let optionalProgram = parser.parseProgram()
        checkParserErrors(parser)
        
        guard let program = optionalProgram else {
            XCTFail("parser.parseProgram() is returning nil")
            return
        }
        
        guard let statement = program.statements[0] as? Ast.ExpressionStatement else {
            XCTFail("program.statement[0] is not ast.ExpressionStatement. got=\(type(of: program.statements[0]))")
            return
        }
        
        guard let callExpression = statement.expression as? Ast.CallExpression else {
            XCTFail("statement.expression is not Ast.CallExpression. got=\(type(of: statement.expression))")
            return
        }
        
        if !testIdentifier(expression: callExpression.function, value: "add") {
            return
        }
        
        if callExpression.arguments.count != 3 {
            XCTFail("wrong length of arguments. got=\(callExpression.arguments.count)")
            return
        }
        
        let _ = testLiteralExpression(expression: callExpression.arguments[0], expected: 1)
        let _ = testInfixExpression(expression: callExpression.arguments[1], left: 2, operator: "*", right: 3)
        let _ = testInfixExpression(expression: callExpression.arguments[2], left: 4, operator: "+", right: 5)
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
