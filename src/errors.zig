const std = @import("std");

pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Error Handling Demo ===\n", .{});

    try basicErrorHandling();
    try errorSets();
    try errorUnions();
    try catchingErrors();
    try errorPayloads();
    try deferAndErrorHandling();
    try customErrorExample(allocator);
}

/// 1. Basic error handling with try
fn basicErrorHandling() !void {
    std.debug.print("\n1. Basic Error Handling:\n", .{});

    // 'try' automatically propagates errors up the call stack
    const result = try parseNumber("42");
    std.debug.print("   Parsed successfully: {}\n", .{result});

    // This would propagate an error if uncommented:
    // const bad_result = try parseNumber("not a number");
}

/// Helper function that can return an error
fn parseNumber(str: []const u8) !i32 {
    return std.fmt.parseInt(i32, str, 10);
}

/// 2. Defining custom error sets
fn errorSets() !void {
    std.debug.print("\n2. Custom Error Sets:\n", .{});

    // Define a custom error set
    const FileError = error{
        FileNotFound,
        PermissionDenied,
        DiskFull,
    };

    std.debug.print("   FileError has the following errors:\n", .{});
    std.debug.print("   - FileNotFound\n", .{});
    std.debug.print("   - PermissionDenied\n", .{});
    std.debug.print("   - DiskFull\n", .{});

    // You can also merge error sets
    const NetworkError = error{
        ConnectionRefused,
        Timeout,
    };

    // Merged error set
    const AllErrors = FileError || NetworkError;
    _ = AllErrors; // Suppress unused variable warning

    std.debug.print("   Error sets can be merged with ||\n", .{});
}

/// 3. Error unions - combining errors with return values
fn errorUnions() !void {
    std.debug.print("\n3. Error Unions:\n", .{});

    // Error union type: ErrorSet!Type
    // This means the function returns either an error or an i32
    const result: anyerror!i32 = divide(10, 2);

    // Check if it's an error
    if (result) |value| {
        std.debug.print("   10 / 2 = {}\n", .{value});
    } else |err| {
        std.debug.print("   Error: {}\n", .{err});
    }

    // This will be an error
    const error_result = divide(10, 0);
    if (error_result) |value| {
        std.debug.print("   10 / 0 = {}\n", .{value});
    } else |_| {
        std.debug.print("   10 / 0 = Error: Cannot divide by zero\n", .{});
    }
}

fn divide(a: i32, b: i32) !i32 {
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}

/// 4. Catching and handling errors explicitly
fn catchingErrors() !void {
    std.debug.print("\n4. Catching Errors:\n", .{});

    // Method 1: Using catch to provide a default value
    const result1 = parseNumber("not a number") catch 0;
    std.debug.print("   Parse 'not a number' with default: {}\n", .{result1});

    // Method 2: Using catch to execute a block
    const result2 = parseNumber("invalid") catch blk: {
        std.debug.print("   Parsing failed, using fallback value\n", .{});
        break :blk -1;
    };
    std.debug.print("   Fallback result: {}\n", .{result2});

    // Method 3: Using if-else to handle errors
    if (parseNumber("123")) |value| {
        std.debug.print("   Successfully parsed: {}\n", .{value});
    } else |err| {
        std.debug.print("   Error occurred: {}\n", .{err});
    }

    // Method 4: Using catch with error variable
    const result3 = parseNumber("bad") catch |err| {
        std.debug.print("   Caught error: {}\n", .{err});
        return err; // Re-throw the error
    };
    _ = result3; // This line won't execute
}

