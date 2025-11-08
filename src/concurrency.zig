const std = @import("std");

/// Demonstrates concurrency patterns in Zig
pub fn demo(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Concurrency Demo ===\n\n", .{});

    try basicThreadExample();
    try threadPoolExample(allocator);
    try mutexExample();
    try atomicExample();
    try channelPatternExample(allocator);

    std.debug.print("\n=== Concurrency Demo Complete ===\n", .{});
}

/// 1. Basic thread creation and joining
fn basicThreadExample() !void {
    std.debug.print("1. Basic Thread Example:\n", .{});

    // Spawn a thread
    const thread = try std.Thread.spawn(.{}, workerThread, .{10});

    // Do some work in main thread
    std.debug.print("   Main thread: doing work...\n", .{});
    std.Thread.sleep(100 * std.time.ns_per_ms); // Sleep 100ms

    // Wait for thread to complete
    thread.join();
    std.debug.print("   Main thread: worker thread completed\n\n", .{});
}

fn workerThread(iterations: u32) void {
    std.debug.print("   Worker thread: starting with {} iterations\n", .{iterations});
    var i: u32 = 0;
    while (i < iterations) : (i += 1) {
        // Simulate work
        std.Thread.sleep(10 * std.time.ns_per_ms); // Sleep 10ms
    }
    std.debug.print("   Worker thread: completed all iterations\n", .{});
}

/// 2. Thread pool pattern
fn threadPoolExample(allocator: std.mem.Allocator) !void {
    std.debug.print("2. Thread Pool Example:\n", .{});

    const num_threads = 4;
    var threads: std.ArrayList(std.Thread) = .{};
    defer threads.deinit(allocator);

    // Spawn multiple threads
    std.debug.print("   Spawning {} worker threads...\n", .{num_threads});
    var i: usize = 0;
    while (i < num_threads) : (i += 1) {
        const thread = try std.Thread.spawn(.{}, numberedWorker, .{i});
        try threads.append(allocator, thread);
    }

    // Wait for all threads to complete
    std.debug.print("   Waiting for all threads to complete...\n", .{});
    for (threads.items) |thread| {
        thread.join();
    }
    std.debug.print("   All threads completed!\n\n", .{});
}

fn numberedWorker(id: usize) void {
    std.debug.print("   Thread {}: starting work\n", .{id});
    std.Thread.sleep(50 * std.time.ns_per_ms);
    std.debug.print("   Thread {}: finished work\n", .{id});
}

/// 3. Mutex for synchronization
fn mutexExample() !void {
    std.debug.print("3. Mutex Example (Thread-Safe Counter):\n", .{});

    var context = Counter{
        .value = 0,
        .mutex = std.Thread.Mutex{},
    };

    // Spawn threads that increment the counter
    const thread1 = try std.Thread.spawn(.{}, incrementCounter, .{&context});
    const thread2 = try std.Thread.spawn(.{}, incrementCounter, .{&context});
    const thread3 = try std.Thread.spawn(.{}, incrementCounter, .{&context});

    thread1.join();
    thread2.join();
    thread3.join();

    std.debug.print("   Final counter value: {} (expected: 3000)\n\n", .{context.value});
}

const Counter = struct {
    value: u32,
    mutex: std.Thread.Mutex,

    fn increment(self: *Counter) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.value += 1;
    }
};

fn incrementCounter(context: *Counter) void {
    var i: u32 = 0;
    while (i < 1000) : (i += 1) {
        context.increment();
    }
}

/// 4. Atomic operations (lock-free)
fn atomicExample() !void {
    std.debug.print("4. Atomic Operations Example:\n", .{});

    var atomic_counter = std.atomic.Value(u32).init(0);

    // Spawn threads that atomically increment
    const thread1 = try std.Thread.spawn(.{}, atomicIncrement, .{&atomic_counter});
    const thread2 = try std.Thread.spawn(.{}, atomicIncrement, .{&atomic_counter});
    const thread3 = try std.Thread.spawn(.{}, atomicIncrement, .{&atomic_counter});

    thread1.join();
    thread2.join();
    thread3.join();

    const final_value = atomic_counter.load(.monotonic);
    std.debug.print("   Final atomic counter: {} (expected: 3000)\n", .{final_value});
    std.debug.print("   Atomics are lock-free and faster than mutex!\n\n", .{});
}

fn atomicIncrement(counter: *std.atomic.Value(u32)) void {
    var i: u32 = 0;
    while (i < 1000) : (i += 1) {
        _ = counter.fetchAdd(1, .monotonic);
    }
}

