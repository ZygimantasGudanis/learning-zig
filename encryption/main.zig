const std = @import("std");
const aesencoder = @import("aesencoder.zig");
const aesdecoder = @import("aesdecoder.zig");

const printArray = struct {
    pub fn print(arr: [][4]u8) void {
        std.debug.print("\n", .{});
        for (arr) |row| {
            for (row) |item| {
                std.debug.print("|{x}", .{item});
            }
            std.debug.print("|\n", .{});
        }
    }
}.print;

const hardKey = [4][4]u8{
    [_]u8{ 124, 252, 10, 11 },
    [_]u8{ 65, 45, 105, 151 },
    [_]u8{ 74, 52, 140, 111 },
    [_]u8{ 24, 22, 102, 121 },
};

const hardKey2 = [16]u8{ 124, 252, 10, 11, 65, 45, 105, 151, 74, 52, 140, 111, 24, 22, 102, 121 };

// "1 block to encod"
const text = [4][4]u8{
    [_]u8{ '1', ' ', 'b', 'l' },
    [_]u8{ 'o', 'c', 'k', ' ' },
    [_]u8{ 't', 'o', ' ', 'e' },
    [_]u8{ 'n', 'c', 'o', 'd' },
};

const testText: [4][4]u8 = [4][4]u8{
    [_]u8{ 0x54, 0x71, 0x6b, 0x6f },
    [_]u8{ 0x68, 0x75, 0x20, 0x77 },
    [_]u8{ 0x65, 0x69, 0x62, 0x6e },
    [_]u8{ 0x20, 0x63, 0x72, 0x20 },
};

pub fn main() !void {
    std.debug.print("AES 128 \n", .{});
    // const result = testText;
    // const key = hardKey;

    var result = try aesencoder.aes128(testText); //aes128(testText);

    // TODO: add key expansion logic
    // TODO:

    printArray(&result);
}

test "AES128" {
    std.debug.print("AES 128 \n", .{});
    // const result = testText;
    // const key = hardKey;

    var result = try aesencoder.aes128(testText);
    printArray(&result);
}
