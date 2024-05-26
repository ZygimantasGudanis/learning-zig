const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var array = [_]i8{ 2, 5, 9, 1, 7, 3, 4, 8 };
    quicksort(&array, 0, array.len - 1);

    std.debug.print("Sorted array: {any}\n", .{array});
}

pub fn quicksort(array: []i8, low: u32, high: u32) void {
    if (low >= high or low < 0) {
        return;
    }
    const point = partition(array, low, high);
    if (point != 0) {
        quicksort(array, low, point - 1);
    }
    quicksort(array, point + 1, high);
}

pub fn partition(array: []i8, low: u32, high: u32) u32 {
    const pivot = array[high];
    var i: u32 = low;
    // std.debug.print("Low {}, High {}\n", .{ low, high });
    for (low..high) |j| {
        if (array[j] <= pivot) {
            // std.debug.print("Index {}, Array {any}, Pivot {}\n", .{ j, array[j], pivot });
            const temp = array[i];
            array[i] = array[j];
            array[j] = temp;
            i = i + 1;
        }
    }

    array[high] = array[i];
    array[i] = pivot;
    // std.debug.print("{} Sorted array: {any}\n", .{ i, array });
    return i;
}
