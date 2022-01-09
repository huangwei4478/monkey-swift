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
