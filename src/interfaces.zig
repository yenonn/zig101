const std = @import("std");

/// Demonstrates interface-like patterns in Zig
/// Note: Zig doesn't have "interfaces" like Java/Go, but uses:
/// 1. Duck typing with comptime
/// 2. Function pointers (vtables)
/// 3. anytype parameters
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Interface Patterns in Zig ===\n\n", .{});

    demoComptimePolymorphism();
    try demoVTablePattern(allocator);
    demoAnytypePattern();

    std.debug.print("\n=== Interface Demo Complete ===\n", .{});
}

// Types for Pattern 1: Duck Typing
const Dog = struct {
    name: []const u8,

    const Self = @This();

    pub fn speak(self: Self) void {
        std.debug.print("   {s} says: Woof!\n", .{self.name});
    }

    pub fn move(self: Self) void {
        std.debug.print("   {s} runs on four legs\n", .{self.name});
    }
};

const Cat = struct {
    name: []const u8,

    const Self = @This();

    pub fn speak(self: Self) void {
        std.debug.print("   {s} says: Meow!\n", .{self.name});
    }

    pub fn move(self: Self) void {
        std.debug.print("   {s} walks gracefully\n", .{self.name});
    }
};

const Bird = struct {
    name: []const u8,

    const Self = @This();

    pub fn speak(self: Self) void {
        std.debug.print("   {s} says: Tweet!\n", .{self.name});
    }

    pub fn move(self: Self) void {
        std.debug.print("   {s} flies in the sky\n", .{self.name});
    }
};

// Generic function - works with ANY type that has speak() and move()
fn makeAnimalAct(animal: anytype) void {
    animal.speak();
    animal.move();
}

/// Pattern 1: Compile-time polymorphism (Duck Typing)
fn demoComptimePolymorphism() void {
    std.debug.print("1. Compile-time Polymorphism (Duck Typing):\n", .{});
    std.debug.print("   Zig checks at compile-time if types have required methods\n\n", .{});

    const dog = Dog{ .name = "Buddy" };
    const cat = Cat{ .name = "Whiskers" };
    const bird = Bird{ .name = "Tweety" };

    std.debug.print("   Using generic makeAnimalAct() function:\n", .{});
    makeAnimalAct(dog);
    makeAnimalAct(cat);
    makeAnimalAct(bird);
    std.debug.print("\n", .{});
}

/// Pattern 2: VTable Pattern (Runtime Polymorphism)
fn demoVTablePattern(allocator: std.mem.Allocator) !void {
    std.debug.print("2. VTable Pattern (Runtime Polymorphism):\n", .{});
    std.debug.print("   Using function pointers for dynamic dispatch\n\n", .{});

    // Define an interface using a struct with function pointers
    const Shape = struct {
        ptr: *anyopaque,
        vtable: *const VTable,

        const VTable = struct {
            area: *const fn (ptr: *anyopaque) f32,
            describe: *const fn (ptr: *anyopaque) void,
        };

        pub fn area(self: @This()) f32 {
            return self.vtable.area(self.ptr);
        }

        pub fn describe(self: @This()) void {
            self.vtable.describe(self.ptr);
        }
    };

    const Rectangle = struct {
        width: f32,
        height: f32,

        fn area(ptr: *anyopaque) f32 {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            return self.width * self.height;
        }

        fn describe(ptr: *anyopaque) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.print("   Rectangle: {d:.1}x{d:.1}\n", .{ self.width, self.height });
        }

        const vtable = Shape.VTable{
            .area = area,
            .describe = describe,
        };

        pub fn shape(self: *@This()) Shape {
            return Shape{
                .ptr = self,
                .vtable = &vtable,
            };
        }
    };

    const Circle = struct {
        radius: f32,

        fn area(ptr: *anyopaque) f32 {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            return std.math.pi * self.radius * self.radius;
        }

        fn describe(ptr: *anyopaque) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.print("   Circle: radius {d:.1}\n", .{self.radius});
        }

        const vtable = Shape.VTable{
            .area = area,
            .describe = describe,
        };

        pub fn shape(self: *@This()) Shape {
            return Shape{
                .ptr = self,
                .vtable = &vtable,
            };
        }
    };

    var rect = Rectangle{ .width = 5.0, .height = 10.0 };
    var circ = Circle{ .radius = 7.0 };

    var shapes = std.array_list.AlignedManaged(Shape, null).init(allocator);
    defer shapes.deinit();

    try shapes.append(rect.shape());
    try shapes.append(circ.shape());

    std.debug.print("   Processing shapes dynamically:\n", .{});
    for (shapes.items) |shape| {
        shape.describe();
        std.debug.print("     Area: {d:.2}\n", .{shape.area()});
    }
    std.debug.print("\n", .{});
}

// Types for Pattern 3
const Book = struct {
    title: []const u8,
    author: []const u8,

    pub fn print(self: @This()) void {
        std.debug.print("   Book: '{s}' by {s}\n", .{ self.title, self.author });
    }
};

const Movie = struct {
    title: []const u8,
    director: []const u8,

    pub fn print(self: @This()) void {
        std.debug.print("   Movie: '{s}' directed by {s}\n", .{ self.title, self.director });
    }
};

// Generic function - works with ANY type that has print()
fn printItem(item: anytype) void {
    item.print();
}

/// Pattern 3: anytype (Most common in Zig)
fn demoAnytypePattern() void {
    std.debug.print("3. anytype Pattern (Zig's preferred way):\n", .{});
    std.debug.print("   Generic functions that work with any compatible type\n\n", .{});

    const book = Book{ .title = "1984", .author = "George Orwell" };
    const movie = Movie{ .title = "Inception", .director = "Christopher Nolan" };

    std.debug.print("   Using generic printItem() function:\n", .{});
    printItem(book);
    printItem(movie);
    std.debug.print("\n", .{});
}

/// Practical Example: Simplified Writer Interface
pub fn writerInterfaceExample() !void {
    std.debug.print("4. Practical Example - Simple Interface:\n", .{});
    std.debug.print("   Real-world pattern: Logger interface\n\n", .{});

    const Logger = struct {
        ptr: *anyopaque,
        vtable: *const VTable,

        const VTable = struct {
            log: *const fn (ptr: *anyopaque, message: []const u8) void,
        };

        pub fn log(self: @This(), message: []const u8) void {
            self.vtable.log(self.ptr, message);
        }
    };

    const ConsoleLogger = struct {
        prefix: []const u8,

        fn log(ptr: *anyopaque, message: []const u8) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.print("   [{s}] {s}\n", .{ self.prefix, message });
        }

        const vtable = Logger.VTable{
            .log = log,
        };

        pub fn logger(self: *@This()) Logger {
            return Logger{
                .ptr = self,
                .vtable = &vtable,
            };
        }
    };

    var console = ConsoleLogger{ .prefix = "INFO" };
    const logger = console.logger();

    logger.log("Application started");
    logger.log("Processing data...");
    logger.log("Complete!");
}
