//
//  Environment.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/6/1.
//

import Foundation

class Environment {
    private var _store: [String: Object] = [:]
    
    func get(name: String) -> Object? {
        return _store[name]
    }
    
    func set(name: String, value: Object) -> Object {
        _store[name] = value
        return value
    }
}
