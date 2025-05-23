const std = @import("std");
const tsc = @import("tsc/mod.zig");

pub fn main() !void {
    const start = tsc.now();
    // do smt
    const end = tsc.now();
    std.debug.print("Cycle delta = {}\n", .{tsc.delta(start, end)});
}

