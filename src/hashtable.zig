const std = @import("std");

/// Demonstrates HashMap (HashTable) operations
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== HashMap Demo ===\n\n", .{});

    try demoBasicOperations(allocator);
    try demoWithStrings(allocator);
    try demoIteration(allocator);

    std.debug.print("\n=== HashMap Demo Complete ===\n", .{});
}

/// Demonstrates basic HashMap operations with integers
fn demoBasicOperations(allocator: std.mem.Allocator) !void {
    std.debug.print("1. Basic HashMap Operations:\n", .{});

    // Create a HashMap with integer keys and string values
    var map = std.AutoHashMap(i32, []const u8).init(allocator);
    defer map.deinit(); // Always free memory when done

    // Insert key-value pairs
    try map.put(1, "one");
    try map.put(2, "two");
    try map.put(3, "three");
    std.debug.print("   Added 3 items\n", .{});
    std.debug.print("   Size: {}\n", .{map.count()});

    // Get a value by key
    if (map.get(2)) |value| {
        std.debug.print("   map.get(2) = {s}\n", .{value});
    }

    // Check if a key exists
    const has_key = map.contains(3);
    std.debug.print("   Contains key 3? {}\n", .{has_key});

    // Update a value
    try map.put(2, "TWO");
    if (map.get(2)) |value| {
        std.debug.print("   Updated map[2] = {s}\n", .{value});
    }

    // Remove a key
    const removed = map.remove(1);
    std.debug.print("   Removed key 1? {}\n", .{removed});
    std.debug.print("   Size after removal: {}\n\n", .{map.count()});
}

/// Demonstrates HashMap with string keys
fn demoWithStrings(allocator: std.mem.Allocator) !void {
    std.debug.print("2. HashMap with String Keys:\n", .{});

    // StringHashMap is optimized for string keys
    var map = std.StringHashMap(i32).init(allocator);
    defer map.deinit();

    // Insert name-age pairs
    try map.put("Alice", 30);
    try map.put("Bob", 25);
    try map.put("Charlie", 35);

    std.debug.print("   Added people with ages\n", .{});

    // Lookup by name
    if (map.get("Alice")) |age| {
        std.debug.print("   Alice's age: {}\n", .{age});
    }

    if (map.get("Bob")) |age| {
        std.debug.print("   Bob's age: {}\n", .{age});
    }

    // getOrPut - get existing or insert new
    const result = try map.getOrPut("David");
    if (!result.found_existing) {
        result.value_ptr.* = 28;
        std.debug.print("   David wasn't found, added with age 28\n", .{});
    }

    std.debug.print("   Total people: {}\n\n", .{map.count()});
}

/// Demonstrates different ways to iterate over HashMap
fn demoIteration(allocator: std.mem.Allocator) !void {
    std.debug.print("3. Iterating over HashMap:\n", .{});

    var map = std.StringHashMap(i32).init(allocator);
    defer map.deinit();

    try map.put("apple", 5);
    try map.put("banana", 3);
    try map.put("orange", 7);
    try map.put("grape", 12);

    // Iterate over key-value pairs
    std.debug.print("   Inventory:\n", .{});
    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        std.debug.print("     {s}: {} items\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // Iterate and modify values
    std.debug.print("\n   Doubling all quantities...\n", .{});
    var iter = map.valueIterator();
    while (iter.next()) |value_ptr| {
        value_ptr.* *= 2;
    }

    // Verify the changes
    std.debug.print("   Updated inventory:\n", .{});
    var iter2 = map.iterator();
    while (iter2.next()) |entry| {
        std.debug.print("     {s}: {} items\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // Key-only iteration
    std.debug.print("\n   All keys: ", .{});
    var key_iter = map.keyIterator();
    while (key_iter.next()) |key| {
        std.debug.print("{s} ", .{key.*});
    }
    std.debug.print("\n", .{});
}

/// Example: Using HashMap for counting word occurrences
pub fn wordCountExample(allocator: std.mem.Allocator) !void {
    std.debug.print("\n4. Practical Example - Word Counter:\n", .{});

    const text = "the quick brown fox jumps over the lazy dog the fox";

    var word_count = std.StringHashMap(usize).init(allocator);
    defer word_count.deinit();

    // Split text by spaces and count occurrences
    var iter = std.mem.splitScalar(u8, text, ' ');
    while (iter.next()) |word| {
        const result = try word_count.getOrPut(word);
        if (result.found_existing) {
            result.value_ptr.* += 1;
        } else {
            result.value_ptr.* = 1;
        }
    }

    std.debug.print("   Text: \"{s}\"\n", .{text});
    std.debug.print("   Word counts:\n", .{});
    var count_iter = word_count.iterator();
    while (count_iter.next()) |entry| {
        std.debug.print("     '{s}': {} time(s)\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}
