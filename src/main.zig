const std = @import("std");
const array_list = @import("array_list.zig");
const hashtable = @import("hashtable.zig");
const structs = @import("structs.zig");
const constructors = @import("constructors.zig");
const interfaces = @import("interfaces.zig");
const strings = @import("strings.zig");
const errors = @import("errors.zig");
const concurrency = @import("concurrency.zig");

pub fn main() !void {
    // Setup allocator for memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // If no arguments or --help, show usage
    if (args.len == 1) {
        try runAllDemos(allocator);
    } else if (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
        printHelp();
    } else if (std.mem.eql(u8, args[1], "--list") or std.mem.eql(u8, args[1], "-l")) {
        printList();
    } else {
        // Run specific demo
        try runDemo(allocator, args[1]);
    }
}

fn printHelp() void {
    std.debug.print(
        \\Zig 101 - Learning Zig Programming Examples
        \\
        \\USAGE:
        \\    zig101 [DEMO_NAME]
        \\
        \\OPTIONS:
        \\    --help, -h     Show this help message
        \\    --list, -l     List all available demos
        \\
        \\EXAMPLES:
        \\    zig101                 # Run all demos
        \\    zig101 arraylist       # Run only ArrayList demo
        \\    zig101 concurrency     # Run only Concurrency demo
        \\
        \\Run 'zig101 --list' to see all available demos.
        \\
    , .{});
}

fn printList() void {
    std.debug.print(
        \\Available Demos:
        \\
        \\  arraylist          - ArrayList operations with multiple types
        \\  hashtable          - HashMap/HashTable key-value storage
        \\  structs            - Struct definitions and methods
        \\  constructors       - Constructor pattern examples
        \\  interfaces         - Interface pattern implementations
        \\  strings            - String manipulation utilities
        \\  errors             - Error handling patterns
        \\  concurrency        - Multi-threading and synchronization
        \\  all                - Run all demos (default)
        \\
        \\USAGE:
        \\    zig build run -- [DEMO_NAME]
        \\
        \\EXAMPLES:
        \\    zig build run                      # Run all demos
        \\    zig build run -- arraylist         # Run ArrayList demo only
        \\    zig build run -- concurrency       # Run Concurrency demo only
        \\
    , .{});
}

fn runDemo(allocator: std.mem.Allocator, demo_name: []const u8) !void {
    // Use std.meta.stringToEnum for cleaner pattern matching
    const DemoType = enum {
        arraylist,
        hashtable,
        structs,
        constructors,
        interfaces,
        strings,
        errors,
        concurrency,
        all,
    };

    const demo = std.meta.stringToEnum(DemoType, demo_name) orelse {
        std.debug.print("Unknown demo: '{s}'\n\n", .{demo_name});
        printList();
        return error.UnknownDemo;
    };

    switch (demo) {
        .arraylist => {
            try array_list.demo(allocator);
        },
        .hashtable => {
            try hashtable.demo(allocator);
            try hashtable.wordCountExample(allocator);
        },
        .structs => {
            try structs.demo(allocator);
            try structs.studentExample(allocator);
        },
        .constructors => {
            try constructors.demo(allocator);
            try constructors.complexConstructorExample(allocator);
        },
        .interfaces => {
            try interfaces.demo(allocator);
            try interfaces.writerInterfaceExample();
        },
        .strings => {
            try strings.demo(allocator);
            try strings.advancedExample(allocator);
        },
        .errors => {
            try errors.demo(allocator);
            try errors.advancedErrorExample();
        },
        .concurrency => {
            try concurrency.demo(allocator);
            try concurrency.advancedExample(allocator);
        },
        .all => {
            try runAllDemos(allocator);
        },
    }
}

fn runAllDemos(allocator: std.mem.Allocator) !void {
    std.debug.print("\n========================================\n", .{});
    std.debug.print("Running All Zig 101 Demos\n", .{});
    std.debug.print("========================================\n", .{});

    // Run the ArrayList demo
    try array_list.demo(allocator);

    // Run the HashMap demo
    try hashtable.demo(allocator);

    // Run the word count example
    try hashtable.wordCountExample(allocator);

    // Run the Struct demo
    try structs.demo(allocator);

    // Run the student example
    try structs.studentExample(allocator);

    // Run the Constructor patterns demo
    try constructors.demo(allocator);

    // Run the complex constructor example
    try constructors.complexConstructorExample(allocator);

    // Run the Interface patterns demo
    try interfaces.demo(allocator);

    // Run the writer interface example
    try interfaces.writerInterfaceExample();

    // Run the String manipulation demo
    try strings.demo(allocator);

    // Run the advanced string example
    try strings.advancedExample(allocator);

    // Run the Error handling demo
    try errors.demo(allocator);

    // Run the advanced error example
    try errors.advancedErrorExample();

    // Run the Concurrency demo
    try concurrency.demo(allocator);

    // Run the advanced concurrency example
    try concurrency.advancedExample(allocator);

    std.debug.print("\n========================================\n", .{});
    std.debug.print("All Demos Completed!\n", .{});
    std.debug.print("========================================\n\n", .{});
}
