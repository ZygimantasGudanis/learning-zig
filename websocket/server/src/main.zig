const std = @import("std");
const net = std.net;

const incommingConnMutex = std.Thread.Mutex{};

pub fn main() !void {
    try loop();
}

fn loop() !void {
    var heap = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = heap.deinit();
    const alloc = heap.allocator();

    var conns = std.ArrayList(net.Server.Connection).init(alloc);
    var incomingConns = std.ArrayList(net.Server.Connection).init(alloc);
    defer {
        for (conns.items) |conn| {
            conn.stream.close();
        }
        conns.deinit();
    }

    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);

    var server: std.net.Server = try address.listen(.{});
    defer server.deinit();
    var close = false;

    const incommingConnThread = try std.Thread.spawn(.{}, accepConnectionLoop, .{ &server, &incomingConns, &close });
    defer {
        close = true;
        incommingConnThread.join();
    }

    while (true) {
        try connectedClient(alloc, &conns, &incomingConns);
    }
}

pub fn connectedClient(alloc: std.mem.Allocator, conns: *std.ArrayList(net.Server.Connection), incommingConns: *std.ArrayList(net.Server.Connection)) !void {
    while (true) {
        std.time.sleep(1_000);
        if (incommingConns.*.items.len > 0) {
            sourceLock(incommingConnMutex);

            try conns.appendSlice(incommingConns.*.items);
            incommingConns.*.clearAndFree();

            sourceUnLock(incommingConnMutex);
        }
        if (conns.*.items.len == 0) {
            continue;
        }

        var index: u32 = 0;
        while (index < conns.*.items.len) : (index += 1) {
            // TODO: How to manage this array of connections
            _ = conns.*.items[index].stream.write("s") catch |err| {
                std.debug.print("Remove conn: {}\n", .{err});
                _ = conns.*.swapRemove(index);
                if (conns.*.items.len == 0) {
                    conns.*.clearAndFree();
                    continue;
                }
                if (index != 0) {
                    index -= 1;
                }
                continue;
            };

            const result = read(alloc, conns.*.items[index]) catch |err| {
                std.debug.print("Remove conn: {}\n", .{err});
                _ = conns.*.swapRemove(index);
                if (conns.*.items.len == 0) {
                    conns.*.clearAndFree();
                    continue;
                }
                if (index != 0) {
                    index -= 1;
                }
                continue;
            };

            defer result.deinit();
            if (result.items.len > 0) {
                //std.debug.print("Size: {d} | Output: {s}\n", .{ result.items.len, result.items });
                var writeIndex: u32 = 0;
                while (writeIndex < conns.*.items.len) : (writeIndex += 1) {
                    write(result.items, conns.*.items[writeIndex]) catch {
                        //conns.*.replaceRange(i, 1, undefined);
                        _ = conns.*.swapRemove(writeIndex);
                        if (conns.*.items.len == 0) {
                            conns.*.clearAndFree();
                            continue;
                        }
                        if (writeIndex != 0) {
                            writeIndex -= 1;
                        }
                    };
                }
            }
        }
    }
}

//Dispose result after return
pub fn read(alloc: std.mem.Allocator, conn: net.Server.Connection) !std.ArrayList(u8) {
    var buf: [256]u8 = undefined;
    var streamResult = std.ArrayList(u8).init(alloc);
    var bytes: usize = 1;
    //while (bytes > 0) {
    bytes = conn.stream.read(&buf) catch |err| {
        //std.debug.print("Error caught: {}\n", .{err});
        return err;
    };

    if (bytes > 0) {
        //std.debug.print("[INFO] Received {d} bytes from client - {s}\n", .{ bytes, buf[0..bytes] });
        streamResult.writer().writeAll(buf[0..bytes]) catch |err| {
            //std.debug.print("Error caught:\n", .{});
            return err;
        };
    }
    //}

    if (streamResult.items.len > 0) {
        std.debug.print("[INFO] Received {d} bytes from client - {s}\n", .{ bytes, streamResult.items });
    }
    return streamResult;
}

pub fn write(body: []u8, conn: net.Server.Connection) !void {
    if (body.len == 0) {
        return;
    }

    if (body.len <= 256) {
        _ = try conn.stream.write(body);
        return;
    }
}

fn accepConnectionLoop(server: *std.net.Server, incommingConns: *std.ArrayList(net.Server.Connection), close: *bool) !void {
    while (!close.*) {
        const conn = server.accept() catch {
            continue;
        };

        sourceLock(incommingConnMutex);
        try incommingConns.append(conn);
        sourceUnLock(incommingConnMutex);
    }
}

fn sourceLock(mutex: std.Thread.Mutex) void {
    var m = mutex;
    while (!m.tryLock()) {
        std.time.sleep(1_000_000);
    }
}

fn sourceUnLock(mutex: std.Thread.Mutex) void {
    var m = mutex;
    m.unlock();
}
