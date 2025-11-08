# Zig101 Learning Project

## Project Overview

This is a comprehensive Zig learning project that demonstrates fundamental programming concepts, data structures, and patterns in the Zig programming language. The project is designed for educational purposes, with each module focusing on specific concepts through practical, runnable examples.

## Project Structure

```
zig101/
├── src/
│   ├── main.zig              # Entry point - runs all demo modules
│   ├── array_list.zig        # ArrayList demonstrations with multiple types
│   ├── hashtable.zig         # HashMap/HashTable examples
│   ├── structs.zig           # Struct definitions and methods
│   ├── constructors.zig      # Constructor pattern examples
│   ├── interfaces.zig        # Interface pattern implementations
│   └── strings.zig           # String manipulation utilities
├── build.zig                 # Build configuration
├── README.md                 # Project documentation
└── .claude/
    └── claude.md             # This file
```

## Key Concepts

### Memory Management
- All examples use proper memory management with allocators
- `GeneralPurposeAllocator` is used for development
- `defer` statements ensure proper cleanup
- Memory safety is demonstrated throughout

### Module Organization
- Each `.zig` file is a self-contained module
- Modules export public functions via `pub fn demo()`
- Most modules include both basic and advanced examples
- `main.zig` orchestrates all demos

### Common Patterns

#### ArrayList Usage
- Multiple type demonstrations: integers, strings, floats, booleans, structs
- Nested ArrayLists for 2D structures
- Proper initialization and deinitialization

#### Struct Patterns
- Field definitions with various types
- Method definitions with `pub fn`
- `@This()` for self-referential types
- Custom `format()` functions for pretty printing

#### Error Handling
- All fallible operations use error unions (`!void`, `!Type`)
- `try` keyword for error propagation
- Explicit error handling where needed

## Build and Run

```bash
# Build the project
zig build

# Run all examples
zig build run

# Build in release mode
zig build -Doptimize=ReleaseFast
```

## Development Guidelines

### When Adding New Examples
1. Create a new module file in `src/` if needed
2. Implement `pub fn demo(allocator: std.mem.Allocator) !void`
3. Import the module in `main.zig`
4. Call the demo function in `main()`
5. Ensure proper memory management with `defer`

### Code Style
- Use 4 spaces for indentation
- Include descriptive comments
- Print section headers for clarity in output
- Follow Zig standard library conventions

### Memory Safety
- Always use `defer` for cleanup
- Pass allocators as parameters
- Avoid memory leaks by ensuring all allocated memory is freed
- Use `defer` blocks to guarantee cleanup even on early returns

## Module Details

### array_list.zig
Demonstrates ArrayList operations with various types:
- Integer operations (append, insert, pop, clear)
- String storage
- Custom struct storage (Person)
- Floating-point numbers with calculations
- Boolean flags with counting
- Nested ArrayLists (2D matrix)

### hashtable.zig
HashMap demonstrations:
- Basic key-value operations
- Word counting example
- String keys with integer values

### structs.zig
Struct patterns and usage:
- Basic struct definitions
- Methods and associated functions
- Student record management example

### constructors.zig
Constructor pattern examples:
- Simple initialization
- Complex multi-step construction
- Builder patterns

### interfaces.zig
Interface-like patterns in Zig:
- Function pointer tables
- Runtime polymorphism
- Writer interface example
- Type erasure patterns

### strings.zig
String manipulation utilities:
- Concatenation using `std.fmt.allocPrint`
- Splitting and tokenizing
- Trimming whitespace
- Search and replace
- Case conversion (ASCII)
- Parsing and formatting

## Testing Approach

When testing changes:
1. Run `zig build` to check for compilation errors
2. Run `zig build run` to execute all demos
3. Check output for correctness
4. Verify no memory leaks (GPA will report leaks on deinit)

## Common Commands

```bash
# Clean build artifacts
rm -rf zig-cache zig-out

# Check for compilation errors only
zig build-exe src/main.zig

# Format all Zig files
zig fmt src/

# Run with specific Zig version
zig build run
```

## Version Information

- **Zig Version**: 0.11.0 or later recommended
- **Language**: Zig
- **Platform**: Cross-platform (tested on macOS, Linux, Windows)

## Learning Path

Recommended order for studying the modules:
1. **array_list.zig** - Start with basic dynamic arrays
2. **structs.zig** - Learn custom types and methods
3. **strings.zig** - String operations and manipulation
4. **hashtable.zig** - Key-value storage
5. **constructors.zig** - Object initialization patterns
6. **interfaces.zig** - Advanced polymorphism patterns

## Notes for AI Assistants

- This is a learning project, so code clarity is prioritized over optimization
- Examples should be self-contained and well-commented
- Each demo should print clear output showing what it's doing
- Memory management should always be explicit and correct
- Follow the existing code style and patterns when adding new examples
- Ensure all new code compiles and runs without errors
- When adding new modules, update main.zig and this documentation