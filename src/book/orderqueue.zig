const std = @import("std");
const Order = @import("./order.zig").Order;

pub const Node = struct {
    order: *Order, // pointer to heap Order!
    prev: ?*Node,
    next: ?*Node,
};

pub const OrderQueue = struct {
    allocator: std.mem.Allocator,
    head: ?*Node = null,
    tail: ?*Node = null,

    pub fn init(allocator: std.mem.Allocator) OrderQueue {
        return OrderQueue{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *OrderQueue) void {
        var node = self.head;
        while (node) |n| {
            const next = n.next;
            self.allocator.destroy(n);
            node = next;
        }
        self.head = null;
        self.tail = null;
    }

    pub fn append(self: *OrderQueue, order: *Order) !void {
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
    }

    pub fn popFront(self: *OrderQueue) ?*Order {
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
        self.allocator.destroy(node);
        return order;
    }
};
