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

pub fn aes128(data: [4][4]u8) ![4][4]u8 {
    var result = data;

    const alloc = std.heap.page_allocator;
    const expandedKey = try alloc.alloc(u8, 176);
    defer alloc.free(expandedKey);

    for (0..16) |i| {
        expandedKey[i] = 0;
    }
    keyExpansion(&expandedKey);
    var keyIndex: u16 = 0;
    var key = makeBlocks(expandedKey[keyIndex .. keyIndex + 16]);
    keyIndex += 16;
    addKey(&result, &key);

    for (0..9) |_| {
        // std.debug.print("\n{} round:\n", .{(i + 1)});
        // printArray(&result);

        substitution(&result);
        rowShift(&result);
        result = mixColums(result);

        key = makeBlocks(expandedKey[keyIndex .. keyIndex + 16]);
        keyIndex += 16;
        addKey(&result, &key);
    }

    substitution(&result);
    rowShift(&result);

    key = makeBlocks(expandedKey[keyIndex .. keyIndex + 16]);
    addKey(&result, &key);

    return result;
}

// fn aes128Encoder(data: []u8, encryptionKey: []u8) void {}

fn makeBlocks(array: []u8) [4][4]u8 {
    var result: [4][4]u8 = std.mem.zeroes([4][4]u8);
    for (array, 0..) |item, i| {
        result[i % 4][i / 4] = item;
    }
    return result;
}

fn addKey(data: [][4]u8, key: [][4]u8) void {
    for (0..data.len) |i| {
        for (0..data[i].len) |u| {
            data[i][u] = data[i][u] ^ key[i][u];
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

fn rcon(value: u8) u8 {
    var c: u8 = 1;
    var temp = value;

    if (temp == 0) {
        return 0;
    }

    while (temp != 1) {
        c = gmul(c, 2);
        temp -= 1;
    }
    return c;
}

fn rotate(val: *[4]u8) void {
    const a = val.*[0];
    for (0..val.*.len - 1) |i| {
        val.*[i] = val.*[i + 1];
    }
    val.*[3] = a;
}

fn schedule_core(in: *[4]u8, val: u8) void {
    rotate(in);

    for (0..4) |i| {
        const x = in[i] / 16;
        const y = in[i] % 16;
        in[i] = sBox[x][y];
    }
    in.*[0] ^= rcon(val);
}

fn keyExpansion(key: *const []u8) void {
    var c: u8 = 16;
    var t: [4]u8 = [4]u8{ 0, 0, 0, 0 };
    var i: u8 = 1;
    while (c < 176) {
        for (0..4) |a| {
            t[a] = key.*[a + c - 4];
        }
        if (c % 16 == 0) {
            schedule_core(&t, i);
            i += 1;
        }
        for (0..4) |a| {
            key.*[c] = key.*[c - 16] ^ t[a];
            c += 1;
        }
    }
}
