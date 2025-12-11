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
        //get an iterator over the utf8 chars in the string
        var utf8s = (try std.unicode.Utf8View.init(arg)).iterator();

        std.debug.print("arg? {s}\n", .{arg});

        var sign: i8 = undefined;
        var val: i8 = undefined;
        var j: usize = 0;
        var parsed = true;
        // first char: "L"/"R" for int sign
        // second char: initial int value
        // nth char: shift current val up one digit and new val
        while (utf8s.nextCodepointSlice()) |a| {
            if (j == 0) {
                if (std.mem.eql(u8, a, "L")) {
                    sign = -1;
                } else if (std.mem.eql(u8, a, "R")) {
                    sign = 1;
                } else {
                    // skip this arg if sign is not first char
                    std.debug.print("char not valid sign. char: {s}\n", .{a});
                    parsed = false;
                    break;
                }
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
        // skip this arg if it we could not parse it
        if (!parsed) {
            std.debug.print("couldn't parse. skipping arg: {s}\n", .{arg});
            continue;
        }
        vals[i] = sign * val;
        i += 1;
    }
    return vals[0..];
}
