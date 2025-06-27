const std = @import("std");
const print = @import("std").debug.print;
pub const Order = @import("./order.zig").Order;
pub const OrderBook = @import("./orderbook.zig").OrderBook;

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
    
    try ob.popFrontAtPrice(100.0, .bid);
    try ob.popFrontAtPrice(100.0, .bid);
    
    ob.printInfo();

    // const best_bid = ob.getBestBidPrice();
    // const best_ask = ob.getBestAskPrice();

    // if (best_bid) |bid| {
    //     std.debug.print("Best Bid={d}", .{bid});
    // } else {
    //     std.debug.print("No best bid", .{});
    // }
    // if (best_ask) |ask| {
    //     std.debug.print(", Best Ask={d}\n", .{ask});
    // } else {
    //     std.debug.print(", No best ask\n", .{});
    // }
}
