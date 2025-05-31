const std = @import("std");
const parse = @import("parser/mod.zig");
const tsc = @import("tsc/mod.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/data/ITCHMessage", .{});
    defer file.close();
    
    var offset: u64 = 0;

    var buffer: [256]u8 = undefined;
    const bytesRead = try file.readAll(&buffer);

    const msg_type = buffer[0 + offset];
    const payload = buffer[1..bytesRead];
    
    const start = tsc.now();
    const msg = parse.parseITCHMessage(msg_type, payload);
    const end = tsc.now();
    
    msg.printInfo();  
    offset += 1; 

    std.debug.print("Cycles {d}\n", .{tsc.delta(start, end)});
}
