const std = @import("std");

const Price = f64;
const Quantity = u64;
const OrderId = u64;
const Timestamp = u64;
const SequenceNumber = u64;

const Side = enum(u8) {
    bid = 0,
    ask = 1,
};

const Color = enum(u8) {
    red, 
    black,
};

const Order = struct {
    order_id: OrderId,
    price: Price,
    quantity: Quantity,
    side: Side,
    timestamp: Timestamp,
    next_order: ?*Order,
    prev_order: ?*Order,

    fn init(order_id: OrderId, price: Price, quantity: Quantity, side: Side, timestamp: Timestamp) Order {
        return Order{
            .order_id = order_id,
            .price = price,
            .quantity = quantity,
            .side = side,
            .timestamp = timestamp,
            .next_order = null,
            .prev_order = null,
        };
    }
};

const PriceLevel = struct {
    price: Price,
    total_quantity: Quantity,
    order_count: u32,
    first_order: ?*Order,
    last_order: ?*Order,
    parent: ?*PriceLevel,
    left: ?*PriceLevel,
    right: ?*PriceLevel,
    color: Color,

    fn init(price: Price) PriceLevel {
        return PriceLevel{
            .price = price,
            .total_quantity = 0,
            .order_count = 0,
            .first_order = null,
            .last_order = null,
            .parent = null,
            .left = null,
            .right = null,
            .color = .red,
        };
    }
};

const Book = struct {
    symbol: [8]u8,
    bid_tree: ?*PriceLevel,
    ask_tree: ?*PriceLevel,
    bid_top: ?*PriceLevel,
    ask_top: ?*PriceLevel,
    last_trade_price: Price,
    sequence_number: SequenceNumber,
    order_map: std.HashMap(OrderId, *Order, std.hash_map.DefaultContext(OrderId), std.hash_map.default_max_load_percentage),

    fn init(allocator: std.mem.Allocator, symbol: []const u8) Book {
        return Book {
            .symbol = symbol, 
            .bid_tree = null,
            .ask_tree = null,
            .bid_top = null,
            .ask_top = null,
            .last_trade_price = 0,
            .sequence_number = 0,
            .order_map = std.HashMap(OrderId, *Order, std.hash_map.DefaultContext(OrderId), std.hash_map.default_max_load_percentage).init(allocator),
        };
    }
};
