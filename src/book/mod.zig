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
    
    // try ob.popFrontAtPrice(100.0, .bid);
    // try ob.popFrontAtPrice(100.0, .bid);
      
    // const a = try ob.getOrderById(1); 
    // try ob.modifyOrder(1, 10); 
     
    try ob.removeOrderById(2);

    ob.printInfo();
}
