const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const Map = @import("./map.zig").Map;
const OrderQueue = @import("./orderqueue.zig").OrderQueue;
const Order = @import("./order.zig").Order;
const Side = @import("./order.zig").Side;
const print = std.debug.print;

pub const OrderBook = struct {
    allocator: std.mem.Allocator,
    bids: Map(f64, *OrderQueue),
    asks: Map(f64, *OrderQueue),
    order_id_map: AutoHashMap(u64, *Order),

    pub fn init(allocator: std.mem.Allocator) OrderBook {
        return OrderBook{
            .allocator = allocator,
            .bids = Map(f64, *OrderQueue).init(allocator),
            .asks = Map(f64, *OrderQueue).init(allocator),
            .order_id_map = AutoHashMap(u64, *Order).init(allocator),
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

        // free heap orders
        var order_it = self.order_id_map.iterator();
        while (order_it.next()) |entry| {
            self.allocator.destroy(entry.value_ptr.*);
        }
        self.order_id_map.deinit();
    }

    pub fn addLimitOrder(self: *OrderBook, order: Order) !void {
        const order_ptr = try self.allocator.create(Order);
        order_ptr.* = order;

        const price_key = switch (order.side) {
            .bid => -@as(f64, order.price),
            .ask => @as(f64, order.price),
        };
        const book = switch (order.side) {
            .bid => &self.bids,
            .ask => &self.asks,
        };

        var queue_ptr: *OrderQueue = undefined;
        if (book.contains(price_key)) {
            queue_ptr = book.get(price_key) orelse unreachable;
        } else {
            queue_ptr = try self.allocator.create(OrderQueue);
            queue_ptr.* = OrderQueue.init(self.allocator);
            try book.insert(price_key, queue_ptr);
        }

        try queue_ptr.append(order_ptr);

        try self.order_id_map.put(order.order_id, order_ptr);
    }

    pub fn popFrontAtPrice(self: *OrderBook, price: f32, side: Side) ?Order {
        const price_key = switch (side) {
            .bid => -@as(f64, price),
            .ask => @as(f64, price),
        };
        const book = switch (side) {
            .bid => &self.bids,
            .ask => &self.asks,
        };

        if (!book.contains(price_key)) return null;
        var queue_ptr = book.get(price_key) orelse return null;
        const order_ptr = queue_ptr.popFront() orelse return null;
        self.order_id_map.remove(order_ptr.order_id);
        const order_val = order_ptr.*;
        self.allocator.destroy(order_ptr);
        return order_val;
    }

    pub fn getOrderById(self: *OrderBook, order_id: u64) ?Order {
        const maybe_ptr = self.order_id_map.get(order_id);
        if (maybe_ptr) |order_ptr| {
            return order_ptr.*;
        }
        return null;
    }

    pub fn removeOrderById(self: *OrderBook, order_id: u64) !void {
        const maybe_ptr = self.order_id_map.get(order_id);
        if (maybe_ptr) |order_ptr| {
            const order = order_ptr.*;
            const price_key = switch (order.side) {
                .bid => -@as(f64, order.price),
                .ask => @as(f64, order.price),
            };
            const book = switch (order.side) {
                .bid => &self.bids,
                .ask => &self.asks,
            };
            const queue_ptr = book.get(price_key) orelse return error.OrderNotFound;
            var node = queue_ptr.head;
            while (node) |n| {
                if (n.order == order_ptr) {
                    // Unlink from list
                    if (n.prev) |prev| {
                        prev.next = n.next;
                    } else {
                        queue_ptr.head = n.next;
                    }
                    if (n.next) |next| {
                        next.prev = n.prev;
                    } else {
                        queue_ptr.tail = n.prev;
                    }
                    self.allocator.destroy(n);
                    break;
                }
                node = n.next;
            }
            _ = self.order_id_map.remove(order_id);
            self.allocator.destroy(order_ptr);
            return;
        }
        return error.OrderNotFound;
    }

    pub fn replaceOrderById(self: *OrderBook, new_order: Order, original_order_id: u64) !void {
        try self.removeOrderById(original_order_id);
        try self.addLimitOrder(new_order);
    }

    pub fn getBestBidOrder(self: *OrderBook) ?Order {
        var it = self.bids.iterator();
        if (it.next()) |entry| {
            if (entry.value.head) |node| {
                return node.order.*;
            }
        }
        return null;
    }

    pub fn getBestAskOrder(self: *OrderBook) ?Order {
        var it = self.asks.iterator();
        if (it.next()) |entry| {
            if (entry.value.head) |node| {
                return node.order.*;
            }
        }
        return null;
    }

    pub fn getBestBidPrice(self: *OrderBook) ?f32 {
        return self.getBestBidOrder().?.price;
    }

    pub fn getBestAskPrice(self: *OrderBook) ?f32 {
        return self.getBestAskOrder().?.price;
    }

    pub fn printInfo(self: *OrderBook) void {
        print("OrderBook Info:\n", .{});
        print("Bids:\n", .{});
        {
            var bid_it = self.bids.iterator();
            while (bid_it.next()) |entry| {
                // For bids, key is negative price!
                const price: f64 = -entry.key;
                print("  Price: {d:.2}\n", .{price});
                const queue = entry.value;
                var node = queue.head;
                while (node) |n| {
                    const o: *Order = n.order;
                    print("    OrderId: {}, Qty: {d}, Side: {s}\n", .{
                        o.order_id, o.quantity, @tagName(o.side),
                    });
                    node = n.next;
                }
            }
        }
        print("Asks:\n", .{});
        {
            var ask_it = self.asks.iterator();
            while (ask_it.next()) |entry| {
                const price: f64 = entry.key;
                print("  Price: {d:.2}\n", .{price});
                const queue = entry.value;
                var node = queue.head;
                while (node) |n| {
                    const o: *Order = n.order;
                    print("    OrderId: {}, Qty: {d}, Side: {s}\n", .{
                        o.order_id, o.quantity, @tagName(o.side),
                    });
                    node = n.next;
                }
            }
        }
        print("OrderIdMap contains {d} orders\n", .{self.order_id_map.count()});
    }
};
