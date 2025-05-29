const std = @import("std");

const MyStruct = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    stock: [8]u8,
    trading_state: u8,
    reserved: u8,
    reason: [4]u8,
};

pub fn main() void {
    std.debug.print("sizeOf: {d}\n", .{@sizeOf(MyStruct)});
    std.debug.print("alignOf: {d}\n", .{@alignOf(MyStruct)});
}
