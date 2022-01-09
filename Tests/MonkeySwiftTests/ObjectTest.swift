//
//  ObjectTest.swift
//  MonkeySwiftUnitTest
//
//  Created by huangwei on 2021/7/3.
//

import XCTest

class ObjectTest: XCTestCase {
    func testStringHashKey() {
        let hello1 = Object_t.string(value: "Hello World")
        let hello2 = Object_t.string(value: "Hello World")
        let diff1 = Object_t.string(value: "My name is johnny")
        let diff2 = Object_t.string(value: "My name is johnny")
        
        guard hello1.hashKey() == hello2.hashKey() else {
            XCTFail("string with same content have different hash keys")
            return
        }
        
        guard diff1.hashKey() == diff2.hashKey() else {
            XCTFail("string with same content have different hash keys")
            return
        }
        
        guard hello1.hashKey() != diff1.hashKey() else {
            XCTFail("string with different content have same hash keys")
            return
        }
    }
}
