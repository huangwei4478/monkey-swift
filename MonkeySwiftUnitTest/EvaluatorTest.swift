//
//  EvaluatorTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/5/9.
//

import XCTest

@testable import MonkeySwift

class EvaluatorTest: XCTestCase {
    
    struct TestCase<T> {
        let input: String
        let expected: T
        init(_ input: String, _ expected: T) {
            self.input = input
            self.expected = expected
        }
    }
    
    func testEvalIntegerExpression() {
        let tests: [TestCase<Int64>] = [
            TestCase("5", 5),
            TestCase("10", 10),
            TestCase("-5", -5),
            TestCase("-10", -10),
            TestCase("5 + 5 + 5 + 5 - 10", 10),
            TestCase("2 * 2 * 2 * 2 * 2", 32),
            TestCase("-50 + 100 + -50", 0),
            TestCase("5 * 2 + 10", 20),
            TestCase("5 + 2 * 10", 25),
            TestCase("20 + 2 * -10", 0),
            TestCase("50 / 2 * 2 + 10", 60),
            TestCase("2 * (5 + 10)", 30),
            TestCase("3 * 3 * 3 + 10", 37),
            TestCase("3 * (3 * 3) + 10", 37),
            TestCase("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50),
        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            let _ = testIntegerObject(object: evaluated, expected: test.expected)
        }
    }
    
    func testEvalBooleanExpression() {
        let tests: [TestCase<Bool>] = [
            TestCase("true", true),
            TestCase("false", false),
            TestCase("1 < 2", true),
            TestCase("1 > 2", false),
            TestCase("1 < 1", false),
            TestCase("1 > 1", false),
            TestCase("1 == 1", true),
            TestCase("1 != 1", false),
            TestCase("1 == 2", false),
            TestCase("1 != 2", true),
            TestCase("true == true", true),
            TestCase("false == false", true),
            TestCase("true == false", false),
            TestCase("true != false", true),
            TestCase("false != true", true),
            TestCase("(1 < 2) == true", true),
            TestCase("(1 < 2) == false", false),
            TestCase("(1 > 2) == true", false),
            TestCase("(1 > 2) == false", true),

        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            let _ = testBooleanObject(object: evaluated, expected: test.expected)
        }
    }
    
    func testBangOperator() {
        let tests: [TestCase<Bool>] = [
            TestCase("!true", false),
            TestCase("!false", true),
            TestCase("!5", false),
            TestCase("!!true", true),
            TestCase("!!false", false),
            TestCase("!!5", true),
        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            let _ = testBooleanObject(object: evaluated, expected: test.expected)
        }
    }
    
    private func testEval(input: String) -> Object {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        guard let program = parser.parseProgram() else {
            return Object_t.Null()
        }
        
        return Evaluator.eval(program) ?? Object_t.Null()
    }

    private func testIntegerObject(object: Object, expected: Int64) -> Bool {
        guard let result = object as? Object_t.Integer else {
            XCTFail("object is not Integer. got=\(type(of: object))")
            return false
        }
        
        if result.value != expected {
            XCTFail("object has wrong value. got=\(result.value), expected=\(expected)")
            return false
        }
        
        return true
    }
    
    // TODO: try to refactor this into Generics function
    private func testBooleanObject(object: Object, expected: Bool) -> Bool {
        guard let result = object as? Object_t.Boolean else {
            XCTFail("object is not Boolean. got=\(type(of: object))")
            return false
        }
        
        if result.value != expected {
            XCTFail("object has wrong value. got=\(result.value), expected=\(expected)")
            return false
        }
        
        return true
    }
}
