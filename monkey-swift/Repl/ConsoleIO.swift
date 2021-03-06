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
            print("\u{001B}[;m\(message)")
        case .error:
            fputs("\u{001B}[0;31m\(message)\n", stderr)
        }
    }
    
    func printUsage() {
        let userName = NSFullUserName()
        writeMessage("Hello \(userName)! This is the Monkey Programming Language!")
        writeMessage("Feel free to type in commands")
        writeMessage("Type 'q' to quit")
    }
    
    func getInput() -> String {
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        let strData = String(data: inputData, encoding: String.Encoding.utf8)!
        return strData.trimmingCharacters(in: CharacterSet.newlines)
    }
    
}
