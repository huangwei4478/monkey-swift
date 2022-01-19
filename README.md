# MonkeySwift

a modern programming language implemented in pure Swift

from the book ["Writing an Interpreter in Go"](https://interpreterbook.com/)

![img](https://interpreterbook.com/img/monkey_logo-d5171d15.png)

how to use

```bash
git clone https://github.com/huangwei4478/monkey-swift
cd monkey-swift
swift run MonkeySwift repl    // into repl mode

// or, load script file
swift run MonkeySwift script ./Scripts/twoSum.mk
```



```
OVERVIEW: Monkey Programming Language Interpreter

USAGE: MonkeySwift <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  repl                    repl mode
  script                  execute script file

  See 'MonkeySwift help <subcommand>' for detailed help.
```



supported syntax: 

```javascript
// Leetcode 1, twoSum.mk
let nums = [2, 11, 7, 15];
let target = 9;

let n = len(nums);

let i = 0;

while (i < n) {
 let j = i + 1;
 while (j < n) {
  if (nums[i] + nums[j] == target) {
   return [i, j];
  }
  
  j = j + 1;
 }
 i = i + 1;
}

return [-1, -1];
```

```javascript
// Bind values to names with let-statements
let version = 1;
let name = "Monkey programming language";
let myArray = [1, 2, 3, 4, 5];
let coolBooleanLiteral = true;

// Use expressions to produce values
let awesomeValue = (10 / 2) * 5 + 30;
let arrayWithValues = [1 + 1, 2 * 2, 3];
```



```javascript
let fibonacci = fn(x) {
  if (x == 0) {
    0
  } else {
    if (x == 1) {
      return 1;
    } else {
      fibonacci(x - 1) + fibonacci(x - 2);
    }
  }
};

puts("fibonacci(20) = " + fibonacci(20))
```



it also supports higher-order functions: 

```javascript
let people = [{"name": "Anna", "age": 24}, {"name": "Bob", "age": 99}];

let getName = fn(person) { person["name"]; };

let map = fn(arr, f) {
  let iter = fn(arr, accumulated) {
    if (len(arr) == 0) {
      accumulated
    } else {
      iter(rest(arr), push(accumulated, f(first(arr))));
    }
  };

  iter(arr, []);
};

map(people, getName);
```

