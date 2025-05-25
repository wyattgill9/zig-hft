const std = @import("std");
const tsc = @import("tsc/mod.zig");
const parse = @import("parser/mod.zig");

pub fn make_itch_message() !parse.itch.ITCHMessage {
    const data: [38]u8 = [_]u8{
        0x41, // message_type (c_char)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // timestamp (u64)
        0x00, 0x00, 0x03, 0xea, // order_reference_num (u32)
        0x00, 0x00, 0x00, 0x05, // transaction_id (u32)
        0x00, 0xcd, 0x42, 0x00, // order_book_id (u32)
        0x00, // side (c_char)
        0x01, 0x00, 0x00, 0x00, // quantity (u32)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x3f, // price (f64)
        0x00, 0x00, 0x00, 0x01, // yield (f32)
    };

    return parse.itch.parse(&data);
}

pub fn main() !void {
    const start = tsc.now();

    const message = try make_itch_message();
    std.debug.print("message = {}\n", .{message}); 

    const end = tsc.now();
    std.debug.print("cycles = {}\n", .{tsc.delta(start, end)});
}
