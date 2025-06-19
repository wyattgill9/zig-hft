const std = @import("std");

pub const Side = enum(u8) {
    bid = 0,
    ask = 1,
};

pub const Order = struct {
    order_id: u64,
    price: f32,
    quantity: u32,
    side: Side,
    timestamp: u64,

    pub fn init(order_id: u64, price: f32, quantity: u32, side: Side, timestamp: u64) Order {
        return Order{
            .order_id = order_id,
            .price = price,
            .quantity = quantity,
            .side = side,
            .timestamp = timestamp,
        };
    }
};
