const std = @import("std");
const utils = @import("utils.zig");

// TODO: remove the message_type in each struct, as it is inferred in the Union?

pub const ITCHMessage = union(enum) {
    SystemEventMessage: SystemEventMessage,
    StockDirectoryMessage: StockDirectoryMessage,
    StockTradingActionMessage: StockTradingActionMessage,
    ShortSalePriceTestMessage: ShortSalePriceTestMessage,
    // MarketParticipantPositionMessage: MarketParticipantPositionMessage,
    // MWCBDeclineLevelMessage: MWCBDeclineLevelMessage,
    // MWCBStatusMessage: MWCBStatusMessage,
    // IPOQuotationPeriodUpdateMessage: IPOQuotationPeriodUpdateMessage,
    // LULDAuctionCollarMessage: LULDAuctionCollarMessage,
    // OperationalHaltMessage: OperationalHaltMessage,
    // AddOrderNoMPIDMessage: AddOrderNoMPIDMessage,
    // AddOrderWithMPIDMessage: AddOrderWithMPIDMessage,
    // OrderExecutedMessage: OrderExecutedMessage,
    // OrderExecutedwithPriceMessage: OrderExecutedwithPriceMessage,
    // OrderCancelMessage: OrderCancelMessage,
    // OrderDeleteMessage: OrderDeleteMessage,
    // OrderReplaceMessage: OrderReplaceMessage,
    // TradeMessage: TradeMessage,
    // CrossTradeMessage: CrossTradeMessage,
    // BrokenTradeMessage: BrokenTradeMessage,
    // NOIIMessage: NOIIMessage,
    // DirectListingWithCapitalRaisePriceMessage: DirectListingWithCapitalRaisePriceMessage,

    pub fn initFromBytes(payload: []const u8) ITCHMessage {
        const msg_type = payload[0];
        return switch (msg_type) {
            'S' => ITCHMessage{ .SystemEventMessage = SystemEventMessage.initFromBytes(payload) }, 
            'R' => ITCHMessage{ .StockDirectoryMessage = StockDirectoryMessage.initFromBytes(payload) },
            'H' => ITCHMessage{ .StockTradingActionMessage = StockTradingActionMessage.initFromBytes(payload) },  
            'Y' => ITCHMessage{ .ShortSalePriceTestMessage = ShortSalePriceTestMessage.initFromBytes(payload) },
            // 'L' => ITCHMessage{ .MarketParticipantPositionMessage = MarketParticipantPositionMessage.initFromBytes(payload) },
            // 'V' => ITCHMessage{ .MWCBDeclineLevelMessage = MWCBDeclineLevelMessage.initFromBytes(payload) },
            // 'W' => ITCHMessage{ .MWCBStatusMessage = MWCBStatusMessage.initFromBytes(payload) },
            // 'K' => ITCHMessage{ .IPOQuotationPeriodUpdateMessage = IPOQuotationPeriodUpdateMessage.initFromBytes(payload) },
            // 'J' => ITCHMessage{ .LULDAuctionCollarMessage = LULDAuctionCollarMessage.initFromBytes(payload) },
            // 'h' => ITCHMessage{ .OperationalHaltMessage = OperationalHaltMessage.initFromBytes(payload) },
            // 'A' => ITCHMessage{ .AddOrderNoMPIDMessage = AddOrderNoMPIDMessage.initFromBytes(payload) },
            // 'F' => ITCHMessage{ .AddOrderWithMPIDMessage = AddOrderWithMPIDMessage.initFromBytes(payload) },
            // 'E' => ITCHMessage{ .OrderExecutedMessage = OrderExecutedMessage.initFromBytes(payload) },
            // 'C' => ITCHMessage{ .OrderExecutedwithPriceMessage = OrderExecutedwithPriceMessage.initFromBytes(payload) },
            // 'X' => ITCHMessage{ .OrderCancelMessage = OrderCancelMessage.initFromBytes(payload) },
            // 'D' => ITCHMessage{ .OrderDeleteMessage = OrderDeleteMessage.initFromBytes(payload) },
            // 'U' => ITCHMessage{ .OrderReplaceMessage = OrderReplaceMessage.initFromBytes(payload) },
            // 'P' => ITCHMessage{ .TradeMessage = TradeMessage.initFromBytes(payload) },
            // 'Q' => ITCHMessage{ .CrossTradeMessage = CrossTradeMessage.initFromBytes(payload) },
            // 'B' => ITCHMessage{ .BrokenTradeMessage = BrokenTradeMessage.initFromBytes(payload) },
            // 'I' => ITCHMessage{ .NOIIMessage = NOIIMessage.initFromBytes(payload) },
            // 'N' => ITCHMessage{ .DirectListingWithCapitalRaisePriceMessage = DirectListingWithCapitalRaisePriceMessage.initFromBytes(payload) },
            else => unreachable,
        };
    }

    pub fn printInfo(self: ITCHMessage) void {
        switch (self) {
            inline else => |msg| {
                if (@hasDecl(@TypeOf(msg), "printInfo")) {
                    msg.printInfo();
                }
            },
        }
    }
};

