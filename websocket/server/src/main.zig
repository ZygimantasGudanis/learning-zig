const std = @import("std");
const net = std.net;

const message = struct { timestamp: u64, body: *const []u8 };

pub fn main() !void {
    try loop();
}

fn loop() !void {
    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);

    var server = try address.listen(.{});

    defer server.deinit();

    while (true) {
        const conn = try server.accept();
        errdefer conn.stream.close();

        try connectedClient(conn);
    }
}

fn connectedClient(conn: net.Server.Connection) !void {
    var buf: [256]u8 = undefined;
    while (true) {
        const bytes = conn.stream.read(&buf) catch |err| switch (err) {
            else => {
                std.debug.print("Error caught: {}", .{err});
                conn.stream.close();
                break;
            },
        };

        if (bytes == 0) {
            //std.debug.print("Still trying to read", .{});
            _ = conn.stream.write("\n") catch |err| switch (err) {
                else => {
                    std.debug.print("Error caught: {}\n", .{err});
                    conn.stream.close();
                    break;
                },
            };
            continue;
        }
        std.debug.print("[INFO] Received {d} bytes from client - {s}\n", .{ bytes, buf[0..bytes] });
        //conn.stream.write("");

        //conn.stream.close();
    } else unreachable;
}

// WHAT IS A HASHMAP
