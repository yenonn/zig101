const std = @import("std");

pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== String Manipulation Demo ===\n", .{});

    // 1. String concatenation
    const first = "Hello";
    const second = "World";
    const concatenated = try std.fmt.allocPrint(allocator, "{s} {s}!", .{ first, second });
    defer allocator.free(concatenated);
    std.debug.print("Concatenated: {s}\n", .{concatenated});

    // 2. String splitting
    const sentence = "apple,banana,orange,grape";
    std.debug.print("\nSplitting '{s}' by comma:\n", .{sentence});
    var iter = std.mem.splitSequence(u8, sentence, ",");
    while (iter.next()) |part| {
        std.debug.print("  - {s}\n", .{part});
    }

    // 3. String trimming
    const whitespace = "   trim me   ";
    const trimmed = std.mem.trim(u8, whitespace, " ");
    std.debug.print("\nOriginal: '{s}'\n", .{whitespace});
    std.debug.print("Trimmed: '{s}'\n", .{trimmed});

    // 4. String contains/indexOf
    const haystack = "The quick brown fox";
    const needle = "quick";
    if (std.mem.indexOf(u8, haystack, needle)) |index| {
        std.debug.print("\nFound '{s}' at index {d} in '{s}'\n", .{ needle, index, haystack });
    }

    // 5. String replacement (manual with ArrayList)
    const original = "foo bar foo baz";
    const replaced = try replaceAll(allocator, original, "foo", "hello");
    defer allocator.free(replaced);
    std.debug.print("\nOriginal: '{s}'\n", .{original});
    std.debug.print("Replaced: '{s}'\n", .{replaced});

    // 6. String to uppercase/lowercase (ASCII only)
    const mixed = "HeLLo WoRLd";
    var buffer: [50]u8 = undefined;
    const lower = std.ascii.lowerString(&buffer, mixed);
    std.debug.print("\nOriginal: '{s}'\n", .{mixed});
    std.debug.print("Lowercase: '{s}'\n", .{lower});

    // 7. String formatting with numbers
    const formatted = try std.fmt.allocPrint(allocator, "Pi is approximately {d:.2}", .{3.14159});
    defer allocator.free(formatted);
    std.debug.print("\nFormatted: {s}\n", .{formatted});
}

// Helper function to replace all occurrences of a substring
fn replaceAll(allocator: std.mem.Allocator, input: []const u8, old: []const u8, new: []const u8) ![]u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    var i: usize = 0;
    while (i < input.len) {
        if (i + old.len <= input.len and std.mem.eql(u8, input[i .. i + old.len], old)) {
            try result.appendSlice(new);
            i += old.len;
        } else {
            try result.append(input[i]);
            i += 1;
        }
    }

    return result.toOwnedSlice();
}

pub fn advancedExample(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Advanced String Manipulation ===\n", .{});

    // Building a string dynamically
    var builder = std.ArrayList(u8).init(allocator);
    defer builder.deinit();

    try builder.appendSlice("Building ");
    try builder.appendSlice("a ");
    try builder.appendSlice("string ");
    try builder.appendSlice("dynamically!");

    std.debug.print("Built string: {s}\n", .{builder.items});

    // Parsing integers from strings
    const number_str = "42";
    const parsed = try std.fmt.parseInt(i32, number_str, 10);
    std.debug.print("\nParsed '{s}' as integer: {d}\n", .{ number_str, parsed });

    // Tokenizing with multiple delimiters
    const text = "one,two;three:four";
    std.debug.print("\nTokenizing '{s}' by multiple delimiters:\n", .{text});
    var token_iter = std.mem.tokenizeAny(u8, text, ",;:");
    while (token_iter.next()) |token| {
        std.debug.print("  - {s}\n", .{token});
    }

    // Checking string prefixes/suffixes
    const filename = "document.txt";
    if (std.mem.endsWith(u8, filename, ".txt")) {
        std.debug.print("\n'{s}' is a text file\n", .{filename});
    }
    if (std.mem.startsWith(u8, filename, "doc")) {
        std.debug.print("'{s}' starts with 'doc'\n", .{filename});
    }
}