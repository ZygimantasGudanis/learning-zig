const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);
    const conn = try net.tcpConnectToAddress(address);
    defer conn.close();

    _ = try conn.write("Hello world \n");

    var buf: [256]u8 = undefined;
    _ = try conn.read(buf[0..]);
}

// fn s () void {
//     const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, 5101);
//     var server = address.getOsSockLen();
//     defer server.deinit();

//     var client = try server.accept();

//     _ = client.stream.write("Hope this works\n") catch |err| switch (err) {
//         else => {
//             std.debug.print("Failed {}", .{err});
//             return;
//         },
//     };
//     std.debug.print("Sent {d}", .{address.getPort()});
// }
