const structs = @import("structs.zig");
const ITCHMessage = structs.ITCHMessage;
const utils = @import("utils.zig");
const std = @import("std");

pub fn parseITCHMessage(msg_type: u8, payload: []const u8) ITCHMessage {
    return switch (msg_type) {
        'S' => ITCHMessage { .SystemEventMessage = structs.SystemEventMessage.initFromBytes(payload) }, 
        'R' => ITCHMessage { .StockDirectoryMessage = structs.StockDirectoryMessage.initFromBytes(payload) },
        'H' => ITCHMessage { .StockTradingActionMessage = structs.StockTradingActionMessage.initFromBytes(payload) },  
        'Y' => ITCHMessage { .ShortSalePriceTestMessage = structs.ShortSalePriceTestMessage.initFromBytes(payload) },
        'L' => ITCHMessage { .MarketParticipantPositionMessage = structs.MarketParticipantPositionMessage.initFromBytes(payload) },
        'V' => ITCHMessage { .MWCBDeclineLevelMessage = structs.MWCBDeclineLevelMessage.initFromBytes(payload) },
        'W' => ITCHMessage { .MWCBStatusMessage = structs.MWCBStatusMessage.initFromBytes(payload) },
        'K' => ITCHMessage { .QuotingPeriodUpdateMessage = structs.QuotingPeriodUpdateMessage.initFromBytes(payload) },
        'J' => ITCHMessage {  .LULDAuctionCollarMessage = structs.LULDAuctionCollarMessage.initFromBytes(payload) },
        'h' => ITCHMessage { .OperationalHaltMessage = structs.OperationalHaltMessage.initFromBytes(payload) },
        'A' => ITCHMessage { .AddOrderNoMPIDMessage = structs.AddOrderNoMPIDMessage.initFromBytes(payload) },
        'F' => ITCHMessage { .AddOrderWithMPIDMessage = structs.AddOrderWithMPIDMessage.initFromBytes(payload) },
        'E' => ITCHMessage { .OrderExecutedMessage = structs.OrderExecutedMessage.initFromBytes(payload) },
        'C' => ITCHMessage { .OrderExecutedwithPriceMessage = structs.OrderExecutedwithPriceMessage.initFromBytes(payload) },
        'X' => ITCHMessage { .OrderCancelMessage = structs.OrderCancelMessage.initFromBytes(payload) },
        'D' => ITCHMessage { .OrderDeleteMessage = structs.OrderDeleteMessage.initFromBytes(payload) },
        'U' => ITCHMessage { .OrderReplaceMessage = structs.OrderReplaceMessage.initFromBytes(payload) },
        'P' => ITCHMessage { .TradeMessage = structs.TradeMessage.initFromBytes(payload) },
        'Q' => ITCHMessage { .CrossTradeMessage = structs.CrossTradeMessage.initFromBytes(payload) },
        'B' => ITCHMessage { .BrokenTradeMessage = structs.BrokenTradeMessage.initFromBytes(payload) },
        'I' => ITCHMessage { .NOIIMessage = structs.NOIIMessage.initFromBytes(payload) },
        'N' => ITCHMessage { .DirectListingWithCapitalRaisePriceMessage = structs.DirectListingWithCapitalRaisePriceMessage.initFromBytes(payload) },
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
