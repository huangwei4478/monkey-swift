//
//  Environment.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/6/1.
//

import Foundation

final class Environment {
    private var _store: [String: Object]
    
    private var _outer: Environment?
    
    convenience init() {
        self.init(store: [:], outer: nil)
    }
    
    convenience init(outer: Environment?) {
        self.init(store: [:], outer: outer)
    }
    
    private init(store: [String: Object], outer: Environment?) {
        _store = store
        _outer = outer
    }
    
    func get(name: String) -> Object? {
        let object = _store[name]
        if let object = object {
            return object
        } else if let outer = _outer {
            return outer.get(name: name)
        } else {
            return nil
        }
    }
    
    func set(name: String, value: Object) -> Object {
        _store[name] = value
        return value
    }
}
