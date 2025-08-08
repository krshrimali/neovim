# Next Edit Suggestions - Example

## How It Works

The plugin detects when you rename variables, functions, or other symbols and suggests related changes throughout your file.

## Example Scenario

### Before: Original Code
```javascript
function calculateSum(x, y) {
    let result = x + y;
    console.log("Sum of", x, "and", y, "is", result);
    return result;
}

let x = 5;
let y = 10;
let total = calculateSum(x, y);
console.log("Final result:", total);
```

### Step 1: Rename Variable
You change `x` to `firstNumber` on line 1:

```javascript
function calculateSum(firstNumber, y) {  // ← You changed this
    let result = firstNumber + y;        // ← Plugin highlights this
    console.log("Sum of", firstNumber, "and", y, "is", result);  // ← And this
    return result;
}

let x = 5;                              // ← And this
let y = 10;
let total = calculateSum(x, y);         // ← And this
console.log("Final result:", total);
```

### Step 2: Plugin Shows Suggestions
A popup appears showing:

```
🔄 Next Edit Suggestions
═══════════════════════════

Symbol: firstNumber

Found 4 related edits:

→ 1: Line 2 - let result = x + y;
  2: Line 3 - console.log("Sum of", x, "and", y, "is", result);
  3: Line 7 - let x = 5;
  4: Line 9 - let total = calculateSum(x, y);

Keys: <CR>=Accept <Tab>=Next <S-Tab>=Prev
      <leader>a=Accept All <leader>x=Dismiss
```

### Step 3: Apply Changes
- Press `<CR>` to apply the current suggestion
- Press `<Tab>` to navigate to the next suggestion
- Press `<leader>a` to apply all suggestions at once

### After: All Changes Applied
```javascript
function calculateSum(firstNumber, y) {
    let result = firstNumber + y;
    console.log("Sum of", firstNumber, "and", y, "is", result);
    return result;
}

let firstNumber = 5;
let y = 10;
let total = calculateSum(firstNumber, y);
console.log("Final result:", total);
```

## Visual Feedback

While suggestions are active:
- **Current suggestion**: Highlighted in bright yellow
- **Other suggestions**: Highlighted in dim gray
- **Popup window**: Shows all related edits with line numbers
- **Navigation**: Easy keyboard navigation between suggestions

## Key Benefits

1. **No More Manual Search**: No need to manually find all occurrences
2. **Context Aware**: Only suggests semantically related changes
3. **Safe**: Preview all changes before applying
4. **Fast**: Instant detection and highlighting
5. **Flexible**: Apply individually or all at once

## Supported Scenarios

- Variable renaming
- Function parameter changes
- Class/object property updates
- Import/require statement changes
- And more...

Just like Cursor IDE, but in Neovim! 🎉