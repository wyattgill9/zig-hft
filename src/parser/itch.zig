const std = @import("std");
const utils = @import("utils.zig");
const ITCHMessage = @import("structs.zig").ITCHMessage;
const structs = @import("structs.zig");

pub fn parseITCHMessage(buffer: []const u8) ITCHMessage {
    return ITCHMessage.initFromBytes(buffer); 
}
