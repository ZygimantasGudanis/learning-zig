const std = @import("std");

pub const Packet = struct { size: usize, data: []u8 };

pub const ServerSocket = struct {
    socket: std.net.Server,
    connections: [8]std.net.Stream,

    pub fn init(host: []const u8, port: u16) !ServerSocket {
        const address = try std.net.Address.parseIp4(host, port);
        const socket = ServerSocket;
        socket.socket = try address.listen(.{});

        return socket;
    }
};

// pub fn send(self: ServerSocket, connection: u8, message: []u8) !void {
//     const connection = self.connections[connection];

//     connection.read(buffer: []u8)
// }

pub const Client = struct {
    socket: std.net.Stream,

    pub fn init(host: []const u8, port: u16) !Client {
        const address = try std.net.Address.parseIp4(host, port);
        const client = Client;
        client.socket = try std.net.tcpConnectToAddress(address);

        return client;
    }
};
