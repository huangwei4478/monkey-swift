import ArgumentParser

enum Command {}

extension Command {
	struct Main: ParsableCommand {
		static var configuration: CommandConfiguration {
			.init(
				commandName: "MonkeySwift",
				abstract: "Monkey Programming Language Interpreter",
				version: "1.0.0",
				subcommands: [Repl.self, RunScript.self]
			)
		}
	}
}

extension Command {
	struct Repl: ParsableCommand {
		static var configuration: CommandConfiguration {
			.init(
				commandName: "repl",
				abstract: "repl mode"
			)
		}
		
		func run() throws {
			MonkeyRepl.start()
		}
	}
	
	struct RunScript: ParsableCommand {
		static var configuration: CommandConfiguration {
			.init(
				commandName: "script",
				abstract: "execute script file"
			)
		}
		
		@Argument(help: "filepath of the script")
		var path: String
		
		func run() throws {
			MonkeyScript.runScript(scriptPath: path)
		}
	}
}

Command.Main.main()
