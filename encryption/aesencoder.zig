const std = @import("std");
const common = @import("common.zig");

pub fn aes128(data: [4][4]u8, encryptionKey: [16]u8) ![4][4]u8 {
    var result = data;

    const alloc = std.heap.page_allocator;
    const expandedKey = try alloc.alloc(u8, 176);
    defer alloc.free(expandedKey);

    for (0..16) |i| {
        expandedKey[i] = encryptionKey[i];
    }
    common.keyExpansion(&expandedKey);
    var keyIndex: u16 = 0;
    var key = common.makeKeyBlocks(expandedKey[keyIndex .. keyIndex + 16]);
    keyIndex += 16;
    addKey(&result, &key);

    for (0..9) |_| {
        substitution(&result);
        rowShift(&result);
        result = mixColums(result);

        key = common.makeKeyBlocks(expandedKey[keyIndex .. keyIndex + 16]);
        keyIndex += 16;
        addKey(&result, &key);
    }

    substitution(&result);
    rowShift(&result);

    key = common.makeKeyBlocks(expandedKey[keyIndex .. keyIndex + 16]);
    addKey(&result, &key);

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
            array[row][column] = common.sBox[x][y];
        }
    }
}

fn rowShift(body: [][4]u8) void {
    var i: u8 = 1;
    while (i < body.len) : (i += 1) {
        for (body[i], 0..) |item, index| {
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
    const gmul = common.gmul;
    for (body, 0..) |_, i| {
        result[0][i] = gmul(body[0][i], 2) ^ gmul(body[1][i], 3) ^ body[2][i] ^ body[3][i];
        result[1][i] = body[0][i] ^ gmul(result[1][i], 2) ^ gmul(result[2][i], 3) ^ body[3][i];
        result[2][i] = body[0][i] ^ body[1][i] ^ gmul(body[2][i], 2) ^ gmul(body[3][i], 3);
        result[3][i] = gmul(body[0][i], 3) ^ body[1][i] ^ body[2][i] ^ gmul(body[3][i], 2);
    }
    return result;
}
