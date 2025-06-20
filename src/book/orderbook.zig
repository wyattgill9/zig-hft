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
        // clean bids
        var it = self.bids.iterator();
        while (it.next()) |entry| {
            entry.value.*.deinit();
            self.allocator.destroy(entry.value);
        }
        self.bids.deinit();

        // clean asks
        it = self.asks.iterator();
        while (it.next()) |entry| {
            entry.value.*.deinit();
            self.allocator.destroy(entry.value);
        }
        self.asks.deinit();

        // Free heap orders
        var order_it = self.order_id_map.iterator();
        while (order_it.next()) |entry| {
            self.allocator.destroy(entry.value_ptr.*);
        }
        self.order_id_map.deinit();
    }

    inline fn getBookAndKey(self: *OrderBook, side: Side, price: f32) struct { book: *Map(f64, *OrderQueue), key: f64 } {
        return switch (side) {
            .bid => .{ .book = &self.bids, .key = -@as(f64, price) },
            .ask => .{ .book = &self.asks, .key = @as(f64, price) },
        };
    }

    // clean empty
    fn cleanupEmptyQueue(self: *OrderBook, book: *Map(f64, *OrderQueue), price_key: f64) void {
        if (book.get(price_key)) |queue_ptr| {
            if (queue_ptr.head == null) {
                queue_ptr.deinit();
                self.allocator.destroy(queue_ptr);
                _ = book.erase(price_key);
            }
        }
    }

    pub fn addLimitOrder(self: *OrderBook, order: Order) !void {
        const order_ptr = try self.allocator.create(Order);
        order_ptr.* = order;

        const book_info = self.getBookAndKey(order.side, order.price);
        
        const queue_ptr = book_info.book.get(book_info.key) orelse blk: {
            const new_queue = try self.allocator.create(OrderQueue);
            new_queue.* = OrderQueue.init(self.allocator);
            try book_info.book.insert(book_info.key, new_queue);
            break :blk new_queue;
        };

        try queue_ptr.append(order_ptr);
        try self.order_id_map.put(order.order_id, order_ptr);
    }

    pub fn popFrontAtPrice(self: *OrderBook, price: f32, side: Side) !void {
        const book_info = self.getBookAndKey(side, price);

        const queue_ptr = book_info.book.get(book_info.key) orelse return error.NotFound;
        const order_ptr = queue_ptr.popFront() orelse return error.NotFound;

        _ = self.order_id_map.remove(order_ptr.order_id);
        // const order_val = order_ptr.*;
        self.allocator.destroy(order_ptr);

        self.cleanupEmptyQueue(book_info.book, book_info.key);

        // return order_val;
    }
    
    pub fn getOrderById(self: *OrderBook, order_id: u64) ?*Order {
        return self.order_id_map.get(order_id);
    }

    pub fn removeOrderById(self: *OrderBook, order_id: u64) !void {
        const order_ptr = self.order_id_map.get(order_id) orelse return error.OrderNotFound;
        const order = order_ptr.*;
        
        const book_info = self.getBookAndKey(order.side, order.price);
        const queue_ptr = book_info.book.get(book_info.key) orelse return error.OrderNotFound;
        
        var node = queue_ptr.head;
        while (node) |n| {
            if (n.order == order_ptr) {
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
        
        self.cleanupEmptyQueue(book_info.book, book_info.key);
    }

    pub fn replaceOrderById(self: *OrderBook, new_order: Order, original_order_id: u64) !void {
        try self.removeOrderById(original_order_id);
        try self.addLimitOrder(new_order);
    }

    pub fn executeOrder(self: *OrderBook, order_id: u64, execute_shares: u32) !void {
        const order_ptr = self.getOrderById(order_id) orelse return error.OrderNotFound;
        order_ptr.remaining_quantity -= execute_shares;
        
        if (order_ptr.remaining_quantity <= 0) {
            try self.removeOrderById(order_id);
        }
    }

    pub fn cancelOrderPartial(self: *OrderBook, order_id: u64, cancel_shares: u32) !void {
        const order_ptr = self.getOrderById(order_id) orelse return error.OrderNotFound;
        order_ptr.remaining_quantity -= cancel_shares;
        
        if (order_ptr.remaining_quantity <= 0) {
            try self.removeOrderById(order_id);
        }
    }

    pub fn getBestBidOrder(self: *OrderBook) ?*Order {
        var it = self.bids.iterator();
        if (it.next()) |entry| {
            if (entry.value.head) |node| {
                return node.order;
            }
        }
        return null;
    }

    pub fn getBestAskOrder(self: *OrderBook) ?*Order {
        var it = self.asks.iterator();
        if (it.next()) |entry| {
            if (entry.value.head) |node| {
                return node.order;
            }
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
        
        print("OrderIdMap contains {d} orders\n", .{self.order_id_map.count()});
    }
};
