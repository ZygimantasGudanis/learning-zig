const std = @import("std");

const sBox: [16][16]u8 = [16][16]u8{
    [16]u8{ 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76 },
    [16]u8{ 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0 },
    [16]u8{ 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15 },
    [16]u8{ 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75 },
    [16]u8{ 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84 },
    [16]u8{ 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf },
    [16]u8{ 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8 },
    [16]u8{ 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2 },
    [16]u8{ 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73 },
    [16]u8{ 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb },
    [16]u8{ 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79 },
    [16]u8{ 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08 },
    [16]u8{ 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a },
    [16]u8{ 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e },
    [16]u8{ 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf },
    [16]u8{ 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16 },
};

const hardKey = [4][4]u8{
    [_]u8{ 124, 252, 10, 11 },
    [_]u8{ 65, 45, 105, 151 },
    [_]u8{ 74, 52, 140, 111 },
    [_]u8{ 24, 22, 102, 121 },
};

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

const keyblock = struct { items: [16]u8 };

const block = struct { items: [4][4]i32 };

pub fn main() !void {
    std.debug.print("AES 128 \n", .{});
    var i: u8 = 0;
    var result = text;
    while (i < 10) : (i += 1) {
        // Substitute
        for (result) |row| {
            for (row) |value| {
                value = substitution(value);
            }
        }

        // RowShift
        rowShift(&result);
    }
}

// 128 bit 10 eounds

// 2. XOR with key
// 3. Substitution
// SBOX

// 4. Shift row
// First row not Change
// Second row shift by 1 to left
// third row shift by 2 to left
// fourth row shift by 3 to left

// 5. Mix Column
//  Matrix multiplication with mixer

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

fn substitution(array: [][4]u8) void {
    for (0..array.len) |row| {
        for (0..array[row].len) |column| {
            const x = array[row][column] / 16;
            const y = array[row][column] % 16;
            array[row][column] = sBox[x][y];
        }
    }
}

fn rowShift(body: [][4]u8) void {
    var i: u8 = 1;
    while (i < body.len) : (i += 1) {
        const row = body[i];
        for (row, 0..) |item, index| {
            var pos = body[i].len + index - i;
            if (pos >= body[i].len) {
                pos -= body[i].len;
            }
            body[i][pos] = item;
        }
    }
}
const mixer = [_][4]i32{
    [_]i32{ 2, 3, 1, 1 },
    [_]i32{ 1, 2, 3, 1 },
    [_]i32{ 1, 1, 2, 3 },
    [_]i32{ 3, 1, 1, 2 },
};

fn mixColums(body: [4][4]u8) [4][4]u8 {
    var result = body;
    for (body, 0..) |_, i| {
        result[0][i] = gmul(body[0][i], 2) ^ gmul(body[1][i], 3) ^ body[2][i] ^ body[3][i];
        result[1][i] = body[0][i] ^ gmul(result[1][i], 2) ^ gmul(result[2][i], 3) ^ body[3][i];
        result[2][i] = body[0][i] ^ body[1][i] ^ gmul(body[2][i], 2) ^ gmul(body[3][i], 3);
        result[3][i] = gmul(body[0][i], 3) ^ body[1][i] ^ body[2][i] ^ gmul(body[3][i], 2);
    }

    return result;
}

fn gmul(a: u8, b: u8) u8 {
    var tempA = a;
    var tempB = b;
    var p: u8 = 0x00;

    for (0..8) |_| {
        if ((tempB & 1) != 0) {
            p = p ^ tempA;
        }

        const high = (tempA & 0x80) != 0;
        tempA = tempA << 1;
        if (high) {
            tempA = tempA ^ 0x1b;
        }
        tempB = tempB >> 1;
    }
    return p;
}

test "TEst with test text" {
    const print = struct {
        pub fn print(arr: [][4]u8) void {
            for (arr) |row| {
                for (row) |item| {
                    std.debug.print("|{x}", .{item});
                }
                std.debug.print("|\n", .{});
            }
        }
    }.print;

    std.debug.print("\n", .{});
    var array = testText;
    print(&array);

    std.debug.print("Substitution\n", .{});
    substitution(&array);

    std.debug.print("RowShift\n", .{});
    rowShift(&array);
    print(&array);

    std.debug.print("Column shift\n", .{});
    array = mixColums(array);
    print(&array);
}
