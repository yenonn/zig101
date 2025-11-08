const std = @import("std");

/// Demonstrates struct usage in Zig
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Struct Demo ===\n\n", .{});

    try demoBasicStruct();
    try demoStructMethods();
    try demoNestedStructs();
    try demoStructWithAllocator(allocator);

    std.debug.print("\n=== Struct Demo Complete ===\n", .{});
}

/// Basic struct definition and usage
fn demoBasicStruct() !void {
    std.debug.print("1. Basic Struct:\n", .{});

    // Define a simple struct
    const Point = struct {
        x: i32,
        y: i32,
    };

    // Create struct instances
    const p1 = Point{ .x = 10, .y = 20 };
    const p2 = Point{ .x = 5, .y = 15 };

    std.debug.print("   Point 1: ({}, {})\n", .{ p1.x, p1.y });
    std.debug.print("   Point 2: ({}, {})\n", .{ p2.x, p2.y });

    // Struct with default values
    const Config = struct {
        name: []const u8 = "default",
        port: u16 = 8080,
        debug: bool = false,
    };

    const config1 = Config{};
    const config2 = Config{ .name = "production", .port = 443, .debug = true };

    std.debug.print("\n   Config 1: {s}:{} (debug: {})\n", .{ config1.name, config1.port, config1.debug });
    std.debug.print("   Config 2: {s}:{} (debug: {})\n\n", .{ config2.name, config2.port, config2.debug });
}

/// Structs with methods (functions)
fn demoStructMethods() !void {
    std.debug.print("2. Struct Methods:\n", .{});

    const Rectangle = struct {
        width: f32,
        height: f32,

        const Self = @This();

        // Method to calculate area
        pub fn area(self: Self) f32 {
            return self.width * self.height;
        }

        // Method to calculate perimeter
        pub fn perimeter(self: Self) f32 {
            return 2 * (self.width + self.height);
        }

        // Method that modifies the struct (takes pointer)
        pub fn scale(self: *Self, factor: f32) void {
            self.width *= factor;
            self.height *= factor;
        }

        // Static method (doesn't take self)
        pub fn square(size: f32) Self {
            return Self{ .width = size, .height = size };
        }
    };

    var rect = Rectangle{ .width = 5.0, .height = 10.0 };
    std.debug.print("   Rectangle: {d}x{d}\n", .{ rect.width, rect.height });
    std.debug.print("   Area: {d:.2}\n", .{rect.area()});
    std.debug.print("   Perimeter: {d:.2}\n", .{rect.perimeter()});

    // Modify the rectangle
    rect.scale(2.0);
    std.debug.print("\n   After scaling by 2:\n", .{});
    std.debug.print("   Rectangle: {d:.2}x{d:.2}\n", .{ rect.width, rect.height });
    std.debug.print("   Area: {d:.2}\n", .{rect.area()});

    // Create using static method
    const sq = Rectangle.square(7.0);
    std.debug.print("\n   Square: {d:.2}x{d:.2}\n", .{ sq.width, sq.height });
    std.debug.print("   Area: {d:.2}\n\n", .{sq.area()});
}

/// Nested structs
fn demoNestedStructs() !void {
    std.debug.print("3. Nested Structs:\n", .{});

    const Address = struct {
        street: []const u8,
        city: []const u8,
        zip: []const u8,

        const Self = @This();

        pub fn toString(self: Self, allocator: std.mem.Allocator) ![]const u8 {
            return std.fmt.allocPrint(allocator, "{s}, {s} {s}", .{ self.street, self.city, self.zip });
        }
    };

    const Person = struct {
        name: []const u8,
        age: u8,
        address: Address,

        const Self = @This();

        pub fn introduce(self: Self) void {
            std.debug.print("   Hi! I'm {s}, {} years old.\n", .{ self.name, self.age });
            std.debug.print("   I live at: {s}, {s} {s}\n", .{ self.address.street, self.address.city, self.address.zip });
        }
    };

    const person = Person{
        .name = "Alice",
        .age = 30,
        .address = Address{
            .street = "123 Main St",
            .city = "Springfield",
            .zip = "12345",
        },
    };

    person.introduce();
    std.debug.print("\n", .{});
    const address = Address{
        .street = "399 Piasau Garden",
        .city = "Miri",
        .zip = "98000",
    };
    std.debug.print("   My home address: {s}\n", .{try address.toString(std.heap.page_allocator)});
}

/// Struct with allocator and dynamic memory
fn demoStructWithAllocator(allocator: std.mem.Allocator) !void {
    std.debug.print("4. Struct with Dynamic Memory:\n", .{});

    const DynamicArray = struct {
        items: std.array_list.AlignedManaged(i32, null),
        name: []const u8,

        const Self = @This();

        // Constructor
        pub fn init(alloc: std.mem.Allocator, array_name: []const u8) Self {
            return Self{
                .items = std.array_list.AlignedManaged(i32, null).init(alloc),
                .name = array_name,
            };
        }

        // Destructor
        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn add(self: *Self, value: i32) !void {
            try self.items.append(value);
        }

        pub fn print(self: Self) void {
            std.debug.print("   {s}: [", .{self.name});
            for (self.items.items, 0..) |item, i| {
                if (i > 0) std.debug.print(", ", .{});
                std.debug.print("{}", .{item});
            }
            std.debug.print("]\n", .{});
        }
    };

    var arr = DynamicArray.init(allocator, "MyNumbers");
    defer arr.deinit(); // Clean up memory

    try arr.add(10);
    try arr.add(20);
    try arr.add(30);
    try arr.add(40);

    arr.print();
    std.debug.print("   Length: {}\n", .{arr.items.items.len});
}

/// Practical example: Building a simple Student record system
pub fn studentExample(allocator: std.mem.Allocator) !void {
    std.debug.print("\n5. Practical Example - Student Records:\n", .{});

    const Grade = struct {
        subject: []const u8,
        score: u8,
    };

    const Student = struct {
        id: u32,
        name: []const u8,
        grades: std.array_list.AlignedManaged(Grade, null),

        const Self = @This();

        pub fn init(alloc: std.mem.Allocator, student_id: u32, student_name: []const u8) Self {
            return Self{
                .id = student_id,
                .name = student_name,
                .grades = std.array_list.AlignedManaged(Grade, null).init(alloc),
            };
        }

        pub fn deinit(self: *Self) void {
            self.grades.deinit();
        }

        pub fn addGrade(self: *Self, subject: []const u8, score: u8) !void {
            try self.grades.append(Grade{ .subject = subject, .score = score });
        }

        pub fn averageScore(self: Self) f32 {
            if (self.grades.items.len == 0) return 0.0;

            var total: u32 = 0;
            for (self.grades.items) |grade| {
                total += grade.score;
            }

            return @as(f32, @floatFromInt(total)) / @as(f32, @floatFromInt(self.grades.items.len));
        }

        pub fn printReport(self: Self) void {
            std.debug.print("\n   Student Report\n", .{});
            std.debug.print("   ID: {}\n", .{self.id});
            std.debug.print("   Name: {s}\n", .{self.name});
            std.debug.print("   Grades:\n", .{});
            for (self.grades.items) |grade| {
                std.debug.print("     - {s}: {}\n", .{ grade.subject, grade.score });
            }
            std.debug.print("   Average: {d:.2}\n", .{self.averageScore()});
        }
    };

    var student = Student.init(allocator, 12345, "Bob Smith");
    defer student.deinit();

    try student.addGrade("Math", 95);
    try student.addGrade("English", 88);
    try student.addGrade("Science", 92);
    try student.addGrade("History", 85);

    student.printReport();
}
