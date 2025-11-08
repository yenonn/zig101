const std = @import("std");

/// Demonstrates different constructor patterns in Zig
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Constructor Patterns Demo ===\n\n", .{});

    try demoBasicConstructor();
    try demoConstructorWithValidation();
    try demoConstructorWithDefaults();
    try demoConstructorWithAllocator(allocator);

    std.debug.print("\n=== Constructor Demo Complete ===\n", .{});
}

/// Pattern 1: Basic Constructor
fn demoBasicConstructor() !void {
    std.debug.print("1. Basic Constructor Pattern:\n", .{});

    const Point = struct {
        x: f32,
        y: f32,

        const Self = @This();

        // Simple constructor
        pub fn init(x_val: f32, y_val: f32) Self {
            return Self{
                .x = x_val,
                .y = y_val,
            };
        }

        // Alternative: Zero constructor
        pub fn zero() Self {
            return Self{ .x = 0.0, .y = 0.0 };
        }

        // Alternative: From array
        pub fn fromArray(arr: [2]f32) Self {
            return Self{ .x = arr[0], .y = arr[1] };
        }
    };

    const p1 = Point.init(10.5, 20.3);
    const p2 = Point.zero();
    const p3 = Point.fromArray([_]f32{ 5.0, 15.0 });

    std.debug.print("   Point 1: ({d:.1}, {d:.1})\n", .{ p1.x, p1.y });
    std.debug.print("   Point 2 (zero): ({d:.1}, {d:.1})\n", .{ p2.x, p2.y });
    std.debug.print("   Point 3 (from array): ({d:.1}, {d:.1})\n\n", .{ p3.x, p3.y });
}

/// Pattern 2: Constructor with Validation
fn demoConstructorWithValidation() !void {
    std.debug.print("2. Constructor with Validation:\n", .{});

    const Age = struct {
        value: u8,

        const Self = @This();

        // Constructor that can fail
        pub fn init(age: u8) !Self {
            if (age > 150) {
                return error.InvalidAge;
            }
            return Self{ .value = age };
        }

        // Safe constructor with default on error
        pub fn initSafe(age: u8) Self {
            return Self{
                .value = if (age > 150) 0 else age,
            };
        }
    };

    const age1 = try Age.init(25);
    const age2 = Age.initSafe(200); // Too high, will use 0

    std.debug.print("   Valid age: {}\n", .{age1.value});
    std.debug.print("   Invalid age (safe): {}\n", .{age2.value});

    // This would fail
    const age3 = Age.init(200) catch |err| {
        std.debug.print("   Error creating age 200: {}\n\n", .{err});
        return;
    };
    std.debug.print("   Age 3: {}\n\n", .{age3.value});
}

/// Pattern 3: Constructor with Default Values
fn demoConstructorWithDefaults() !void {
    std.debug.print("3. Constructor with Default Values:\n", .{});

    const Server = struct {
        host: []const u8,
        port: u16,
        timeout_ms: u32,
        max_connections: u32,

        const Self = @This();

        // Full constructor
        pub fn init(host: []const u8, port: u16, timeout_ms: u32, max_connections: u32) Self {
            return Self{
                .host = host,
                .port = port,
                .timeout_ms = timeout_ms,
                .max_connections = max_connections,
            };
        }

        // Constructor with defaults
        pub fn initDefault(host: []const u8) Self {
            return Self{
                .host = host,
                .port = 8080,
                .timeout_ms = 5000,
                .max_connections = 100,
            };
        }

        // Builder pattern - start with defaults, then customize
        pub fn builder() Self {
            return Self{
                .host = "localhost",
                .port = 8080,
                .timeout_ms = 5000,
                .max_connections = 100,
            };
        }

        pub fn withPort(self: Self, port: u16) Self {
            var new = self;
            new.port = port;
            return new;
        }

        pub fn withTimeout(self: Self, timeout: u32) Self {
            var new = self;
            new.timeout_ms = timeout;
            return new;
        }
    };

    const server1 = Server.initDefault("example.com");
    std.debug.print("   Server 1: {s}:{} (timeout: {}ms)\n", .{ server1.host, server1.port, server1.timeout_ms });

    // Builder pattern
    const server2 = Server.builder()
        .withPort(3000)
        .withTimeout(10000);
    std.debug.print("   Server 2: {s}:{} (timeout: {}ms)\n\n", .{ server2.host, server2.port, server2.timeout_ms });
}

