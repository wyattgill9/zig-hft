const std = @import("std");
const Order = @import("./order.zig").Order;

const Node = struct {
    order: Order,
    prev: ?*Node,
    next: ?*Node,
};

pub const OrderQueue = struct {
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
            // list became empty
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
