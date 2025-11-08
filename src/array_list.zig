const std = @import("std");

/// Demonstrates ArrayList operations with integers and strings
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("=== ArrayList Demo ===\n\n", .{});

    try demoWithIntegers(allocator);
    try demoWithStrings(allocator);
    try demoWithStructs(allocator);
    try demoWithFloats(allocator);
    try demoWithBooleans(allocator);
    try demoNestedArrayLists(allocator);

    std.debug.print("\n=== Demo Complete ===\n", .{});
}

/// Demonstrates ArrayList operations with integers
fn demoWithIntegers(allocator: std.mem.Allocator) !void {
    // Create an ArrayList of integers
    var list = std.array_list.AlignedManaged(i32, null).init(allocator);
    defer list.deinit(); // Important: free memory when done

    // 1. Adding items
    std.debug.print("1. Adding items:\n", .{});
    try list.append(10);
    try list.append(20);
    try list.append(30);
    std.debug.print("   Added: 10, 20, 30\n", .{});
    std.debug.print("   Length: {}\n", .{list.items.len});
    std.debug.print("   Capacity: {}\n\n", .{list.capacity});

    // 2. Accessing items
    std.debug.print("2. Accessing items:\n", .{});
    std.debug.print("   list[0] = {}\n", .{list.items[0]});
    std.debug.print("   list[1] = {}\n", .{list.items[1]});
    std.debug.print("   list[2] = {}\n\n", .{list.items[2]});

    // 3. Iterating through items
    std.debug.print("3. Iterating through items:\n", .{});
    for (list.items, 0..) |item, i| {
        std.debug.print("   Index {}: {}\n", .{ i, item });
    }
    std.debug.print("\n", .{});

    // 4. Modifying items
    std.debug.print("4. Modifying items:\n", .{});
    list.items[1] = 99;
    std.debug.print("   Changed list[1] to 99\n", .{});
    std.debug.print("   New values: ", .{});
    for (list.items) |item| {
        std.debug.print("{} ", .{item});
    }
    std.debug.print("\n\n", .{});

    // 5. Removing items
    std.debug.print("5. Removing items:\n", .{});
    const removed = list.pop();
    std.debug.print("   Popped: {?}\n", .{removed});
    std.debug.print("   Remaining length: {}\n\n", .{list.items.len});

    // 6. Insert at specific position
    std.debug.print("6. Insert at position:\n", .{});
    try list.insert(0, 5);
    std.debug.print("   Inserted 5 at index 0\n", .{});
    std.debug.print("   Values: ", .{});
    for (list.items) |item| {
        std.debug.print("{} ", .{item});
    }
    std.debug.print("\n\n", .{});

    // 7. AppendSlice - add multiple items at once
    std.debug.print("7. Append multiple items:\n", .{});
    const more_items = [_]i32{ 40, 50, 60 };
    try list.appendSlice(&more_items);
    std.debug.print("   Added: 40, 50, 60\n", .{});
    std.debug.print("   All values: ", .{});
    for (list.items) |item| {
        std.debug.print("{} ", .{item});
    }
    std.debug.print("\n\n", .{});

    // 8. Clear all items
    std.debug.print("8. Clearing list:\n", .{});
    list.clearRetainingCapacity();
    std.debug.print("   Length after clear: {}\n", .{list.items.len});
    std.debug.print("   Capacity retained: {}\n\n", .{list.capacity});
}

/// Demonstrates ArrayList operations with strings
fn demoWithStrings(allocator: std.mem.Allocator) !void {
    // In Zig, strings are []const u8 (slices of constant bytes)
    // A string literal like "Hello" is UTF-8 encoded bytes
    std.debug.print("9. ArrayList with strings:\n", .{});
    var string_list = std.array_list.AlignedManaged([]const u8, null).init(allocator);
    defer string_list.deinit();

    try string_list.append("Hello");
    try string_list.append("Zig");
    try string_list.append("ArrayList");

    for (string_list.items, 0..) |str, i| {
        std.debug.print("   [{}]: {s}\n", .{ i, str });
    }
    std.debug.print("\n", .{});
}

/// Person struct for demonstrating ArrayList with custom types
const Person = struct {
    name: []const u8,
    age: u32,

    pub fn format(
        self: Person,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("Person{{ name: {s}, age: {} }}", .{ self.name, self.age });
    }
};

