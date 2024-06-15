const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    var value = Tagged{ .b = 1 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* = 3,
        .c => |*b| b.* = !b.*,
    }

    std.debug.print("{}", .{value.b});
}

const Tag = enum { a, b, c };

const Tagged = union(Tag) { a: u8, b: f32, c: bool };

test "switch on tagged union" {
    var value = Tagged{ .b = 1.5 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*b| b.* = !b.*,
    }
    try expect(value.b == 3);
}

test "overflow" {
    var val: u8 = 255;
    val +%= 1;
    try expect(val == 0);
}
