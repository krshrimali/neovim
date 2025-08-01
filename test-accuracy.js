// Comprehensive test for Next Edit Suggestions accuracy
let x = 4;
print(x);
console.log(x);

function calculate(x, y) {
    let result = x + y;
    return result;
}

let myVar = 10;
let anotherVar = myVar * 2;
console.log(myVar, anotherVar);

class MyClass {
    constructor(value) {
        this.value = value;
    }
    
    getValue() {
        return this.value;
    }
}

let obj = new MyClass(42);
console.log(obj.getValue());

// Test cases:
// 1. Change 'x' to 'check' on line 2 - should highlight lines 3, 4, 6, 7
// 2. Change 'myVar' to 'newName' on line 11 - should highlight lines 12, 13
// 3. Change 'value' to 'data' on line 16 - should highlight lines 20, 22
// 4. Change 'obj' to 'instance' on line 25 - should highlight line 26