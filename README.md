# Zig 101 - Learning Zig Programming

A comprehensive collection of Zig programming examples and patterns, covering fundamental concepts and common data structures.

## Overview

This project demonstrates various Zig programming concepts through practical, runnable examples. Each module focuses on a specific topic with detailed code samples and explanations.

## Topics Covered

### Data Structures
- **ArrayList** (`src/array_list.zig`) - Dynamic arrays with multiple type examples:
  - Integers, strings, floats, booleans
  - Custom structs
  - Nested ArrayLists (2D structures)

- **HashMap** (`src/hashtable.zig`) - Key-value storage and word counting examples

### Object-Oriented Patterns
- **Structs** (`src/structs.zig`) - Custom data types and methods
- **Constructors** (`src/constructors.zig`) - Object initialization patterns
- **Interfaces** (`src/interfaces.zig`) - Runtime polymorphism with function pointers

### String Manipulation
- **Strings** (`src/strings.zig`) - Comprehensive string operations:
  - Concatenation, splitting, trimming
  - Search and replace
  - Case conversion
  - Parsing and formatting

### Error Handling
- **Errors** (`src/errors.zig`) - Comprehensive error handling patterns:
  - Basic error propagation with `try`
  - Custom error sets and error unions
  - Catching and handling errors
  - `defer` and `errdefer` for cleanup
  - Real-world validation examples

## Getting Started

### Prerequisites
- Zig compiler (0.11.0 or later)

### Building and Running

```bash
# Build the project
zig build

# Run all examples
zig build run

# Run tests (if available)
zig build test
```

## Project Structure

```
zig101/
├── src/
│   ├── main.zig              # Entry point, runs all demos
│   ├── array_list.zig        # ArrayList demonstrations
│   ├── hashtable.zig         # HashMap examples
│   ├── structs.zig           # Struct patterns
│   ├── constructors.zig      # Constructor patterns
│   ├── interfaces.zig        # Interface implementations
│   ├── strings.zig           # String manipulation
│   └── errors.zig            # Error handling patterns
├── build.zig                 # Build configuration
└── README.md                 # This file
```

## Key Learning Points

### Memory Management
All examples demonstrate proper memory management using:
- `defer` for cleanup
- Allocators for dynamic memory
- `GeneralPurposeAllocator` for development

### Type System
Examples showcase Zig's type system:
- Compile-time type parameters
- Generic functions and structs
- Type inference

### Error Handling
Consistent use of:
- Error unions (`!void`, `!Type`)
- `try` for error propagation
- Explicit error handling

## Running Individual Examples

Each module contains a `demo()` function and additional example functions. To run specific examples, modify `src/main.zig` to comment out unwanted demos.

## Learning Path

Recommended order for beginners:
1. ArrayList basics (`array_list.zig`)
2. Structs and methods (`structs.zig`)
3. String manipulation (`strings.zig`)
4. HashMaps (`hashtable.zig`)
5. Constructor patterns (`constructors.zig`)
6. Interface patterns (`interfaces.zig`)
7. Error handling (`errors.zig`)

## License

This is a learning project. Feel free to use and modify as needed.

## Resources

- [Official Zig Documentation](https://ziglang.org/documentation/)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)
- [Zig Learn](https://ziglearn.org/)