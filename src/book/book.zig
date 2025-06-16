const std = @import("std");
const Map = @import("./map.zig").Map;

const Side = enum(u8) {
    bid = 0,
    ask = 1,
};

pub const Order = struct {
    order_id: u64, 
    price: f64, 
    quantity: u32, 
    side: Side, 
    timestamp: u64,    

    pub fn init(order_id: u64, price: f64, quantity: u32, side: Side, timestamp: u64) Order {
        return Order {
            .order_id = order_id,
            .price = price,
            .quantity = quantity,
            .side = side,
            .timestamp = timestamp,
        };
    }
};

const Node = struct {
    order: Order,
    prev: ?*Node,
    next: ?*Node,
};

const OrderQueue = struct {
    allocator: std.mem.Allocator,
    head: ?*Node = null,
    tail: ?*Node = null,
    order_map: std.AutoHashMap(u64, *Node),

    pub fn init(allocator: std.mem.Allocator) OrderQueue {
        return OrderQueue {
            .allocator = allocator,
            .order_map = std.AutoHashMap(u64, *Node).init(allocator),
        };
    }

    pub fn deinit(self: *OrderQueue) void {
        var node = self.head;
        while (node) |n| {
            const next = n.next;
            self.allocator.destroy(n);
            node = next;
        }
        self.order_map.deinit();
        self.head = null;
        self.tail = null;
    }

    pub fn append(self: *OrderQueue, order: Order) !void {
        const node = try self.allocator.create(Node);
        node.* = Node{
            .order = order,
            .prev = self.tail,
            .next = null,
        };

        if (self.tail) |tail| {
            tail.next = node;
        } else {
            // List was empty
            self.head = node;
        }
        self.tail = node;

        try self.order_map.put(order.order_id, node);
    }

    pub fn popFront(self: *OrderQueue) ?Order {
        if (self.head == null) return null;

        const node = self.head.?;
        const order = node.order;
        self.head = node.next;
        if (self.head) |h| {
            h.prev = null;
        } else {
            // List became empty
            self.tail = null;
        }
        _ = self.order_map.remove(order.order_id);
        self.allocator.destroy(node);
        return order;
    }

    pub fn removeById(self: *OrderQueue, order_id: u64) !bool {
        if (!self.order_map.contains(order_id)) return false;
        const node = self.order_map.get(order_id).?;

        if (node.prev) |prev| {
            prev.next = node.next;
        } else {
            self.head = node.next;
        }
        if (node.next) |next| {
            next.prev = node.prev;
        } else {
            self.tail = node.prev;
        }
        _ = self.order_map.remove(order_id);
        self.allocator.destroy(node);
        return true;
    }

};

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
            var it = self.bids.mutIterator();
            while (it.next()) |entry| {
                entry.value.*.deinit();
                self.allocator.destroy(entry.value);
            }
        }
        self.bids.deinit();

        {
            var it = self.asks.mutIterator();
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
        if (queue_ptr.head == null) {
            _ = book.erase(price);
            queue_ptr.deinit();
            self.allocator.destroy(queue_ptr); 
        }
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
