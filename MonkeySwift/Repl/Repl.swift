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
                    let lexer = Lexer(input: string)
                    let parser = Parser(lexer: lexer)
                    
                    let optionalProgram = parser.parseProgram()
                    if !parser.Errors().isEmpty {
                        printParserErrors(errors: parser.Errors())
                        continue
                    }
                    
                    guard let program = optionalProgram else { continue }
                    
                    ConsoleIO.shared.writeMessage(program.string())
                    ConsoleIO.shared.writeMessage("\n")
                case .quit:
                    shouldQuit = true
            }
        }
    }
    
    
    private static func printParserErrors(errors: [String]) {
        for message in errors {
            ConsoleIO.shared.writeMessage(message)
        }
    }
}
