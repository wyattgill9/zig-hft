const std = @import("std");
const Order = @import("./order.zig").Order;
const OrderBook = @import("./orderbook.zig").OrderBook;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ob = OrderBook.init(allocator);
    defer ob.deinit();

    const o1 = Order.init(1, 100.0, 10, .bid, 12345678);
    const o2 = Order.init(2, 100.0, 5, .bid, 12345679);
    const o3 = Order.init(3, 101.0, 7, .ask, 12345680);
    const o4 = Order.init(4, 101.0, 3, .ask, 12345681);

    try ob.addLimitOrder(o1);
    try ob.addLimitOrder(o2);
    try ob.addLimitOrder(o3);
    try ob.addLimitOrder(o4);

    const bid = ob.popFrontAtPrice(100.0, .bid);

    const ask = ob.popFrontAtPrice(101.0, .ask);

    if (bid) |b| {
        std.debug.print("Popped BID order: id={}, qty={}\n", .{ b.order_id, b.quantity });
    } else {
        std.debug.print("No BID order at 100.0\n", .{});
    }

    if (ask) |a| {
        std.debug.print("Popped ASK order: id={}, qty={}\n", .{ a.order_id, a.quantity });
    } else {
        std.debug.print("No ASK order at 101.0\n", .{});
    }
}
