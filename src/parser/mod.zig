const structs = @import("structs.zig");
const std = @import("std");

pub fn parseITCHMessage(buffer: []const u8) structs.ITCHMessage {
    return structs.ITCHMessage.initFromBytes(buffer); 
}

pub fn getMessageSize(buffer: []const u8) u32 {
    const msg_type = buffer[0]; 

    return switch (msg_type) {  
        'S' => @sizeOf(structs.SystemEventMessage), 
        'R' => 39, // FIXME: ADD THE APROPRIAT FOR EACH, ITS NOT -> @sizeOf(structs.StockDirectoryMessage),
        'H' => @sizeOf(structs.StockTradingActionMessage),  
        'Y' => @sizeOf(structs.ShortSalePriceTestMessage),
        'L' => @sizeOf(structs.MarketParticipantPositionMessage),
        'V' => @sizeOf(structs.MWCBDeclineLevelMessage),
        'W' => @sizeOf(structs.MWCBStatusMessage),
        'K' => @sizeOf(structs.QuotingPeriodUpdateMessage),
        'J' => @sizeOf(structs.LULDAuctionCollarMessage),
        'h' => @sizeOf(structs.OperationalHaltMessage),
        'A' => @sizeOf(structs.AddOrderNoMPIDMessage),
        'F' => @sizeOf(structs.AddOrderWithMPIDMessage),
        'E' => @sizeOf(structs.OrderExecutedMessage),
        'C' => @sizeOf(structs.OrderExecutedwithPriceMessage),
        'X' => @sizeOf(structs.OrderCancelMessage),
        'D' => @sizeOf(structs.OrderDeleteMessage),
        'U' => @sizeOf(structs.OrderReplaceMessage),
        'P' => @sizeOf(structs.TradeMessage),
        'Q' => @sizeOf(structs.CrossTradeMessage),
        'B' => @sizeOf(structs.BrokenTradeMessage),
        'I' => @sizeOf(structs.NOIIMessage),
        'N' => @sizeOf(structs.DirectListingWithCapitalRaisePriceMessage),
        else => {
            std.debug.print("Unknown message type: {}\n", .{msg_type});
            unreachable;
        },
    }; 
}

pub fn isValidMessageType(b: u8) bool {
    return switch (b) {
        'S', 'R', 'H', 'Y', 'L', 'V', 'W', 'K', 'J', 'h',
        'A', 'F', 'E', 'C', 'X', 'D', 'U', 'P', 'Q', 'B',
        'I', 'N' => true,
        else => false,
    };
}