const SystemEventMessage = struct {
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8, // exactly 6 bytes
    event_code: u8,

    pub fn initFromBytes(payload: []const u8) SystemEventMessage {
        return SystemEventMessage {
            .stock_locate = utils.readU16(payload, 0),
            .tracking_number = utils.readU16(payload, 2),
            .timestamp = payload[4..10].*,
            .event_code = utils.readU8(payload, 10),
        };
    }

    pub fn printInfo(self: SystemEventMessage) void {
        std.debug.print("SystemEventMessage {{\n", .{});
        std.debug.print("   stock_locate        = {d}\n", .{self.stock_locate});
        std.debug.print("   tracking_number     = {d}\n", .{self.tracking_number});
        std.debug.print("   timestamp           = {d}\n", .{self.timestamp});

        const event_code_str = switch (self.event_code) {
            'O' => "Start of Messages",
            'S' => "Start of System hours",
            'Q' => "Start of Market hours",
            'M' => "End of Market hours",
            'E' => "End of System hours",
            'C' => "End of Messages",
            else => "Unknown event code",
        };

        std.debug.print("   event_code          = {s}\n", .{event_code_str});
        std.debug.print("}}\n\n", .{});
    }
};

const StockDirectoryMessage = struct {
    message_type: u8,                            // 0
    stock_locate: u16,                           // 1-2
    tracking_number: u16,                        // 3-4
    timestamp: u64,                              // 5-10 (u48)
    stock: [8]u8,                                // 11-18
    market_category: u8,                         // 19
    financial_status_indicator: u8,              // 20
    round_lot_size: u32,                         // 21-24
    round_lots_only: u8,                         // 25
    issue_classification: u8,                    // 26
    issue_sub_type: [2]u8,                       // 27-28
    authenticity: u8,                            // 29
    short_sale_threshold_indicator: u8,          // 30
    ipo_flag: u8,                                // 31
    luld_reference_price_tier: u8,               // 32
    etp_flag: u8,                                // 33
    etp_leverage_factor: u32,                    // 34-37
    inverse_indicator: u8,                       // 38

    pub fn initFromBytes(payload: []const u8) StockDirectoryMessage {
        return StockDirectoryMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = utils.readU48(payload, 5),
            .stock = payload[11..19].*,
            .market_category = utils.readU8(payload, 19),
            .financial_status_indicator = utils.readU8(payload, 20),
            .round_lot_size = utils.readU32(payload, 21),
            .round_lots_only = utils.readU8(payload, 25),
            .issue_classification = utils.readU8(payload, 26),
            .issue_sub_type = payload[27..29].*,
            .authenticity = utils.readU8(payload, 29),
            .short_sale_threshold_indicator = utils.readU8(payload, 30),
            .ipo_flag = utils.readU8(payload, 31),
            .luld_reference_price_tier = utils.readU8(payload, 32),
            .etp_flag = utils.readU8(payload, 33),
            .etp_leverage_factor = utils.readU32(payload, 34),
            .inverse_indicator = utils.readU8(payload, 38),
        };
    }

    pub fn printInfo(self: StockDirectoryMessage) void {
        std.debug.print("StockDirectoryMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  market_category = {s}\n", .{utils.printMarketCategory(self.market_category)});
        std.debug.print("  financial_status_indicator = {s}\n", .{utils.printFinancialStatusIndicator(self.financial_status_indicator)});
        std.debug.print("  round_lot_size = {d}\n", .{self.round_lot_size});
        std.debug.print("  round_lots_only = {c}\n", .{self.round_lots_only});
        std.debug.print("  issue_classification = {c}\n", .{self.issue_classification});
        std.debug.print("  issue_sub_type = {c}{c}\n", .{self.issue_sub_type[0], self.issue_sub_type[1]});
        std.debug.print("  authenticity = {c}\n", .{self.authenticity});
        std.debug.print("  short_sale_threshold_indicator = {c}\n", .{self.short_sale_threshold_indicator});
        std.debug.print("  ipo_flag = {c}\n", .{self.ipo_flag});
        std.debug.print("  luld_reference_price_tier = {c}\n", .{self.luld_reference_price_tier});
        std.debug.print("  etp_flag = {c}\n", .{self.etp_flag});
        std.debug.print("  etp_leverage_factor = {d}\n", .{self.etp_leverage_factor});
        std.debug.print("  inverse_indicator = {c}\n", .{self.inverse_indicator});
        std.debug.print("}}\n\n", .{});
    }
};

const StockTradingActionMessage = struct {
    message_type: u8, // H
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8, // exactly 6 bytes
    stock: [8]u8,
    trading_state: u8,
    reserved: u8,
    reason: [4]u8,

    pub fn initFromBytes(payload: []const u8) StockTradingActionMessage {
        return StockTradingActionMessage{
            .message_type = utils.readU8(payload, 0), // should be H FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .stock = payload[11..19].*,
            .trading_state = utils.readU8(payload, 19),
            .reserved = utils.readU8(payload, 20),
            .reason = payload[21..25].*,
        };
    }

    pub fn printInfo(self: StockTradingActionMessage) void {
        std.debug.print("StockTradingActionMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  trading_state = {s}\n", .{utils.printTradingState(self.trading_state)});
        std.debug.print("  reserved = {c}\n", .{self.reserved});
        std.debug.print("  reason = {s}\n", .{self.reason});
        std.debug.print("}}\n\n", .{});
    }
};

