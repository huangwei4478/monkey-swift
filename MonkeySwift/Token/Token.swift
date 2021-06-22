//
//  Token.swift
//  monkey-swift
//
//  Created by huangwei on 2021/3/6.
//

import Foundation

public struct Token: Hashable {
    let tokenType: TokenType
    let literal: String
}
