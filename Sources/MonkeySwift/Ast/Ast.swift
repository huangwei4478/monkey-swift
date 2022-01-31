//
//  Ast.swift
//  MonkeySwift
//
//  Created by huangwei on 2021/3/13.
//

import Foundation

protocol Node {
    func tokenLiteral() -> String
    func string() -> String
}

protocol Statement: Node {
    func statementNode()
}

protocol Expression: Node {
    func expressionNode()
}

public struct Ast {
    struct Program: Node {
        
        var statements: [Statement]
        
        func tokenLiteral() -> String {
            if statements.count > 0 {
                return statements[0].tokenLiteral()
            } else {
                return ""
            }
        }
        
        func string() -> String {
            return statements.reduce("") { (resultSoFar, statement) -> String in
                return resultSoFar + statement.string()
            }
        }
    }
    
    struct LetStatement: Statement {
        let token: Token                    // the token.LET token
        
        let name: Identifier
        
        let value: Expression
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func statementNode() {}
        
        func string() -> String {
            return "\(tokenLiteral()) \(name.string()) = \(value.string());"
        }
    }
    
    struct ReturnStatement: Statement {
        let token: Token                    // the 'return' token
        
        let returnValue: Expression
        
        func statementNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return "\(tokenLiteral()) \(returnValue.string());"
        }
    }
	
	struct ClassDefineStatement: Statement {

		let token: Token							// the class name identifier token
		
		let methods: [Ast.FunctionDefineLiteral]
		
		func statementNode() {}
		
		func tokenLiteral() -> String {
			return token.literal
		}
		
		func string() -> String {
			return "class \(tokenLiteral())"
		}
	}
    
    struct ExpressionStatement: Statement {
        let token: Token                    // the first token of the expression
        
        let expression: Expression
        
        func statementNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return expression.string()
        }
    }
	
	// AssignmentStatement: let-less assignment
	// such as "x = y"
	struct AssignStatement: Expression {
		
		let token: Token
		
		let name: Identifier
		
		let value: Expression
		
		func expressionNode() {}
		
		func tokenLiteral() -> String {
			return token.literal
		}
		
		func string() -> String {
			return "\(name.string()) = \(value.string())"
		}
	}
    
	struct Identifier: Expression {
		let token: Token                    // the token.IDENT token
		
		let value: String
		
		func expressionNode() {}
		
		func tokenLiteral() -> String {
			return token.literal
		}
		
		func string() -> String {
			return value
		}
	}
	
    struct IntegerLiteral: Expression {
        let token: Token
        
        let value: Int64
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return token.literal
        }
    }
    
    struct StringLiteral: Expression {
        let token: Token
        
        let value: String
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return token.literal
        }
        
        
    }
    
    struct PrefixExpression: Expression {
        let token: Token
        
        let `operator`: String
        
        let right: Expression
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return "(\(`operator`)\(right.string()))"
        }
    }
    
    struct InfixExpression: Expression {
        let token: Token                            // the operator token, e.g. +
        
        let left: Expression
        
        let `operator`: String
        
        let right: Expression
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return "(\(left.string()) \(`operator`) \(right.string()))"
        }
    }
    
    struct IndexExpression: Expression {
        let token: Token            // the [ token
        
        let left: Expression
        
        let index: Expression
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return "(\(left.string())[\(index.string())])"
        }
    }
    
    struct Boolean: Expression {
        let token: Token
        
        let value: Bool
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return token.literal
        }
    }
    
    struct BlockStatement: Statement {
        let token: Token                    // the { token
        
        let statements: [Statement]
        
        func statementNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            return statements.reduce("") { $0 + $1.string() }
        }
    }

    struct IfExpression: Expression {
        let token: Token
        
        let condition: Expression

        let consequence: BlockStatement
        
        let alternative: BlockStatement?
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            var string = "if \(condition.string()) \(consequence.string()))"
            
            if let alternative = alternative {
                string += " else "
                string += alternative.string()
            }
            
            return string
        }
    }
	
	struct WhileExpression: Expression {
		let token: Token					// the 'while' token
		
		let condition: Expression
		
		let consequence: BlockStatement
		
		func expressionNode() {}
		
		func tokenLiteral() -> String {
			return token.literal
		}
		
		func string() -> String {
			return "while (\(condition.string())) { \(consequence.string()) }"
		}
	}
    
    struct FunctionLiteral: Expression {
        
        let token: Token                    // the 'fn' token
        
        let parameters: [Ast.Identifier]
        
        let body: BlockStatement
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            let params = parameters.map{ $0.string() }.joined(separator: ", ")
            
            return "\(tokenLiteral())(\(params))\(body.string())"
        }
    }
	
	struct FunctionDefineLiteral: Expression {
		let token: Token					// the identifier, i.e. the function name
		
		let parameters: [Ast.Identifier]
		
		let body: BlockStatement
		
		func expressionNode() {}
		
		func tokenLiteral() -> String {
			return token.literal
		}
		
		func string() -> String {
			let params = parameters.map{ $0.string() }.joined(separator: ", ")
			
			return "function \(tokenLiteral())(\(params))\(body.string())"
		}
	}
    
    struct ArrayLiteral: Expression {
        let token: Token                    // the '[' token
        
        let elements: [Expression]
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            let elementExpressions = elements.map{ $0.string() }.joined(separator: ", ")
            return "[\(elementExpressions)]"
        }
    }
    
    struct HashLiteral: Expression {
        
        typealias HashPair = (key: Expression, value: Expression)
        
        let token: Token            // the '{' token
        
        let pairs: [HashPair]

        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            let keyValues = pairs.map { key, value in
                return "\(key.string()):\(value.string())"
            }
            return "{\(keyValues.joined(separator: ", "))}"
        }
    }
    
    struct CallExpression: Expression {
        let token: Token                    // the '(' token
        
        let function: Expression            // Identifier or FunctionLiteral
        
        let arguments: [Expression]
        
        func expressionNode() {}
        
        func tokenLiteral() -> String {
            return token.literal
        }
        
        func string() -> String {
            let args = arguments.map{ $0.string() }.joined(separator: ", ")
            return "\(function.string())(\(args))"
        }
    }
    
}