const ShortSalePriceTestMessage = struct {
    message_type: u8, 
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    stock: [8]u8,
    reg_sho_action: u8,

    pub fn initFromBytes(payload: []const u8) ShortSalePriceTestMessage {
        return ShortSalePriceTestMessage{
            .message_type = utils.readU8(payload, 0), // should be H FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .stock = payload[11..19].*,
            .reg_sho_action = utils.readU8(payload, 19),
        };
    }

    pub fn printInfo(self: ShortSalePriceTestMessage) void {
        std.debug.print("ShortSalePriceTestMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  reg_sho_action = {s}\n", .{utils.printRegSHOAction(self.reg_sho_action)});
        std.debug.print("}}\n\n", .{});
    }
};

const MarketParticipantPositionMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    market_participant_id: [4]u8,
    stock: [8]u8,
    primary_market_maker: u8,
    market_maker_mode: u8,
    market_participant_state: u8,

    pub fn initFromBytes(payload: []const u8) MarketParticipantPositionMessage {
        return MarketParticipantPositionMessage{
            .message_type = utils.readU8(payload, 0), // should be H FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .market_participant_id = payload[11..15].*,
            .stock = payload[15..23].*,
            .primary_market_maker = utils.readU8(payload, 23),
            .market_maker_mode = utils.readU8(payload, 24),
            .market_participant_state = utils.readU8(payload, 25),
        };
    }

    pub fn printInfo(self: MarketParticipantPositionMessage) void {
        std.debug.print("MarketParticipantPositionMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});        
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  market_participant_id = {s}\n", .{self.market_participant_id});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  primary_market_maker = {c}\n", .{self.primary_market_make});
        std.debug.print("  market_maker_mode = {s}\n", .{utils.printMarketMakerMode(self.market_maker_mode)});
        std.debug.print("  market_participant_state = {s}\n", .{utils.printMarketParticipantState(self.market_participant_state)});
        std.debug.print("}}\n\n", .{});         
    } 
};

const MWCBDeclineLevelMessage = struct {
    // pub fn initFromBytes(payload: []const u8) MWCBDeclineLevelMessage {
    //
    // }
};

const MWCBStatusMessage = struct {
    // pub fn initFromBytes(payload: []const u8) MWCBStatusMessage {
    //
    // }
};

const IPOQuotationPeriodUpdateMessage = struct {
    // pub fn initFromBytes(payload: []const u8) IPOQuotationPeriodUpdateMessage {
    //
    // }
};

const LULDAuctionCollarMessage = struct {
    // pub fn initFromBytes(payload: []const u8) LULDAuctionCollarMessage {
    //
    // }
};

const OperationalHaltMessage = struct {
    // pub fn initFromBytes(payload: []const u8) OperationalHaltMessage {
    //
    // }
};

const AddOrderNoMPIDMessage = struct {
    // pub fn initFromBytes(payload: []const u8) AddOrderNoMPIDMessage {
    //
    // }
};

const AddOrderWithMPIDMessage = struct {
    // pub fn initFromBytes(payload: []const u8) AddOrderWithMPIDMessage {
    //
    // }
};

const OrderExecutedMessage = struct {
    // pub fn initFromBytes(payload: []const u8) OrderExecutedMessage {
    //
    // }
};

const OrderExecutedwithPriceMessage = struct {
    // pub fn initFromBytes(payload: []const u8) OrderExecutedwithPriceMessage {
    //
    // }
};

const OrderCancelMessage = struct {
    // pub fn initFromBytes(payload: []const u8) OrderCancelMessage {
    //
    // }
};

const OrderDeleteMessage = packed struct {
    // pub fn initFromBytes(payload: []const u8) OrderDeleteMessage {
    //
    // }
};

const OrderReplaceMessage = struct {
    // pub fn initFromBytes(payload: []const u8) OrderReplaceMessage {
    //
    // }
};

const TradeMessage =  struct {
    // pub fn initFromBytes(payload: []const u8) TradeMessage {
    //
    // }
};

const CrossTradeMessage = struct {
    // pub fn initFromBytes(payload: []const u8) CrossTradeMessage {
    //
    // }
};

const BrokenTradeMessage = struct {
    // pub fn initFromBytes(payload: []const u8) BrokenTradeMessage {
    //
    // }
};

const NOIIMessage = struct {
    // pub fn initFromBytes(payload: []const u8) NOIIMessage {
    //
    // }
};

const DirectListingWithCapitalRaisePriceMessage = struct {
    // pub fn initFromBytes(payload: []const u8) DirectListingWithCapitalRaisePriceMessage {
    //
    // }
};

pub fn main() void {}
