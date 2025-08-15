// Test file for Rust LSP configuration

use std::collections::HashMap;

#[derive(Debug)]
struct Person {
    name: String,
    age: u32,
}

impl Person {
    fn new(name: &str, age: u32) -> Self {
        Person {
            name: name.to_string(),
            age,
        }
    }
    
    fn greet(&self) -> String {
        format!("Hello, my name is {} and I'm {} years old!", self.name, self.age)
    }
}

fn process_numbers(numbers: Vec<i32>) -> Option<f64> {
    if numbers.is_empty() {
        return None;
    }
    
    let sum: i32 = numbers.iter().sum();
    let avg = sum as f64 / numbers.len() as f64;
    Some(avg)
}

fn main() {
    let person = Person::new("Alice", 30);
    println!("{}", person.greet());
    
    let numbers = vec![1, 2, 3, 4, 5];
    match process_numbers(numbers) {
        Some(avg) => println!("Average: {:.2}", avg),
        None => println!("No numbers provided"),
    }
    
    // Test HashMap
    let mut scores = HashMap::new();
    scores.insert("Alice", 95);
    scores.insert("Bob", 87);
    
    for (name, score) in &scores {
        println!("{}: {}", name, score);
    }
    
    // This will cause a warning for testing diagnostics
    let unused_variable = 42;  // Warning: unused variable
}