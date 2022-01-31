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

puts(binarySearch(nums, target) == expectedOutput);

