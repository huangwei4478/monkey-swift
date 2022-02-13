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

