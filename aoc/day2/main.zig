const std = @import("std");

pub fn main() !void {
    std.debug.print("Day 2\n", .{});
    const alloc = std.heap.page_allocator;

    const file = std.fs.cwd().openFile("aoc/day2/Day2.txt", .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("File failed to opne due to wrong path.\n\r", .{});
            return err;
        },
        else => return err,
    };

    defer file.close();
    var bufReader = std.io.bufferedReader(file.reader());
    const reader = bufReader.reader();

    var line = std.ArrayList(u8).init(alloc);
    const writer = line.writer();
    defer line.deinit();

    var line_no: i16 = 1;

    while (reader.streamUntilDelimiter(writer, '\n', null)) : (line_no += 1) {
        defer line.clearRetainingCapacity();
        std.debug.print("{s}\n", .{line.items});
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => return err, // Propagate error
    }
}
