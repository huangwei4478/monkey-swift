class ListNode{}

function ListNodeFactory(value, next) {
	let node = ListNode();
	node.value = value;
	node.next = next;
	return node;
}

let node = ListNodeFactory(111, 222);
