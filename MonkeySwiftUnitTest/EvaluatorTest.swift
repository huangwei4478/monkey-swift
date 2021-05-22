//
//  EvaluatorTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/5/9.
//

import XCTest

@testable import MonkeySwift

class EvaluatorTest: XCTestCase {
    func testEvalIntegerExpression() {
        struct Test {
            let input: String
            let expected: Int64
            init(_ input: String, _ expected: Int64) {
                self.input = input
                self.expected = expected
            }
        }
        
        let tests: [Test] = [
            Test("5", 5),
            Test("10", 10)
        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            let _ = testIntegerObject(object: evaluated, expected: test.expected)
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
    
    
}
