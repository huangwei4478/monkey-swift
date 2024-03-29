//
//  Repl.swift
//  monkey-swift
//
//  Created by huangwei on 2021/3/6.
//

import Foundation

let prompt = ">> "

struct MonkeyRepl {
    static func start() {
        var shouldQuit = false
        ConsoleIO.shared.printUsage()
        let env = Environment()
        while !shouldQuit {
            
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
                    
                    guard let evaluated = Evaluator.eval(program, env) else { continue }
                    ConsoleIO.shared.writeMessage(evaluated.inspect())
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
