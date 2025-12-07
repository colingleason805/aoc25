//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn readIn() ![*]i8 {
    const allocator = std.heap.page_allocator;
    var argsIterator = try std.process.ArgIterator.initWithAllocator(allocator);
    defer argsIterator.deinit();

    _ = argsIterator.next(); // Skip the executable name

    var vals = [_]i8{0} ** 1024;
    var i: usize = 0;
    while (argsIterator.next()) |arg| {
        //get an iterator over the
        var utf8s = (try std.unicode.Utf8View.init(arg)).iterator();

        std.debug.print("arg? {s}\n", .{arg});

        var sign: i8 = undefined;
        var val: i8 = undefined;
        var j: usize = 0;

        // first char: "L"/"R" for int sign
        // second char: initial int value
        // nth char: shift current val up one digit and new val
        while (utf8s.nextCodepointSlice()) |a| {
            if (j == 0) {
                sign = if (std.mem.eql(u8, a, "L")) -1 else 1;
                std.debug.print("sign: {}\n", .{sign});
            } else if (j == 1) {
                val = try std.fmt.parseInt(i8, a, 10);
                std.debug.print("val: {}\n", .{val});
            } else {
                val = val * 10 + try std.fmt.parseInt(i8, a, 10);
                std.debug.print("val: {}\n", .{val});
            }
            j += 1;
        }
        vals[i] = sign * val;
        i += 1;
    }
    return vals[0..];
}
