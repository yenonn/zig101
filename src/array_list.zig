const std = @import("std");

/// Demonstrates ArrayList operations with integers and strings
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("=== ArrayList Demo ===\n\n", .{});

    try demoWithIntegers(allocator);
    try demoWithStrings(allocator);

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
}
