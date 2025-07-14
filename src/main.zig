const std = @import("std");
const parse = @import("parser/mod.zig");
const book = @import("book/mod.zig");
const tsc = @import("tsc/mod.zig");
const core = @import("core/mod.zig");

pub fn main() !void {
    const debug = false;

    // Buffer/File TODO: ingest from NASDAQ
    var file = try std.fs.cwd().openFile("./src/data/ComprehensiveOrderBookOps", .{});
    defer file.close();
    
    var buf: [1024]u8 = undefined;
    const bytes = try file.readAll(&buf);
    var offset: u64 = 0;
  
    // OrderBook
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ob = book.OrderBook.init(allocator, debug);
    defer ob.deinit();

    // Stats 
    var total_time: u64 = 0;
    var count: u32 = 0;

    while (offset < bytes) {
        const msg_type = buf[offset];
        const len = parse.getMessageLength(msg_type);

        if (offset + len > bytes) break;

        const start = std.time.nanoTimestamp();
        const msg = parse.parseITCHMessage(msg_type, buf[offset .. offset + len]);
        const time = tsc.delta(i128, start, std.time.nanoTimestamp());

        // msg.printInfo(); 
        try ob.editBook(msg); 
        if (debug) ob.printBook(); 
        
        // const out_order = try core.processOrderBook(&ob);
        // if(out_order != null) {
            // egress.sendOrder(out_order);
        // }    

        offset += len;
        total_time += time;
        count += 1;
    }
    
    ob.printBook();
    if (debug) std.debug.print("Messages processed: {d}, Total: {d}ns, Avg: {d}ns\n", .{ count, total_time, if (count > 0) total_time / count else 0 });
}
