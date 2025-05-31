const std = @import("std");
const parse = @import("parser/mod.zig");
const tsc = @import("tsc/mod.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/data/ITCHMessage", .{});
    defer file.close();
    
    var offset: u64 = 0;
    var buffer: [256]u8 = undefined;
    const bytesRead = try file.readAll(&buffer);
    
    var total_cycles: u64 = 0;
    var message_count: u32 = 0;
    
    while (offset < bytesRead) {
        if (offset >= bytesRead) break;
        
        const msg_type = buffer[offset];
        const msg_length = parse.getMessageLength(msg_type);
        
        if (offset + msg_length > bytesRead) {
            std.debug.print("Warning: Not enough bytes for message type '{c}'. Expected {d} bytes, but only {d} remaining.\n", 
                .{msg_type, msg_length, bytesRead - offset});
            std.debug.print("Current offset: {d}, Total bytes read: {d}\n", .{offset, bytesRead});
            break;
        }
        
        std.debug.print("Processing message '{c}' at offset {d}, payload length: {d}\n", 
            .{msg_type, offset, msg_length - 1});
        
        const payload = buffer[offset + 1 .. offset + msg_length];
        
        const start = tsc.now();
        const msg = parse.parseITCHMessage(msg_type, payload);
        const end = tsc.now();
        
        const cycles = tsc.delta(start, end);
        
        std.debug.print("Message {d}: Type {c}\n", .{ message_count + 1, msg_type });
        msg.printInfo();
        std.debug.print("Cycles: {d}\n\n", .{cycles});
        
        offset += msg_length;
        total_cycles += cycles;
        message_count += 1;
    }
    
    std.debug.print("Total messages processed: {d}\n", .{message_count});
    std.debug.print("Total cycles: {d}\n", .{total_cycles});
}