/// Demonstrates ArrayList with custom struct types
fn demoWithStructs(allocator: std.mem.Allocator) !void {
    std.debug.print("10. ArrayList with structs:\n", .{});
    var people = std.ArrayList(Person).init(allocator);
    defer people.deinit();

    // Adding struct instances
    try people.append(.{ .name = "Alice", .age = 30 });
    try people.append(.{ .name = "Bob", .age = 25 });
    try people.append(.{ .name = "Charlie", .age = 35 });

    std.debug.print("   People in list:\n", .{});
    for (people.items, 0..) |person, i| {
        std.debug.print("   [{}]: {}\n", .{ i, person });
    }

    // Modifying a struct field
    people.items[1].age = 26;
    std.debug.print("   Updated Bob's age to: {}\n", .{people.items[1].age});
    std.debug.print("\n", .{});
}

/// Demonstrates ArrayList with floating-point numbers
fn demoWithFloats(allocator: std.mem.Allocator) !void {
    std.debug.print("11. ArrayList with floats:\n", .{});
    var numbers = std.ArrayList(f64).init(allocator);
    defer numbers.deinit();

    // Adding floating-point numbers
    try numbers.append(3.14159);
    try numbers.append(2.71828);
    try numbers.append(1.41421);
    try numbers.append(1.73205);

    std.debug.print("   Mathematical constants:\n", .{});
    const names = [_][]const u8{ "Pi", "e", "√2", "√3" };
    for (numbers.items, 0..) |num, i| {
        std.debug.print("   {s}: {d:.5}\n", .{ names[i], num });
    }

    // Calculate average
    var sum: f64 = 0;
    for (numbers.items) |num| {
        sum += num;
    }
    const average = sum / @as(f64, @floatFromInt(numbers.items.len));
    std.debug.print("   Average: {d:.5}\n", .{average});
    std.debug.print("\n", .{});
}

/// Demonstrates ArrayList with boolean values
fn demoWithBooleans(allocator: std.mem.Allocator) !void {
    std.debug.print("12. ArrayList with booleans:\n", .{});
    var flags = std.ArrayList(bool).init(allocator);
    defer flags.deinit();

    // Adding boolean values
    try flags.append(true);
    try flags.append(false);
    try flags.append(true);
    try flags.append(true);
    try flags.append(false);

    std.debug.print("   Flags: ", .{});
    for (flags.items) |flag| {
        std.debug.print("{} ", .{flag});
    }
    std.debug.print("\n", .{});

    // Count true values
    var true_count: usize = 0;
    for (flags.items) |flag| {
        if (flag) true_count += 1;
    }
    std.debug.print("   True count: {}/{}\n", .{ true_count, flags.items.len });
    std.debug.print("\n", .{});
}

/// Demonstrates nested ArrayLists (ArrayList of ArrayLists)
fn demoNestedArrayLists(allocator: std.mem.Allocator) !void {
    std.debug.print("13. Nested ArrayLists (2D array-like structure):\n", .{});

    // Create an ArrayList that holds other ArrayLists
    var matrix = std.ArrayList(std.ArrayList(i32)).init(allocator);
    defer {
        // Important: must deinit each inner ArrayList
        for (matrix.items) |*row| {
            row.deinit();
        }
        matrix.deinit();
    }

    // Create first row [1, 2, 3]
    var row1 = std.ArrayList(i32).init(allocator);
    try row1.append(1);
    try row1.append(2);
    try row1.append(3);
    try matrix.append(row1);

    // Create second row [4, 5, 6]
    var row2 = std.ArrayList(i32).init(allocator);
    try row2.append(4);
    try row2.append(5);
    try row2.append(6);
    try matrix.append(row2);

    // Create third row [7, 8, 9]
    var row3 = std.ArrayList(i32).init(allocator);
    try row3.append(7);
    try row3.append(8);
    try row3.append(9);
    try matrix.append(row3);

    std.debug.print("   Matrix ({} rows):\n", .{matrix.items.len});
    for (matrix.items, 0..) |row, i| {
        std.debug.print("   Row {}: ", .{i});
        for (row.items) |val| {
            std.debug.print("{} ", .{val});
        }
        std.debug.print("\n", .{});
    }

    // Access specific element (row 1, column 2)
    std.debug.print("   Element at [1][2]: {}\n", .{matrix.items[1].items[2]});
    std.debug.print("\n", .{});
}
