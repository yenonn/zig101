const std = @import("std");
const array_list = @import("array_list.zig");
const hashtable = @import("hashtable.zig");
const structs = @import("structs.zig");
const constructors = @import("constructors.zig");
const interfaces = @import("interfaces.zig");
const strings = @import("strings.zig");
const errors = @import("errors.zig");

pub fn main() !void {
    // Setup allocator for memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

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
}
