const std = @import("std");

const mixer = [_][4]i32{
    [_]i32{ 2, 3, 1, 1 },
    [_]i32{ 1, 2, 3, 1 },
    [_]i32{ 1, 1, 2, 3 },
    [_]i32{ 3, 1, 1, 2 },
};

const keyblock = struct { items: [16]u8 };

const block = struct { items: [4][4]i32 };

pub fn main() !void {
    std.debug.print("Hello world \n", .{});
}

// fn keyexpansion(key: []u8, password: []u8) void {
//     var
// }

fn generatekey(size: u8) ![]u8 {
    const alloc = std.heap.page_allocator;
    var array = std.ArrayList(u8).init(alloc);
    defer array.deinit();
    var i: u8 = 0;
    while (i < size) : (i += 1) {
        const byte = std.crypto.random.int(u8);
        std.debug.print("{}\n", .{byte});
        try array.append(byte);
    }

    return array.items;
}

fn addKey(data: block, key: block) void {
    var i: u8 = 0;
    var u: u8 = 0;
    while (i < data.items.len) : (i += 1) {
        while (u < data.items[i].len) : (u += 1) {
            data.items[i][u] = data.items[i][u] ^ key[i][u];
        }
    }
}

test "testing xor" {
    var a: i32 = 0b0011_0011;
    const b: i32 = 0b1111_0001;

    a = a ^ b;

    std.debug.print("{b}\n", .{a});
}

test "random byte array" {
    const array = generatekey(16) catch |err| switch (err) {
        else => {
            return;
        },
    };

    std.debug.print("{}\n", .{array.len});

    //std.testing.expect();
}
