const std = @import("std");

/// Generic doubly linked list
pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            prev: ?*Node = null,
            next: ?*Node = null,
        };

        allocator: std.mem.Allocator,
        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self { 
                .allocator = allocator, 
                .len = 0 
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
        }

        pub fn clear(self: *Self) void {
            var node = self.head;
            while (node) |n| {
                const next = n.next;
                self.allocator.destroy(n);
                node = next;
            }
            self.head = null;
            self.tail = null;
            self.len = 0;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.len == 0;
        }

        pub fn append(self: *Self, value: T) !*Node {
            const node = try self.allocator.create(Node);
            node.* = Node{
                .value = value,
                .prev = self.tail,
                .next = null,
            };
            if (self.tail) |tail| {
                tail.next = node;
            } else {
                self.head = node;
            }
            self.tail = node;
            self.len += 1;
            return node;
        }

        /// Prepend value to the head
        pub fn prepend(self: *Self, value: T) !*Node {
            const node = try self.allocator.create(Node);
            node.* = Node{
                .value = value,
                .prev = null,
                .next = self.head,
            };
            if (self.head) |head| {
                head.prev = node;
            } else {
                self.tail = node;
            }
            self.head = node;
            self.len += 1;
            return node;
        }

        /// Pop value from front (head)
        pub fn popFront(self: *Self) ?T {
            if (self.head == null) return null;
            const node = self.head.?;
            const value = node.value;
            self.head = node.next;
            if (self.head) |h| {
                h.prev = null;
            } else {
                self.tail = null;
            }
            self.allocator.destroy(node);
            self.len -= 1;
            return value;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.tail == null) return null;
            const node = self.tail.?;
            const value = node.value;
            self.tail = node.prev;
            if (self.tail) |t| {
                t.next = null;
            } else {
                self.head = null;
            }
            self.allocator.destroy(node);
            self.len -= 1;
            return value;
        }

        pub fn peekFront(self: *Self) ?*T {
            return if (self.head) |n| &n.value else null;
        }

        pub fn peekBack(self: *Self) ?*T {
            return if (self.tail) |n| &n.value else null;
        }

        pub fn remove(self: *Self, node: *Node) void {
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
            self.allocator.destroy(node);
            self.len -= 1;
        }

        pub fn insertAfter(self: *Self, node: *Node, value: T) !*Node {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{
                .value = value,
                .prev = node,
                .next = node.next,
            };
            if (node.next) |next| {
                next.prev = new_node;
            } else {
                self.tail = new_node;
            }
            node.next = new_node;
            self.len += 1;
            return new_node;
        }

        pub fn insertBefore(self: *Self, node: *Node, value: T) !*Node {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{
                .value = value,
                .prev = node.prev,
                .next = node,
            };
            if (node.prev) |prev| {
                prev.next = new_node;
            } else {
                self.head = new_node;
            }
            node.prev = new_node;
            self.len += 1;
            return new_node;
        }
        
        // tests every value in the list against the predicate (fn that returns bool)
        pub fn find(self: *Self, pred: fn (value: *T) bool) ?*Node {
            var node = self.head;
            while (node) |n| {
                if (pred(&n.value)) return n;
                node = n.next;
            }
            return null;
        }

        pub fn contains(self: *Self, value: T) bool {
            var node = self.head;
            while (node) |n| {
                if (std.meta.eql(n.value, value)) return true;
                node = n.next;
            }
            return false;
        }

        pub fn iterator(self: *Self) Iterator {
            return Iterator{ .node = self.head };
        }

        pub fn reverseIterator(self: *Self) ReverseIterator {
            return ReverseIterator{ .node = self.tail };
        }

        pub const Iterator = struct {
            node: ?*Node,
            pub fn next(self: *Iterator) ?*T {
                if (self.node) |n| {
                    self.node = n.next;
                    return &n.value;
                }
                return null;
            }
        };

        pub const ReverseIterator = struct {
            node: ?*Node,
            pub fn next(self: *ReverseIterator) ?*T {
                if (self.node) |n| {
                    self.node = n.prev;
                    return &n.value;
                }
                return null;
            }
        };
    };
}
