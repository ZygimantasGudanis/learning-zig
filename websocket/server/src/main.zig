const std = @import("std");
const net = std.net;

const message = struct { timestamp: u64, body: *const []u8 };

pub fn main() !void {
    try loop();
}

fn loop() !void {
    var heap = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = heap.deinit();
    const alloc = heap.allocator();

    var conns = std.ArrayList(net.Server.Connection).init(alloc);
    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);

    var server = try address.listen(.{});

    defer server.deinit();

    //std.Thread.

    while (true) {
        const conn = try server.accept();
        try conns.append(conn);
        const conn2 = try server.accept();
        try conns.append(conn2);

        errdefer {
            conn.stream.close();
            //conns[0] = null;
        }
        try connectedClient(alloc, &conns);
    }
}

pub fn connectedClient(alloc: std.mem.Allocator, conns: *std.ArrayList(net.Server.Connection)) !void {
    while (true) {
        if (conns.*.items.len == 0) {
            return;
        }

        for (conns.*.items) |conn| {
            const result = try read(alloc, conn);
            defer result.deinit();
        }
    }
}

//Dispose result after return
pub fn read(alloc: std.mem.Allocator, conn: net.Server.Connection) !std.ArrayList(u8) {
    var buf: [256]u8 = undefined;
    var streamResult = std.ArrayList(u8).init(alloc);
    var bytes: usize = 1;
    while (bytes != 0) {
        bytes = conn.stream.read(&buf) catch |err| {
            std.debug.print("Error caught: {}", .{err});
            return err;
        };
    }
    try streamResult.appendSlice(buf[0..bytes]);

    if (bytes == 0) {
        //std.debug.print("Still trying to read", .{});
        _ = conn.stream.write("\n") catch |err| {
            std.debug.print("Error caught: {}\n", .{err});
            conn.stream.close();
            return err;
        };
    } else {
        std.debug.print("[INFO] Received {d} bytes from client - {s}\n", .{ bytes, buf[0..bytes] });
    }

    return streamResult;
}
