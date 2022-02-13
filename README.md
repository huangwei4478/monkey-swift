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
// leetcode 206, reverse a link list
// https://leetcode-cn.com/problems/reverse-linked-list/
class ListNode{}

function ListNodeFactory(value, next) {
	let node = ListNode();
	node.value = value;
	node.next = next;
	return node;
}

let linklist = ListNodeFactory(1, ListNodeFactory(2, ListNodeFactory(3, ListNodeFactory(4, null))))

function reverseLinkList(head) {
	if (head == null) { return null; }

	let prev = null;
	let curr = head;

	while (curr != null) {
		let next = curr.next;
		curr.next = prev;
		prev = curr;
		curr = next;
	}

	return prev;
}

function printLinkList(head) {
	let curr = head;
	while (curr != null) {
		puts(curr.value);
		curr = curr.next;
	}
}

puts("original link list")
printLinkList(linklist)
puts("--------------------")
puts("reverse a link list")
printLinkList(reverseLinkList(linklist))

/*
output:

original link list
1
2
3
4
--------------------
reverse a link list
4
3
2
1
null

*/

```

```javascript
// [easy] leetcode 704, binary search
// https://leetcode-cn.com/problems/binary-search

let nums = [-1,0,3,5,9,12];
let target = 9;
let expectedOutput = 4;

function binarySearch(array, target) {
	let n = len(array);

	// find target in [l ... r)
	let l = 0;
	let r = n;
	let mid = 0;
	while (l < r) {						// when l == r, [l ... r) is an empty set
		mid = (l + r) / 2;
		if (nums[mid] == target) {
			return mid;
		}

		if (target > nums[mid]) {
			l = mid + 1;				// target is in [mid + 1 ... r)
		} else {
			r = mid;					// target is in [l ... mid)
		}
	}

	return -1;
}

puts(binarySearch(nums, target) == expectedOutput);   // output 'True'

```

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

