// const std = @import("std");

pub fn parseITCHMessage(buffer: []const u8) @import("structs.zig").ITCHMessage {
    return @import("structs.zig").ITCHMessage.initFromBytes(buffer); 
}
