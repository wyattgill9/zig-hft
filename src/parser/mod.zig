const structs = @import("structs.zig");
const ITCHMessage = structs.ITCHMessage;
const utils = @import("utils.zig");
const std = @import("std");
const Order = @import("../book/order.zig").Order;
const Side = @import("../book/order.zig").Side;

pub fn parseITCHMessage(msg_type: u8, full_message: []const u8) ITCHMessage {
    const payload = full_message[1..];

    return switch (msg_type) {
        'S' => ITCHMessage{ .SystemEventMessage = structs.SystemEventMessage.initFromBytes(payload) },
        'R' => ITCHMessage{ .StockDirectoryMessage = structs.StockDirectoryMessage.initFromBytes(payload) },
        'H' => ITCHMessage{ .StockTradingActionMessage = structs.StockTradingActionMessage.initFromBytes(payload) },
        'Y' => ITCHMessage{ .ShortSalePriceTestMessage = structs.ShortSalePriceTestMessage.initFromBytes(payload) },
        'L' => ITCHMessage{ .MarketParticipantPositionMessage = structs.MarketParticipantPositionMessage.initFromBytes(payload) },
        'V' => ITCHMessage{ .MWCBDeclineLevelMessage = structs.MWCBDeclineLevelMessage.initFromBytes(payload) },
        'W' => ITCHMessage{ .MWCBStatusMessage = structs.MWCBStatusMessage.initFromBytes(payload) },
        'K' => ITCHMessage{ .QuotingPeriodUpdateMessage = structs.QuotingPeriodUpdateMessage.initFromBytes(payload) },
        'J' => ITCHMessage{ .LULDAuctionCollarMessage = structs.LULDAuctionCollarMessage.initFromBytes(payload) },
        'h' => ITCHMessage{ .OperationalHaltMessage = structs.OperationalHaltMessage.initFromBytes(payload) },
        'A' => ITCHMessage{ .AddOrderNoMPIDMessage = structs.AddOrderNoMPIDMessage.initFromBytes(payload) },
        'F' => ITCHMessage{ .AddOrderWithMPIDMessage = structs.AddOrderWithMPIDMessage.initFromBytes(payload) },
        'E' => ITCHMessage{ .OrderExecutedMessage = structs.OrderExecutedMessage.initFromBytes(payload) },
        'C' => ITCHMessage{ .OrderExecutedwithPriceMessage = structs.OrderExecutedwithPriceMessage.initFromBytes(payload) },
        'X' => ITCHMessage{ .OrderCancelMessage = structs.OrderCancelMessage.initFromBytes(payload) },
        'D' => ITCHMessage{ .OrderDeleteMessage = structs.OrderDeleteMessage.initFromBytes(payload) },
        'U' => ITCHMessage{ .OrderReplaceMessage = structs.OrderReplaceMessage.initFromBytes(payload) },
        'P' => ITCHMessage{ .TradeMessage = structs.TradeMessage.initFromBytes(payload) },
        'Q' => ITCHMessage{ .CrossTradeMessage = structs.CrossTradeMessage.initFromBytes(payload) },
        'B' => ITCHMessage{ .BrokenTradeMessage = structs.BrokenTradeMessage.initFromBytes(payload) },
        'I' => ITCHMessage{ .NOIIMessage = structs.NOIIMessage.initFromBytes(payload) },
        'N' => ITCHMessage{ .DirectListingWithCapitalRaisePriceMessage = structs.DirectListingWithCapitalRaisePriceMessage.initFromBytes(payload) },
        else => {
            std.debug.print("Unknown message type: {c} (0x{X})\n", .{ msg_type, msg_type });
            unreachable;
        },
    };
}

pub fn getMessageLength(msg_type: u8) u32 {
    return switch (msg_type) {
        'S' => 12,
        'R' => 39,
        'H' => 25,
        'Y' => 20,
        'L' => 26,
        'V' => 23,
        'W' => 12,
        'K' => 20,
        'J' => 35,
        'h' => 21,
        'A' => 36,
        'F' => 40,
        'E' => 31,
        'C' => 36,
        'X' => 23,
        'D' => 19,
        'U' => 35,
        'P' => 44,
        'Q' => 40,
        'B' => 19,
        'I' => 50,
        'N' => 48,
        else => {
            std.debug.print("Unknown message type: {c} (0x{X})\n", .{ msg_type, msg_type });
            unreachable;
        },
    };
}

pub fn isValidMessageType(b: u8) bool {
    return switch (b) {
        'S', 'R', 'H', 'Y', 'L', 'V', 'W', 'K', 'J', 'h', 'A', 'F', 'E', 'C', 'X', 'D', 'U', 'P', 'Q', 'B', 'I', 'N' => true,
        else => false,
    };
}
