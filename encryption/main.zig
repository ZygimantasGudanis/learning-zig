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

pub fn main() !void {}

test "AES128" {
    std.debug.print("AES 128 \n", .{});
    var testText: [4][4]u8 = [4][4]u8{
        [_]u8{ 0x54, 0x71, 0x6b, 0x6f },
        [_]u8{ 0x68, 0x75, 0x20, 0x77 },
        [_]u8{ 0x65, 0x69, 0x62, 0x6e },
        [_]u8{ 0x20, 0x63, 0x72, 0x20 },
    };
    const hardKey3 = [16]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    printArray(&testText);
    std.debug.print("encoded AES 128 \n", .{});
    var result = try aesencoder.aes128(testText, hardKey3); //aes128(testText);
    printArray(&result);

    std.debug.print("\nDecoded AES 128 \n", .{});
    result = try aesdecoder.aes128(result, hardKey3);
    printArray(&result);
}
