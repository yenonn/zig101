const std = @import("std");

// This is the root file for the zig101 module.
// Add any public functions or declarations you want to expose here.

test "basic test" {
    try std.testing.expectEqual(1, 1);
}