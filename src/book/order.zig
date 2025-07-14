const std = @import("std");

// const OrderType = union(enum) {
    // LimitOrder: LimitOrder 

// };

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
    
    pub fn printInfo(self: *Order) void {
        std.debug.print("Order {{\n", .{});
        std.debug.print("  order_id = {}\n", .{self.order_id});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("  original_quantity = {}\n", .{self.original_quantity});
        std.debug.print("  remaining_quantity = {}\n", .{self.remaining_quantity});
        std.debug.print("  side = {s}\n", .{switch (self.side) {
            .bid => "bid",
            .ask => "ask",
        }});
        std.debug.print("  timestamp = {}\n", .{self.timestamp});
        if (self.attribution) |attr| {
            std.debug.print("  attribution = '{c}{c}{c}{c}'\n", .{
                attr[0], attr[1], attr[2], attr[3],
            });
        } else {
            std.debug.print("  attribution = null\n", .{});
        }
        std.debug.print("}}\n\n", .{});
    }
};
