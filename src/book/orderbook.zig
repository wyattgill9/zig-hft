const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const Map = @import("./map.zig").Map;
const OrderQueue = @import("./orderqueue.zig").OrderQueue;
const Order = @import("./order.zig").Order;
const Side = @import("./order.zig").Side;
const print = std.debug.print;

pub const OrderBook = struct {
    allocator: std.mem.Allocator,
    bids: Map(f64, OrderQueue),
    asks: Map(f64, OrderQueue),

    pub fn init(allocator: std.mem.Allocator) OrderBook {
        return OrderBook{
            .allocator = allocator,
            .bids = Map(f64, OrderQueue).init(allocator),
            .asks = Map(f64, OrderQueue).init(allocator),
        };
    }

    pub fn deinit(self: *OrderBook) void {
        var it = self.bids.iterator();
        while (it.next()) |entry| {
            if (self.bids.getPtr(entry.key)) |queue| {
                queue.deinit();
            }
        }
        self.bids.deinit();

        it = self.asks.iterator();
        while (it.next()) |entry| {
            if (self.asks.getPtr(entry.key)) |queue| {
                queue.deinit();
            }
        }
        self.asks.deinit();
    }

    inline fn getBookAndKey(self: *OrderBook, side: Side, price: f32) struct { book: *Map(f64, OrderQueue), key: f64 } {
        return switch (side) {
            .bid => .{ .book = &self.bids, .key = -@as(f64, price) },
            .ask => .{ .book = &self.asks, .key = @as(f64, price) },
        };
    }

    fn cleanupEmptyQueue(book: *Map(f64, OrderQueue), price_key: f64) void {
        if (book.getPtr(price_key)) |queue| {
            if (queue.isEmpty()) {
                queue.deinit();
                _ = book.erase(price_key);
            }
        }
    }   
    
    pub fn addLimitOrder(self: *OrderBook, order: Order) !void {
        const book_info = self.getBookAndKey(order.side, order.price);

        var queue_ptr = book_info.book.getPtr(book_info.key) orelse blk: {
            try book_info.book.insert(book_info.key, OrderQueue.init(self.allocator));
            break :blk book_info.book.getPtr(book_info.key).?;
        };
        
        try queue_ptr.append(order);    
    }
    
    pub fn popFrontAtPrice(self: *OrderBook, price: f32, side: Side) !void {
        const book_info = self.getBookAndKey(side, price);

        var queue = book_info.book.getPtr(book_info.key) orelse return error.NotFound;
        if (queue.popFront() == null) return error.NotFound;

        cleanupEmptyQueue(book_info.book, book_info.key);
    }

    pub fn getBestBidOrder(self: *OrderBook) ?*Order {
        var it = self.bids.iterator();
        if (it.next()) |entry| {
            return entry.value.peekFront();
        }
        return null;
    }

    pub fn getBestAskOrder(self: *OrderBook) ?*Order {
        var it = self.asks.iterator();
        if (it.next()) |entry| {
            return entry.value.peekFront();
        }
        return null;
    }

    pub fn getBestBidPrice(self: *OrderBook) ?f32 {
        return if (self.getBestBidOrder()) |order| order.price else null;
    }

    pub fn getBestAskPrice(self: *OrderBook) ?f32 {
        return if (self.getBestAskOrder()) |order| order.price else null;
    }

    pub fn printInfo(self: *OrderBook) void {
        print("OrderBook Info:\n", .{});

        print("Bids:\n", .{});
        var bid_it = self.bids.iterator();
        while (bid_it.next()) |entry| {
            const price: f64 = -entry.key;
            print("  Price: {d:.2}\n", .{price});
            var node = entry.value.head;
            while (node) |n| {
                const o = n.order;
                print("    OrderId: {}, Qty: {d}, Side: {s}\n", .{
                    o.order_id, o.remaining_quantity, @tagName(o.side),
                });
                node = n.next;
            }
        }

        print("Asks:\n", .{});
        var ask_it = self.asks.iterator();
        while (ask_it.next()) |entry| {
            const price: f64 = entry.key;
            print("  Price: {d:.2}\n", .{price});
            var node = entry.value.head;
            while (node) |n| {
                const o = n.order;
                print("    OrderId: {}, Qty: {d}, Side: {s}\n", .{
                    o.order_id, o.remaining_quantity, @tagName(o.side),
                });
                node = n.next;
            }
        }
    }
};
