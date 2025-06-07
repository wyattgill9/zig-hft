const std = @import("std");
const parse = @import("parser/mod.zig");
const tsc = @import("tsc/mod.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./src/data/ITCHMessage", .{});
    defer file.close();
    
    var offset: u64 = 0;
    var buffer: [1024]u8 = undefined; // increase buffer size
    const bytesRead = try file.readAll(&buffer);
    
    var total_cycles: u64 = 0;
    var message_count: u32 = 0;
    
    std.debug.print("Total bytes read: {d}\n", .{bytesRead});
    
    while (offset < bytesRead) {
        const msg_type = buffer[offset];
        const msg_length = parse.getMessageLength(msg_type);
        
        if (offset + msg_length > bytesRead) {
            std.debug.print("Warning: Not enough bytes for message type '{c}'. Expected {d} bytes, but only {d} remaining.\n", 
                .{msg_type, msg_length, bytesRead - offset});
            break;
        }
        
        std.debug.print("Processing message '{c}' at offset {d}, length: {d}\n", 
            .{msg_type, offset, msg_length});
        
        const full_message = buffer[offset .. offset + msg_length];
        
        const start = tsc.now();
        const msg = parse.parseITCHMessage(msg_type, full_message);
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
    if (message_count > 0) {
        std.debug.print("Average cycles per message: {d}\n", .{total_cycles / message_count});
    }
}
