const std = @import("std");
const debug = std.debug;

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    debug.print("Hello world\n\r", .{});

    const numbers = "0123456789";

    var file = std.fs.cwd().openFile("aoc/day1/Day1.txt", .{}) catch |err| switch (err) {
        error.FileNotFound => {
            debug.print("File failed to opne due to wrong path.\n\r", .{});
            return err;
        },
        else => return err,
    };
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    const reader = bufReader.reader();

    var line = std.ArrayList(u8).init(alloc);
    defer line.deinit();
    const writer = line.writer();

    var line_no: usize = 1;
    var totalNumber: i32 = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) : (line_no += 1) {
        defer line.clearRetainingCapacity();

        const number = [2]u8{ getFirstChar(line, numbers), getLastChar(line, numbers) };
        const integer = try std.fmt.parseInt(i32, &number, 10);
        totalNumber += integer;

        // debug.print("{s}--{d}--{s}\n", .{ number, line_no, line.items });
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => return err, // Propagate error
    }

    debug.print("Result {}", .{totalNumber});
}

fn getFirstChar(array: std.ArrayList(u8), filter: []const u8) u8 {
    for (array.items) |char| {
        for (filter) |filt| {
            if (char == filt) {
                return char;
            }
        }
    }
    return 0;
}

fn getLastChar(array: std.ArrayList(u8), filter: []const u8) u8 {
    var length = array.items.len - 1;
    while (length >= 0) : (length -= 1) {
        for (filter) |filt| {
            if (array.items[length] == filt) {
                return array.items[length];
            }
        }
    }
    return 0;
}