/// 5. Channel-like pattern using mutex and condition
fn channelPatternExample(allocator: std.mem.Allocator) !void {
    std.debug.print("5. Producer-Consumer Pattern:\n", .{});

    var channel = Channel.init(allocator);
    defer channel.deinit();

    // Producer thread
    const producer = try std.Thread.spawn(.{}, producerThread, .{&channel});

    // Consumer thread
    const consumer = try std.Thread.spawn(.{}, consumerThread, .{&channel});

    producer.join();
    consumer.join();

    std.debug.print("\n", .{});
}

const Channel = struct {
    queue: std.ArrayList(u32),
    mutex: std.Thread.Mutex,
    allocator: std.mem.Allocator,
    closed: bool,

    fn init(allocator: std.mem.Allocator) Channel {
        return .{
            .queue = .{},
            .mutex = .{},
            .allocator = allocator,
            .closed = false,
        };
    }

    fn deinit(self: *Channel) void {
        self.queue.deinit(self.allocator);
    }

    fn send(self: *Channel, value: u32) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        try self.queue.append(self.allocator, value);
    }

    fn receive(self: *Channel) ?u32 {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.queue.items.len > 0) {
            return self.queue.orderedRemove(0);
        }
        return null;
    }

    fn close(self: *Channel) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.closed = true;
    }

    fn isClosed(self: *Channel) bool {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.closed;
    }
};

fn producerThread(channel: *Channel) void {
    std.debug.print("   Producer: starting to send messages\n", .{});
    var i: u32 = 1;
    while (i <= 5) : (i += 1) {
        channel.send(i) catch |err| {
            std.debug.print("   Producer: error sending {}: {}\n", .{ i, err });
            return;
        };
        std.debug.print("   Producer: sent {}\n", .{i});
        std.Thread.sleep(100 * std.time.ns_per_ms);
    }
    channel.close();
    std.debug.print("   Producer: closed channel\n", .{});
}

fn consumerThread(channel: *Channel) void {
    std.debug.print("   Consumer: waiting for messages\n", .{});
    while (true) {
        if (channel.receive()) |value| {
            std.debug.print("   Consumer: received {}\n", .{value});
        } else {
            if (channel.isClosed()) {
                std.debug.print("   Consumer: channel closed, exiting\n", .{});
                break;
            }
            std.Thread.sleep(50 * std.time.ns_per_ms);
        }
    }
}

/// Advanced example: Parallel computation
pub fn advancedExample(allocator: std.mem.Allocator) !void {
    std.debug.print("\n=== Advanced Concurrency Example ===\n", .{});
    std.debug.print("Parallel Array Processing:\n\n", .{});

    // Create a large array
    const array_size = 1_000_000;
    var numbers: std.ArrayList(u32) = .{};
    defer numbers.deinit(allocator);

    // Fill with numbers
    var i: u32 = 0;
    while (i < array_size) : (i += 1) {
        try numbers.append(allocator, i);
    }

    // Single-threaded sum
    const start_single = std.time.milliTimestamp();
    var sum_single: u64 = 0;
    for (numbers.items) |num| {
        sum_single += num;
    }
    const time_single = std.time.milliTimestamp() - start_single;
    std.debug.print("Single-threaded sum: {} (took {}ms)\n", .{ sum_single, time_single });

    // Multi-threaded sum
    const num_threads = 4;
    const chunk_size = array_size / num_threads;

    var contexts: [4]SumContext = undefined;
    var threads: [4]std.Thread = undefined;

    const start_multi = std.time.milliTimestamp();

    // Spawn worker threads
    for (0..num_threads) |thread_id| {
        const start_idx = thread_id * chunk_size;
        const end_idx = if (thread_id == num_threads - 1) array_size else (thread_id + 1) * chunk_size;

        contexts[thread_id] = SumContext{
            .numbers = numbers.items[start_idx..end_idx],
            .sum = 0,
        };

        threads[thread_id] = try std.Thread.spawn(.{}, sumWorker, .{&contexts[thread_id]});
    }

    // Wait for all threads and collect results
    var sum_multi: u64 = 0;
    for (0..num_threads) |thread_id| {
        threads[thread_id].join();
        sum_multi += contexts[thread_id].sum;
    }

    const time_multi = std.time.milliTimestamp() - start_multi;
    std.debug.print("Multi-threaded sum:  {} (took {}ms)\n", .{ sum_multi, time_multi });
    std.debug.print("Speedup: {d:.2}x\n", .{@as(f64, @floatFromInt(time_single)) / @as(f64, @floatFromInt(time_multi))});
}

const SumContext = struct {
    numbers: []const u32,
    sum: u64,
};

fn sumWorker(context: *SumContext) void {
    var sum: u64 = 0;
    for (context.numbers) |num| {
        sum += num;
    }
    context.sum = sum;
}
