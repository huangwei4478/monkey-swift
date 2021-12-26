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
    
    func testIfElseExpressions() {
        let tests: [TestCase<Int64?>] = [
            TestCase("if (true) { 10 }", 10),
            TestCase("if (false) { 10 }", nil),
            TestCase("if (1) { 10 }", 10),
            TestCase("if (1 < 2) { 10 }", 10),
            TestCase("if (1 > 2) { 10 }", nil),
            TestCase("if (1 > 2) { 10 } else { 20 }", 20),
            TestCase("if (1 < 2) { 10 } else { 20 }", 10),
        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            if let expectedInteger = test.expected {
                let _ = testIntegerObject(object: evaluated, expected: expectedInteger)
            } else {
                let _ = testNullObject(object: evaluated)
            }
        }
    }
	
	func testWhileExpression() {
		let inputs = """
		let x = 1;
		while (x < 10) {
			x = x + 1;
		}
"""
		let evaluated = testEval(input: inputs)
		testIntegerObject(object: evaluated, expected: 11)
	}
    
    func testReturnStatements() {
        let tests: [TestCase<Int64>] = [
            TestCase("return 10;", 10),
            TestCase("return 10; 9;", 10),
            TestCase("return 2 * 5; 9;", 10),
            TestCase("9; return 2 * 5; 9;", 10),
            TestCase("""
                        if (10 > 1) {
                            if (10 > 1) {
                                return 10;
                            }
                        
                            return 1;
                        }
                        
                        """, 10)
        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            let _ = testIntegerObject(object: evaluated, expected: test.expected)
        }
    }
    
    func testErrorHandling() {
        let tests: [TestCase<String>] = [
            TestCase("5 + true;",
                     "type mismatch: INTEGER + BOOLEAN"),
            TestCase("5 + true; 5;",
                     "type mismatch: INTEGER + BOOLEAN"),
            TestCase("-true",
                     "unknown operator: -BOOLEAN"),
            TestCase("true + false;",
                     "unknown operator: BOOLEAN + BOOLEAN"),
            TestCase("true + false + true + false;",
                     "unknown operator: BOOLEAN + BOOLEAN"),
            TestCase("5; true + false; 5",
                     "unknown operator: BOOLEAN + BOOLEAN"),
            TestCase("if (10 > 1) { true + false; }",
                     "unknown operator: BOOLEAN + BOOLEAN"),
            TestCase("""
                    if (10 > 1) {
                      if (10 > 1) {
                        return true + false;
                      }

                      return 1;
                    }
                    """, "unknown operator: BOOLEAN + BOOLEAN"),
            TestCase("foobar", "identifier not found: foobar"),
            TestCase(#""Hello" - "world!""#, "unknown operator: STRING - STRING"),
            TestCase(#"{"name": "Monkey"}[fn(x) { x }]"#, "unusable as hash key: FUNCTION")
        ]
        
        for test in tests {
            let evaluated = testEval(input: test.input)
            
            guard let errorObject = evaluated as? Object_t.Error else {
                XCTFail("no error object returned. got=\(type(of: evaluated))(\(evaluated))")
                continue
            }
            
            if errorObject.message != test.expected {
                XCTFail("wrong error message. expected=\(test.expected), got=\(errorObject.message)")
            }
        }
    }
    
    func testLetStatements() {
        let tests: [TestCase<Int64>] = [
            TestCase("let a = 5; a;", 5),
            TestCase("let a = 5 * 5; a;", 25),
            TestCase("let a = 5; let b = a; b;", 5),
            TestCase("let a = 5; let b = a; let c = a + b + 5; c;", 15),
        ]
        
        for test in tests {
            let _ = testIntegerObject(object: testEval(input: test.input), expected: test.expected)
        }
    }
    
    func testFunctionObject() {
        let input = "fn(x) { x + 2; };"
        
        let evaluated = testEval(input: input)
        
        guard let fn = evaluated as? Object_t.Function else {
            XCTFail("object is not function. got=\(type(of: evaluated)) (\(evaluated))")
            return
        }
        
        guard fn.parameters.count == 1 else {
            XCTFail("function has wrong parameters. Parameters=\(fn.parameters)")
            return
        }
        
        guard fn.parameters[0].string() == "x" else {
            XCTFail("parameter is not 'x'. got=\(fn.parameters[0])")
            return
        }
        
        let expectedBody = "(x + 2)"
        
        guard fn.body.string() == expectedBody else {
            XCTFail("body is not \(expectedBody), got=\(fn.body.string())")
            return
        }
    }
    
    func testFunctionApplication() {
        let tests: [TestCase<Int64>] = [
            TestCase("let identity = fn(x) { x; }; identity(5);", 5),
            TestCase("let identity = fn(x) { return x; }; identity(5);", 5),
            TestCase("let double = fn(x) { x * 2; }; double(5);", 10),
            TestCase("let add = fn(x, y) { x + y; }; add(5, 5);", 10),
            TestCase("let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20),
            TestCase("fn(x) { x; }(5)", 5),
        ]
        
        for test in tests {
           let _ = testIntegerObject(object: testEval(input: test.input), expected: test.expected)
        }
    }
    
    func testCurryClosure() {
        let input = """
                    let newAdder = fn(x) {
                        fn(y) { x + y };
                    };
                    
                    let addTwo = newAdder(2);
                    addTwo(2);
                    """
        let _ = testIntegerObject(object: testEval(input: input), expected: 4)
    }
    
    func testStringLiteral() {
        let input = #""Hello World!""#
        
        let evaluated = testEval(input: input)
        
        guard let string = evaluated as? Object_t.string else {
            XCTFail("object is not string. got=\(type(of: evaluated)) (\(evaluated))")
            return
        }
        
        guard string.value == "Hello World!" else {
            XCTFail("string has wrong value. got=\(string.value)")
            return
        }
    }
    
    func testStringConcatenation() {
        let input = #""Hello" + " " + "World!""#

        let evaluated = testEval(input: input)

        guard let string = evaluated as? Object_t.string else {
            XCTFail("object is not string. got=\(type(of: evaluated)) (\(evaluated))")
            return
        }

        guard string.value == "Hello World!" else {
            XCTFail("string has wrong value. got=\(string.value)")
            return
        }
    }
    
    func testBuiltinFunctions() {
        let tests: [TestCase<Any>] = [
            TestCase(#"len("")"#, 0),
            TestCase(#"len("four")"#, 4),
            TestCase(#"len("hello world")"#, 11),
            TestCase(#"len(1)"#, #"argument to `len` not supported, got=INTEGER"#),
            TestCase(#"len("one", "two")"#, "wrong number of arguments. got=2, want=1")
        ]
        
        for test in tests {
            let evaluated = testEval(input: test.input)
            
            switch test.expected {
            case let expected as Int:
                let _ = testIntegerObject(object: evaluated, expected: Int64(expected))
            case let expected as String:
                guard let error = evaluated as? Object_t.Error else {
                    XCTFail("object is not Error. got=\(type(of: evaluated))")
                    continue
                }
                if error.message != expected {
                    XCTFail("wrong error message. expected=\(test.expected), got=\(error.message)")
                    continue
                }
            default:
                XCTFail("test case type error. please double check the type in testcases")
                continue
            }
        }
    }
    
    func testArrayLiterals() {
        let input = "[1, 2 * 2, 3 + 3]"
        
        let evaluated = testEval(input: input)
        
        guard let result = evaluated as? Object_t.Array else {
            XCTFail("object is not Array. got=\(type(of: evaluated)) (\(evaluated))")
            return
        }
        
        if result.elements.count != 3 {
            XCTFail("array has wrong num of elements. got=\(result.elements.count)")
            return
        }
        
        let _ = testIntegerObject(object: result.elements[0], expected: 1)
        let _ = testIntegerObject(object: result.elements[1], expected: 4)
        let _ = testIntegerObject(object: result.elements[2], expected: 6)
    }
    
    func testArrayIndexExpressions() {
        let tests: [TestCase<Int64?>] = [
                    TestCase(
                        "[1, 2, 3][0]",
                        1),
                    TestCase(
                        "[1, 2, 3][1]",
                        2
                    ),
                    TestCase(
                        "[1, 2, 3][2]",
                        3
                    ),
                    TestCase(
                        "let i = 0; [1][i];",
                        1
                    ),
                    TestCase(
                        "[1, 2, 3][1 + 1];",
                        3
                    ),
                    TestCase(
                        "let myArray = [1, 2, 3]; myArray[2];",
                        3
                    ),
                    TestCase(
                        "let myArray = [1, 2, 3]; myArray[0] + myArray[1] + myArray[2];",
                        6
                    ),
                    TestCase(
                        "let myArray = [1, 2, 3]; let i = myArray[0]; myArray[i]",
                        2
                    ),
                    TestCase(
                        "[1, 2, 3][3]",
                        nil
                    ),
                    TestCase(
                        "[1, 2, 3][-1]",
                        nil
                    ),
        ]
        
        for (_, test) in tests.enumerated() {
            let evaluated = testEval(input: test.input)
            if let expectedInteger = test.expected {
                let _ = testIntegerObject(object: evaluated, expected: expectedInteger)
            } else {
                let _ = testNullObject(object: evaluated)
            }
        }
    }
    
    func testHashLiterals() {
        let input = #"""
                    let two = "two";
                    {
                        "one": 10 - 9,
                        two: 1 + 1,
                        "thr" + "ee": 6 / 2,
                        4: 4,
                        true: 5,
                        false: 6,
                    }
                    """#
        let evaluated = testEval(input: input)
        
        guard let result = evaluated as? Object_t.Hash else {
            XCTFail("object is not Hash. got=\(type(of: evaluated)) (\(evaluated))")
            return
        }
        
        let expected : [HashKey: Int64] = [
            Object_t.string(value: "one").hashKey():    1,
            Object_t.string(value: "two").hashKey():    2,
            Object_t.string(value: "three").hashKey():  3,
            Object_t.Integer(value: 4).hashKey():       4,
            Object_t.Boolean(value: true).hashKey():    5,
            Object_t.Boolean(value: false).hashKey():   6
        ]
        
        guard result.pairs.count == expected.count else {
            XCTFail("Hash has wrong num of pairs. got=\(result.pairs.count)")
            return
        }
        
        for (expectedKey, expectedValue) in expected {
            guard let pair = result.pairs[expectedKey] else {
                XCTFail("no pair for given key in Pairs")
                return
            }
            
            let _ = testIntegerObject(object: pair.value, expected: expectedValue)
        }
    }
    
    func testHashIndexExpressions() {
        let tests: [TestCase<Int?>] = [
            TestCase(#"{"foo": 5}["foo"]"#, 5),
            TestCase(#"{"foo": 5}["bar"]"#, nil),
            TestCase(#"{}["foo"]"#, nil),
            TestCase(#"{5: 5}[5]"#, 5),
            TestCase(#"{true: 5}[true]"#, 5),
            TestCase(#"{false: 5}[false]"#, 5)
        ]
        
        for test in tests {
            let evaluated = testEval(input: test.input)
            if let integer = test.expected {
                let _ = testIntegerObject(object: evaluated, expected: Int64(integer))
            } else {
                let _ = testNullObject(object: evaluated)
            }
        }
    }
    
    private func testEval(input: String) -> Object {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let environment = Environment()
        guard let program = parser.parseProgram() else {
            return Object_t.Error(message: "parse program error, failed to create ast tree")
        }
        
        return Evaluator.eval(program, environment) ?? Object_t.Error(message: "eval error")
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
    
    private func testNullObject(object: Object) -> Bool {
        guard object is Object_t.Null else {
            XCTFail("object is not NULL. got=\(type(of: object))")
            return false
        }
        return true
    }
}
