const std = @import("std");
const test_alloc = std.testing;

pub const TestCase = struct {
    input: *const []const u32,
    expected: *const []const u32,
};

pub fn counting_sort(input: *const []const u32, arena_alloc:std.mem.Allocator ) !*const []const u32 {
    var m:u32 = 0;
    for (input.*) |value| { m = @max(value, m); }

    const counts = try arena_alloc.alloc(u32, m + 1);
    @memset(counts, 0);

    for(input.*) |value| { counts[value] += 1; }
    for(1..counts.len) |i|{ counts[i] += counts[i - 1]; }

    const output = try arena_alloc.alloc(u32, input.len);

    var it = std.mem.reverseIterator(input.*);
    while(it.next()) |value|{
        output[@intCast(counts[value] - 1)] = value;
        counts[value] -= 1;
    }

    return &output;
}

test "testing counting sort inplemtation" {
    var arena_alloc = std.heap.ArenaAllocator.init(test_alloc.allocator);
    defer arena_alloc.deinit();
    
    // Test case 1: Regular case with duplicates
    const test1_input = [_]u32{ 4, 3, 12, 1, 5, 5, 3, 9 };
    const test1_expected = [_]u32{ 1, 3, 3, 4, 5, 5, 9, 12 };

    // Test case 2: Already sorted case
    const test2_input = [_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const test2_expected = [_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 };

    // Test case 3: Reverse sorted case with multiple duplicates
    const test3_input = [_]u32{ 9, 9, 8, 7, 7, 5, 3, 1 };
    const test3_expected = [_]u32{ 1, 3, 5, 7, 7, 8, 9, 9 };   
    
    const tests = [_]TestCase{
        .{ .input = &test1_input[0..test1_input.len],
           .expected = &test1_expected[0..test1_expected.len],
         },
        .{ .input = &test2_input[0..test2_input.len],
           .expected = &test2_expected[0..test2_expected.len],
         },
        .{ .input = &test3_input[0..test3_input.len],
           .expected = &test3_expected[0..test3_expected.len],
         },
    };
    
    for(tests, 1..) |t, i| {
        std.debug.print("Starting Test No -> {d}\n", .{i});
        const res = try counting_sort(t.input, arena_alloc.allocator());

        for(res.*, t.expected.*) |act, exp| { try std.testing.expect(act == exp); }
        std.debug.print("Finished Test No -> {d}\n", .{i});
    }
}