/// Pattern 4: Constructor with Allocator (for dynamic memory)
fn demoConstructorWithAllocator(allocator: std.mem.Allocator) !void {
    std.debug.print("4. Constructor with Allocator:\n", .{});

    const Person = struct {
        name: []const u8,
        age: u8,
        hobbies: std.array_list.AlignedManaged([]const u8, null),

        const Self = @This();

        // Constructor that needs allocator
        pub fn init(alloc: std.mem.Allocator, name: []const u8, age: u8) Self {
            return Self{
                .name = name,
                .age = age,
                .hobbies = std.array_list.AlignedManaged([]const u8, null).init(alloc),
            };
        }

        // Don't forget the destructor!
        pub fn deinit(self: *Self) void {
            self.hobbies.deinit();
        }

        pub fn addHobby(self: *Self, hobby: []const u8) !void {
            try self.hobbies.append(hobby);
        }

        pub fn print(self: Self) void {
            std.debug.print("   Name: {s}, Age: {}\n", .{ self.name, self.age });
            std.debug.print("   Hobbies: ", .{});
            for (self.hobbies.items, 0..) |hobby, i| {
                if (i > 0) std.debug.print(", ", .{});
                std.debug.print("{s}", .{hobby});
            }
            std.debug.print("\n", .{});
        }
    };

    var person = Person.init(allocator, "Alice", 30);
    defer person.deinit(); // Always clean up!

    try person.addHobby("Reading");
    try person.addHobby("Coding");
    try person.addHobby("Gaming");

    person.print();
}

/// Practical Example: Complex Constructor Pattern
pub fn complexConstructorExample(allocator: std.mem.Allocator) !void {
    std.debug.print("\n5. Complex Constructor Example - Database Connection:\n", .{});

    const Database = struct {
        host: []const u8,
        port: u16,
        username: []const u8,
        password: []const u8,
        database: []const u8,
        connected: bool,

        const Self = @This();

        // Constructor with all parameters
        pub fn init(
            host: []const u8,
            port: u16,
            username: []const u8,
            password: []const u8,
            database: []const u8,
        ) Self {
            return Self{
                .host = host,
                .port = port,
                .username = username,
                .password = password,
                .database = database,
                .connected = false,
            };
        }

        // Constructor with connection string
        pub fn fromConnectionString(conn_str: []const u8) !Self {
            // In real code, parse the connection string
            _ = conn_str;
            return Self{
                .host = "localhost",
                .port = 5432,
                .username = "user",
                .password = "pass",
                .database = "mydb",
                .connected = false,
            };
        }

        // Constructor for local development
        pub fn local(database: []const u8) Self {
            return Self{
                .host = "localhost",
                .port = 5432,
                .username = "dev",
                .password = "dev",
                .database = database,
                .connected = false,
            };
        }

        pub fn connect(self: *Self) !void {
            std.debug.print("   Connecting to {s}:{} ...\n", .{ self.host, self.port });
            // Simulate connection
            self.connected = true;
            std.debug.print("   Connected to database: {s}\n", .{self.database});
        }

        pub fn disconnect(self: *Self) void {
            if (self.connected) {
                std.debug.print("   Disconnecting from {s}\n", .{self.database});
                self.connected = false;
            }
        }
    };

    _ = allocator;

    // Example 1: Using the full init() constructor
    std.debug.print("\n   Example 1 - Full init() constructor:\n", .{});
    std.debug.print("   Usage: Database.init(host, port, username, password, database)\n", .{});
    var db1 = Database.init("prod.example.com", 5432, "admin", "secret123", "production");
    std.debug.print("   Result -> host: {s}, port: {}, user: {s}\n", .{ db1.host, db1.port, db1.username });
    try db1.connect();
    defer db1.disconnect();
    std.debug.print("   Status: {s}\n", .{if (db1.connected) "Connected" else "Disconnected"});

    // Example 2: Using the local() constructor (simpler)
    std.debug.print("\n   Example 2 - local() constructor (convenience):\n", .{});
    std.debug.print("   Usage: Database.local(database) - only 1 parameter!\n", .{});
    var db2 = Database.local("my_app");
    std.debug.print("   Result -> host: {s}, port: {}, user: {s} (auto-filled!)\n", .{ db2.host, db2.port, db2.username });
    try db2.connect();
    defer db2.disconnect();
    std.debug.print("   Status: {s}\n", .{if (db2.connected) "Connected" else "Disconnected"});

    // Example 3: Using fromConnectionString() constructor
    std.debug.print("\n   Example 3 - From connection string:\n", .{});
    var db3 = try Database.fromConnectionString("postgresql://user:pass@localhost:5432/mydb");
    try db3.connect();
    defer db3.disconnect();
    std.debug.print("   Status: {s}\n", .{if (db3.connected) "Connected" else "Disconnected"});
}
