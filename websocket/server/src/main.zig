const std = @import("std");
const net = std.net;

const message = struct { timestamp: u64, body: *const []u8 };

pub fn main() !void {
    try loop();
}

fn loop() !void {
    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);

    var buf: [256]u8 = undefined;
    var server = try address.listen(.{});

    defer server.deinit();

    while (true) {
        const conn = try server.accept();

        const bytes = try conn.stream.read(&buf);
        std.debug.print("[INFO] Received {d} bytes from client - {s}\n", .{ bytes, buf });
        //conn.stream.write("");

        conn.stream.close();
    }
}

// WHAT IS A HASHMAP
