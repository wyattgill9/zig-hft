const std = @import("std");

pub const ITCHMessage = packed struct {
    message_type: c_char,
    timestamp: u64,
    order_reference_num: u32,
    transaction_id: u32,
    order_book_id: u32,
    side: c_char,
    quantity: u32, // fractional quantity
    price: f64,
    yield: f32,
};

pub fn parse(message: []const u8) ITCHMessage {
    // std.debug.assert(message.len >= @sizeOf(ITCHMessage));
    return std.mem.bytesToValue(ITCHMessage, message);
}
