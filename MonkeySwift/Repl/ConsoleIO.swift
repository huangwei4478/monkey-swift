//
//  ConsoleIO.swift
//  SwiftProgram
//
//  Created by huangwei on 2021/3/6.
//

import Foundation

enum OutputType {
    case error
    case standard
}

enum OptionType {
    case quit
    case input(string: String)
    
    init(value: String) {
        switch value {
            case "q": self = .quit
            default: self = .input(string: value)
        }
    }
    
}

struct ConsoleIO {
    
    static let shared: ConsoleIO = ConsoleIO()
    
    private init() {}
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
            case .standard:
                fputs("\u{001B}[;m\(message)", stdout)
            case .error:
                fputs("\u{001B}[0;31m\(message)", stderr)
        }
    }
    
    func printUsage() {
        let userName = NSFullUserName()
        writeMessage("Hello \(userName)! This is the Monkey Programming Language!\n")
        writeMessage("Feel free to type in commands\n")
        writeMessage("Type 'q' to quit\n")
    }
    
    func getInput() -> String {
        writeMessage(">>> ")
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        let strData = String(data: inputData, encoding: String.Encoding.utf8)!
        return strData.trimmingCharacters(in: CharacterSet.newlines)
    }
    
}
