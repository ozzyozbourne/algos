const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const runtime_array = try allocator.alloc(i32, 5);
    defer allocator.free(runtime_array);

    for(runtime_array) |*value| {
        value.* = 0;
    }

    const m = @max(runtime_array[2], 2);

    for (runtime_array) |value| {
        std.debug.print("{d} <-> {d}\n", .{value, m});
    }

}
