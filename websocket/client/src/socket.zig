const std = @import("std");

pub const Packet = struct { size: usize, clientId: i32, data: []u8 };

pub const ServerSocket = struct {
    socket: std.net.Server,
    connections: std.net.Stream,
    buffer: u32,

    pub fn init(host: []const u8, port: u16, buffer: u32) !ServerSocket {
        const address = try std.net.Address.parseIp4(host, port);
        const socket = ServerSocket{ .buffer = buffer, .socket = try address.listen(.{}) };

        return socket;
    }

    pub fn accept(self: ServerSocket) !void {
        self.connections = try self.socket.accept();
    }

    pub fn send(self: ServerSocket, message: []const u8) !usize {
        const bytes = self.socket.write(message) catch |err| switch (err) {
            else => {
                return err;
            },
        };

        return bytes;
    }

    pub fn receive(self: ServerSocket) []u8 {
        var buffer: [self.buffer]u8 = undefined;
        while (true) {
            _ = self.socket.stream.read(&buffer);
            const bytes = try self.connections.read(&buffer);
            if (bytes == 0) {
                break;
            }
        }
    }

    pub fn close(self: ServerSocket) void {
        self.connections.close();
        self.socket.deinit();
    }
};

pub const Client = struct {
    socket: std.net.Stream,
    buffer: u32,

    pub fn init(host: []const u8, port: u16, buffer: u32) !Client {
        const address = try std.net.Address.parseIp4(host, port);
        const socket = try std.net.tcpConnectToAddress(address);

        const client = Client{ .buffer = buffer, .socket = socket };
        return client;
    }

    pub fn send(self: Client, message: []const u8) !usize {
        const bytes = self.socket.write(message) catch |err| switch (err) {
            else => {
                std.debug.print("Error: {}\n", .{err});
                return err;
            },
        };
        std.debug.print("Wrote: {}\n", .{bytes});
        return bytes;
    }

    pub fn receive(self: Client) []u8 {
        var buffer: [self.buffer]u8 = undefined;
        while (true) {
            const bytes = try self.socket.read(&buffer);
            if (bytes == 0) {
                continue;
            }
        }
    }

    pub fn close(self: Client) void {
        self.socket.close();
    }
};
