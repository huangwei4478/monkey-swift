// test recursive
// well... recursive is supported

let printNumber = fn(num) {
	if (num == 0) {
		puts(num)
	} else {
		puts(num)
		printNumber(num - 1)
	}
}

printNumber(6)
