const std = @import("std");

pub const Side = enum(u8) {
    bid = 0,
    ask = 1,
};

pub const Order = struct {
    order_id: u64,
    price: f32,
    original_quantity: u32,
    remaining_quantity: u32,
    side: Side,
    timestamp: u64,
    attribution: ?[4]u8, // null if AddOrderNoMPID

    pub fn init(order_id: u64, price: f32, quantity: u32, side: Side, timestamp: u64, attribution: ?[4]u8) Order {
        return Order{
            .order_id = order_id,
            .price = price,
            .original_quantity = quantity,
            .remaining_quantity = quantity, 
            .side = side,
            .timestamp = timestamp,
            .attribution = attribution,
        };
    }
};
