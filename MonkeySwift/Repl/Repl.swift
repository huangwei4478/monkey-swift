//
//  Repl.swift
//  monkey-swift
//
//  Created by huangwei on 2021/3/6.
//

import Foundation

let prompt = ">> "

struct Repl {
    static func start() {
        var shouldQuit = false
        
        while !shouldQuit {
            ConsoleIO.shared.printUsage()
            
            let option = OptionType(value: ConsoleIO.shared.getInput())
            
            switch option {
                case .input(let string):
                    var lexer = Lexer(input: string)
                    
                    var token = lexer.nextToken()
                    while (token.tokenType != .EOF) {
                        ConsoleIO.shared.writeMessage(String(describing: token))
                        token = lexer.nextToken()
                    }
                    ConsoleIO.shared.writeMessage("\n")
                case .quit:
                    shouldQuit = true
            }
        }
    }
    
    
}
