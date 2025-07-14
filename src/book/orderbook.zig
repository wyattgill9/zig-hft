const std = @import("std");
const print = std.debug.print;
const AutoHashMap = std.AutoHashMap;
const List = @import("./list.zig").List;
const Map = @import("./map.zig").Map;
const Order = @import("./order.zig").Order;
const Side = @import("./order.zig").Side;
const ITCHMessage = @import("../parser/structs.zig").ITCHMessage;

pub const OrderQueue = List(Order);

pub const OrderBook = struct {
    allocator: std.mem.Allocator,
    bids: Map(f64, OrderQueue),
    asks: Map(f64, OrderQueue),
    order_id_map: AutoHashMap(u64, *OrderQueue.Node), 
    debug: bool, 


    pub fn init(allocator: std.mem.Allocator, debug: bool) OrderBook {
        return OrderBook {
            .allocator = allocator,
            .bids = Map(f64, OrderQueue).init(allocator),
            .asks = Map(f64, OrderQueue).init(allocator),
            .order_id_map = AutoHashMap(u64, *OrderQueue.Node).init(allocator), 
            .debug = debug 
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
        self.order_id_map.deinit();
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

    // core logic -- testing for now 
    pub fn editBook(self: *OrderBook, msg: ITCHMessage) !void {
        switch (msg) {
            .AddOrderNoMPIDMessage => |add| {
                if (self.debug) { std.debug.print("Adding order {d} with quantitiy {d} at price {d}\n\n", .{add.order_reference_number, add.shares, add.price}); } 
                const order = Order.init(
                    add.order_reference_number,
                    add.price,
                    add.shares,
                    sideFromIndicator(add.buy_sell_indicator),
                    add.header.timestamp,
                    // add.stock, -- inferred
                    null, // No MPID
                );
                try self.addLimitOrder(order);

                return;
            },
            .AddOrderWithMPIDMessage => |add| {
                if (self.debug) { std.debug.print("Adding order {d} with quantitiy {d} at price {d}\n\n", .{add.order_reference_number, add.shares, add.price}); } 
                const order = Order.init(
                    add.order_reference_number,
                    add.price,
                    add.shares,
                    sideFromIndicator(add.buy_sell_indicator),
                    add.header.timestamp,
                    // add.stock, -- inferred
                    add.attribution,
                );

                try self.addLimitOrder(order);
                return;
            },
            .OrderCancelMessage => |cancel| {
                if (self.debug) { std.debug.print("partialy cancelling order {d} with {d} shares\n", .{cancel.order_reference_number, cancel.cancelled_shares}); } 
                try self.modifyOrder(cancel.order_reference_number, cancel.cancelled_shares);
                return; 
            },
            .OrderDeleteMessage => |del| {
                // Remove the entire order from the book
                if (self.debug) { std.debug.print("Deleting order {d}\n", .{del.order_reference_number}); } 
                try self.removeOrderById(del.order_reference_number);
                return; 
            },
            .OrderReplaceMessage => |rep| {
                // Remove the original order and create a new one but preserve the side, timestamp, and MPID 
                if (self.debug) { std.debug.print("Replacing order {d} with quantitiy {d} at price {d}\n\n", .{rep.original_order_reference_number, rep.shares, rep.price}); } 
                const original_order = self.order_id_map.get(rep.original_order_reference_number) orelse return error.NotFound;
                
                const side = original_order.value.side;
                const timestamp = original_order.value.timestamp;
                const mpid = original_order.value.attribution;
                
                try self.removeOrderById(rep.original_order_reference_number);
                
                const new_order = Order.init(
                    rep.new_order_reference_number,
                    rep.price,
                    rep.shares,
                    side,
                    timestamp, 
                    mpid,
                );
                
                try self.addLimitOrder(new_order);
                return;                
            },
            .OrderExecutedMessage => |exec| {
                // partial execution -> reduce the order quantity
                if (self.debug) { std.debug.print("Executing order {d} with quantitiy {d}\n\n", .{exec.order_reference_number, exec.executed_shares}); } 
                try self.modifyOrder(exec.order_reference_number, exec.executed_shares);
                return;
            },
            .OrderExecutedwithPriceMessage => |exec| {
                // partial execution with price -> reduce the order quantity
                if (self.debug) { std.debug.print("Executing order {d} with quantitiy {d} at price {d}\n\n", .{exec.order_reference_number, exec.executed_shares, exec.execution_price}); } 
                try self.modifyOrder(exec.order_reference_number, exec.executed_shares);
                return;
            },
            else => return error.InvalidITCHMessage,
        }
    }    
    
    pub fn sideFromIndicator(ind: u8) Side {
        return switch (ind) {
            'B' => Side.bid,
            'S' => Side.ask,
            else => @panic("Unknown buy_sell_indicator"),
        };
    }

    pub fn addLimitOrder(self: *OrderBook, order: Order) !void {
        // gets book and key (price level), given side and price 
        const book_info = self.getBookAndKey(order.side, order.price);

        // gets pointer to the orderqueue at the key (price level), if it doesn't exist, creates it 
        var queue_ptr = book_info.book.getPtr(book_info.key) orelse blk: {
            try book_info.book.insert(book_info.key, OrderQueue.init(self.allocator));
            break :blk book_info.book.getPtr(book_info.key).?;
        };
        
        if(self.debug) { std.debug.print("Adding order {d} with quantitiy {d} at price {d}\n\n", .{order.order_id, order.original_quantity, order.price}); }
        
        const node = try queue_ptr.append(order);
        
        // node is a pointer to the inserted node
        try self.order_id_map.put(order.order_id, node);         
    }

    pub fn popFrontAtPrice(self: *OrderBook, price: f32, side: Side) !void {
        const book_info = self.getBookAndKey(side, price);

        var queue = book_info.book.getPtr(book_info.key) orelse return error.NotFound;
        const node = queue.head orelse return error.NotFound;
        
        if (self.debug) { std.debug.print("Popping order {d} with quantitiy {d} at price {d}\n\n", .{node.value.order_id, node.value.remaining_quantity, node.value.price}); }
        
        // remove from order_id_map before popping from the queue
        _ = self.order_id_map.remove(node.value.order_id);

        if (queue.popFront() == null) return error.NotFound;

        cleanupEmptyQueue(book_info.book, book_info.key);
    }
    
    pub fn getOrderById(self: *OrderBook, order_id: u64) !*Order {
        if (self.debug) { std.debug.print("Getting order {d}\n", .{order_id}); } 
        if(self.order_id_map.getPtr(order_id)) |order| {
            return order.*;
        } else {
           std.debug.print("Order not found in map for id: {}\n", .{order_id}); 
           return error.NotFound; 
        }
    }

    pub fn removeOrderById(self: *OrderBook, order_id: u64) !void {
        const node = self.order_id_map.get(order_id) orelse return error.NotFound;
        
        const order = node.value;
        const book_info = self.getBookAndKey(order.side, order.price);
        var queue_ptr = book_info.book.getPtr(book_info.key) orelse return error.NotFound;
        
        if (self.debug) { std.debug.print("Removing order {d} with quantitiy {d} at price {d}\n\n", .{order.order_id, order.remaining_quantity, order.price}); }
        queue_ptr.remove(node);
        
        _ = self.order_id_map.remove(order_id);

        cleanupEmptyQueue(book_info.book, book_info.key);
    }

    
    pub fn modifyOrder(self: *OrderBook, order_id: u64, quantity: u32) !void {
        if (self.order_id_map.get(order_id)) |node| {
            if (self.debug) { std.debug.print(" -> Modifying order {d} with quantitiy {d} at price {d} -> new quantitiy {d}\n\n",
                .{order_id, quantity, node.value.price, node.value.remaining_quantity - quantity}); } 
            
            node.value.remaining_quantity -= quantity; 
        } else {
            std.debug.print("Order not found in map for id: {}\n", .{order_id});
        }
    }

    pub fn getBestBidOrder(self: *OrderBook) ?*Order {
        var it = self.bids.iterator();
        if (it.next()) |entry| {
            if (self.debug) { std.debug.print("Best bid order: {d}\n", .{entry.value.peekFront().*.printInfo(),}); }
            return entry.value.peekFront();
        }
        return null;
    }

    pub fn getBestAskOrder(self: *OrderBook) ?*Order {
        var it = self.asks.iterator();
        if (it.next()) |entry| {
            if (self.debug) { std.debug.print("Best ask order: {d}\n", .{entry.value.peekFront().*.printInfo(), }); } 
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

    pub fn printBook(self: *OrderBook) void {
        print("OrderBook Info:\n", .{});

        print("Bids:\n", .{});
        var bid_it = self.bids.iterator();
        while (bid_it.next()) |entry| {
            const price: f64 = -entry.key;
            print("  Price: {d:.2}\n", .{price});
            var node = entry.value.head;
            while (node) |n| {
                const o = n.value;
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
                const o = n.value;
                print("    OrderId: {}, Qty: {d}, Side: {s}\n", .{
                    o.order_id, o.remaining_quantity, @tagName(o.side),
                });
                node = n.next;
            }
        }
        print("\n", .{});    
    }
};