/// 5. Error payloads - getting the actual error value
fn errorPayloads() !void {
    std.debug.print("\n5. Error Payloads:\n", .{});

    const MathError = error{
        DivisionByZero,
        Overflow,
        Underflow,
    };

    const result = safeDivide(10, 0);

    // Capture the error in a variable
    if (result) |value| {
        std.debug.print("   Result: {}\n", .{value});
    } else |err| {
        std.debug.print("   Caught error: ", .{});
        switch (err) {
            MathError.DivisionByZero => std.debug.print("Cannot divide by zero!\n", .{}),
            MathError.Overflow => std.debug.print("Number too large!\n", .{}),
            MathError.Underflow => std.debug.print("Number too small!\n", .{}),
            else => std.debug.print("Unknown error\n", .{}),
        }
    }
}

fn safeDivide(a: i32, b: i32) !i32 {
    if (b == 0) return error.DivisionByZero;
    if (a > 1000000 and b < 2) return error.Overflow;
    return @divTrunc(a, b);
}

/// 6. Defer with error handling - cleanup guaranteed
fn deferAndErrorHandling() !void {
    std.debug.print("\n6. Defer with Error Handling:\n", .{});

    // defer executes even if an error occurs
    defer std.debug.print("   Cleanup: This always runs!\n", .{});

    std.debug.print("   Starting operation...\n", .{});

    // errdefer only runs if an error is returned
    errdefer std.debug.print("   Error cleanup: This runs only on error!\n", .{});

    // Simulate some work
    const success = true;
    if (!success) {
        return error.OperationFailed;
    }

    std.debug.print("   Operation completed successfully\n", .{});
}

/// 7. Real-world example: File operations with error handling
fn customErrorExample(allocator: std.mem.Allocator) !void {
    std.debug.print("\n7. Real-world Example - User Validation:\n", .{});

    const users = [_][]const u8{ "alice", "bob", "", "charlie123", "x" };

    for (users) |username| {
        if (validateUsername(username)) |valid_name| {
            std.debug.print("   ✓ Valid username: '{s}'\n", .{valid_name});
        } else |err| {
            std.debug.print("   ✗ Invalid username '{s}': {}\n", .{ username, err });
        }
    }

    // Example with resource allocation and error handling
    std.debug.print("\n   File-like resource with error handling:\n", .{});
    processFile(allocator, "data.txt") catch |err| {
        std.debug.print("   Failed to process file: {}\n", .{err});
    };
}

const ValidationError = error{
    UsernameTooShort,
    UsernameTooLong,
    InvalidCharacters,
    Empty,
};

fn validateUsername(username: []const u8) ValidationError![]const u8 {
    if (username.len == 0) return error.Empty;
    if (username.len < 3) return error.UsernameTooShort;
    if (username.len > 20) return error.UsernameTooLong;

    // Check for invalid characters (simplified - just checking for spaces)
    for (username) |char| {
        if (char == ' ') return error.InvalidCharacters;
    }

    return username;
}

fn processFile(allocator: std.mem.Allocator, filename: []const u8) !void {
    std.debug.print("   Opening file: {s}\n", .{filename});

    // Simulate file buffer allocation
    var buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer);

    // errdefer cleans up only if an error happens after this point
    errdefer std.debug.print("   Error occurred, buffer cleaned up\n", .{});

    // Simulate file operations
    if (std.mem.eql(u8, filename, "invalid.txt")) {
        return error.FileNotFound;
    }

    std.debug.print("   Processing file content...\n", .{});
    std.debug.print("   File processed successfully\n", .{});
}

/// Additional example: Error wrapping and context
pub fn advancedErrorExample() !void {
    std.debug.print("\n=== Advanced Error Handling ===\n", .{});

    std.debug.print("\n8. Error Return Traces:\n", .{});
    std.debug.print("   In debug mode, Zig provides error return traces\n", .{});
    std.debug.print("   This helps track where errors originated\n", .{});

    // Demonstrate error propagation chain
    outerFunction() catch |err| {
        std.debug.print("   Caught at top level: {}\n", .{err});
    };
}

fn outerFunction() !void {
    try middleFunction();
}

fn middleFunction() !void {
    try innerFunction();
}

fn innerFunction() !void {
    return error.SomethingWentWrong;
}