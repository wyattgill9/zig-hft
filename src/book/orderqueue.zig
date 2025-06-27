const std = @import("std");
const Order = @import("./order.zig").Order;

pub const OrderQueue = struct {
    const Node = struct {
        order: *Order,
        prev: ?*Node,
        next: ?*Node,
    };

    allocator: std.mem.Allocator,
    head: ?*Node = null,
    tail: ?*Node = null,

    pub fn init(allocator: std.mem.Allocator) OrderQueue {
        return OrderQueue{ .allocator = allocator };
    }

    pub fn deinit(self: *OrderQueue) void {
        var node = self.head;
        while (node) |n| {
            const next = n.next;
            self.allocator.destroy(n.order);
            self.allocator.destroy(n);
            node = next;
        }
        self.head = null;
        self.tail = null;
    }

    pub fn append(self: *OrderQueue, order: Order) !void {
        const order_ptr = try self.allocator.create(Order);
        order_ptr.* = order;
        const node = try self.allocator.create(Node);
        
        node.* = Node{
            .order = order_ptr,
            .prev = self.tail,
            .next = null,
        };
        if (self.tail) |tail| {
            tail.next = node;
        } else {
            self.head = node;
        }
        self.tail = node;
    }

    pub fn popFront(self: *OrderQueue) ?Order {
        if (self.head == null) return null;
        const node = self.head.?;
        const order_val = node.order.*;
        self.head = node.next;
        if (self.head) |h| {
            h.prev = null;
        } else {
            self.tail = null;
        }
        self.allocator.destroy(node.order);
        self.allocator.destroy(node);
        return order_val;
    }

    pub fn isEmpty(self: *OrderQueue) bool {
        return self.head == null;
    }

    pub fn peekFront(self: *OrderQueue) ?*Order {
        return if (self.head) |n| n.order else null;
    }
};
