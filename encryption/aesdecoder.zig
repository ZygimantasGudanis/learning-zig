const std = @import("std");
const common = @import("common.zig");

const inverseSBox: [16][16]u8 = [16][16]u8{
    [16]u8{ 0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb },
    [16]u8{ 0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb },
    [16]u8{ 0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e },
    [16]u8{ 0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25 },
    [16]u8{ 0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92 },
    [16]u8{ 0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84 },
    [16]u8{ 0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06 },
    [16]u8{ 0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b },
    [16]u8{ 0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73 },
    [16]u8{ 0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e },
    [16]u8{ 0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b },
    [16]u8{ 0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4 },
    [16]u8{ 0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f },
    [16]u8{ 0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef },
    [16]u8{ 0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61 },
    [16]u8{ 0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d },
};

pub fn aes128(data: [4][4]u8, encryptionKey: [16]u8) ![4][4]u8 {
    var result = data;
    const allocator = std.heap.page_allocator;

    var expandedKey = try allocator.alloc(u8, 176);
    for (0..16) |i| {
        expandedKey[i] = encryptionKey[i];
    }
    common.keyExpansion(&expandedKey);
    var keyIndex: u16 = 176;
    var keyBlock = common.makeKeyBlocks(expandedKey[keyIndex - 16 .. keyIndex]);
    keyIndex -= 16;

    addKey(&result, &keyBlock);
    rowShiftInv(&result);
    substitutionInv(&result);

    for (0..9) |_| {
        keyBlock = common.makeKeyBlocks(expandedKey[keyIndex - 16 .. keyIndex]);
        keyIndex -= 16;

        addKey(&result, &keyBlock);
        result = mixColumsInv(result);
        rowShiftInv(&result);
        substitutionInv(&result);

        // std.debug.print("\n{} round:\n", .{(i + 1)});
        // printArray(&result);
    }

    keyBlock = common.makeKeyBlocks(expandedKey[keyIndex - 16 .. keyIndex]);
    keyIndex -= 16;
    addKey(&result, &keyBlock);
    return result;
}

fn addKey(data: [][4]u8, key: [][4]u8) void {
    for (0..data.len) |i| {
        for (0..data[i].len) |u| {
            data[i][u] = data[i][u] ^ key[i][u];
        }
    }
}

fn substitutionInv(data: [][4]u8) void {
    for (0..data.len) |i| {
        for (0..data.len) |j| {
            const x = data[i][j] / 16;
            const y = data[i][j] % 16;
            data[i][j] = inverseSBox[x][y];
        }
    }
}

fn mixColumsInv(body: [4][4]u8) [4][4]u8 {
    var result = body;
    const gmul = common.gmul;
    for (body, 0..) |_, i| {
        result[0][i] = gmul(body[0][i], 14) ^ gmul(body[1][i], 11) ^ gmul(body[2][i], 13) ^ gmul(body[3][i], 9);
        result[1][i] = gmul(body[0][i], 9) ^ gmul(body[1][i], 14) ^ gmul(body[2][i], 11) ^ gmul(body[3][i], 13);
        result[2][i] = gmul(body[0][i], 13) ^ gmul(body[1][i], 9) ^ gmul(body[2][i], 14) ^ gmul(body[3][i], 11);
        result[3][i] = gmul(body[0][i], 11) ^ gmul(body[1][i], 13) ^ gmul(body[2][i], 9) ^ gmul(body[3][i], 14);
    }

    return result;
}

fn rowShiftInv(data: [][4]u8) void {
    for (1..data.len) |i| {
        for (data[i], 0..data[i].len) |item, j| {
            var pos = j + i;
            if (pos >= data[i].len) {
                pos -= data[i].len;
            }

            data[i][pos] = item;
        }
    }
}
