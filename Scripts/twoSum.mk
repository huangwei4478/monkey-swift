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