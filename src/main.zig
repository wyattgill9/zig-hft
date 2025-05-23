const std = @import("std");

pub fn main() void {
    std.io.getStdOut().writer().print("Hello, world!\n", .{}) catch {};
}
