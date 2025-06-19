const std = @import("std");
const Map = @import("./map.zig").Map;
const OrderQueue = @import("./orderqueue.zig").OrderQueue;
const Order = @import("order.zig").Order;
const Side = @import("order.zig").Side;

pub const OrderBook = struct {
    allocator: std.mem.Allocator,
    bids: Map(f64, *OrderQueue),  // TODO: make descending price
    asks: Map(f64, *OrderQueue),  // ascending price

    pub fn init(allocator: std.mem.Allocator) OrderBook {
        return OrderBook{
            .allocator = allocator,
            .bids = Map(f64, *OrderQueue).init(allocator),
            .asks = Map(f64, *OrderQueue).init(allocator),
        };
    }

    pub fn deinit(self: *OrderBook) void {
        {
            var it = self.bids.iterator();
            while (it.next()) |entry| {
                entry.value.*.deinit();
                self.allocator.destroy(entry.value); 
            }
        }
        self.bids.deinit();

        {
            var it = self.asks.iterator();
            while (it.next()) |entry| {
                entry.value.*.deinit();
                self.allocator.destroy(entry.value);
            }
        }
        self.asks.deinit();
    }


    pub fn addLimitOrder(self: *OrderBook, order: Order) !void {
        const book = switch (order.side) {
            .bid => &self.bids,
            .ask => &self.asks,
        };

        if (book.contains(order.price)) {
            var queue_ptr = book.get(order.price) orelse unreachable;
            try queue_ptr.append(order);
        } else {
            var new_queue = try self.allocator.create(OrderQueue);
            new_queue.* = OrderQueue.init(self.allocator); // same allocator in each queue
            try new_queue.append(order);
            try book.insert(order.price, new_queue);
        }
    }

    pub fn popFrontAtPrice(self: *OrderBook, price: f64, side: Side) ?Order {
        const book = switch (side) {
            .bid => &self.bids,
            .ask => &self.asks,
        };

        if (!book.contains(price)) {
            return null;
        }
        var queue_ptr = book.get(price) orelse return null; 
        const result = queue_ptr.popFront();

        return result;
    }

    pub fn removeOrderById(self: *OrderBook, order_id: u64, price: f64, side: Side) !bool {
        const book = switch (side) {
            .bid => &self.bids,
            .ask => &self.asks,
        };
        if (!book.contains(price)) return false;
        var queue_ptr = book.get(price) catch return false;
        return try queue_ptr.removeById(order_id);
    }
};
