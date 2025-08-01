// Test file for Next Edit Suggestions
function calculateSum(x, y) {
    let result = x + y;
    console.log("Sum of", x, "and", y, "is", result);
    return result;
}

let x = 5;
let y = 10;
let total = calculateSum(x, y);
console.log("Final result:", total);

// Instructions:
// 1. Open this file in Neovim
// 2. Go to line 2 and change 'x' to 'newVar' in insert mode
// 3. You should see highlights on other 'x' occurrences
// 4. Use <leader>n to navigate to next occurrence
// 5. Use <leader>p to navigate to previous occurrence
// 6. Use <leader>c to clear highlights