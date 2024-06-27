const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);
    const conn = try net.tcpConnectToAddress(address);
    //defer std.net.Stream.close(conn);
    defer conn.close();

    for (0..16) |_| {
        _ = try conn.write(" Hello world");
        std.time.sleep(1_000_000);
        // var buf: [256]u8 = undefined;
        // _ = try conn.read(buf[0..]);
    }

    while (true) {}
}
