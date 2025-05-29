const std = @import("std");
const utils = @import("utils.zig");

// TODO: remove the message_type in each struct, as it is inferred in the Union?

pub const ITCHMessage = union(enum) {
    SystemEventMessage: SystemEventMessage,
    StockDirectoryMessage: StockDirectoryMessage,
    StockTradingActionMessage: StockTradingActionMessage,
    MarketParticipantPositionMessage: MarketParticipantPositionMessage,
    ShortSalePriceTestMessage: ShortSalePriceTestMessage,
    MWCBDeclineLevelMessage: MWCBDeclineLevelMessage,
    MWCBStatusMessage: MWCBStatusMessage,
   
    QuotingPeriodUpdateMessage: QuotingPeriodUpdateMessage,
    LULDAuctionCollarMessage: LULDAuctionCollarMessage,
    OperationalHaltMessage: OperationalHaltMessage,

    AddOrderNoMPIDMessage: AddOrderNoMPIDMessage,
    AddOrderWithMPIDMessage: AddOrderWithMPIDMessage,
    OrderExecutedMessage: OrderExecutedMessage,
    OrderExecutedwithPriceMessage: OrderExecutedwithPriceMessage,
    OrderCancelMessage: OrderCancelMessage,
    OrderDeleteMessage: OrderDeleteMessage,
    OrderReplaceMessage: OrderReplaceMessage,
    TradeMessage: TradeMessage,
    CrossTradeMessage: CrossTradeMessage,
    BrokenTradeMessage: BrokenTradeMessage,
    NOIIMessage: NOIIMessage,
    DirectListingWithCapitalRaisePriceMessage: DirectListingWithCapitalRaisePriceMessage,

    pub fn initFromBytes(payload: []const u8) ITCHMessage {
        const msg_type = payload[0];
        return switch (msg_type) {
            'S' => ITCHMessage{ .SystemEventMessage = SystemEventMessage.initFromBytes(payload) }, 
            'R' => ITCHMessage{ .StockDirectoryMessage = StockDirectoryMessage.initFromBytes(payload) },
            'H' => ITCHMessage{ .StockTradingActionMessage = StockTradingActionMessage.initFromBytes(payload) },  
            'Y' => ITCHMessage{ .ShortSalePriceTestMessage = ShortSalePriceTestMessage.initFromBytes(payload) },
            'L' => ITCHMessage{ .MarketParticipantPositionMessage = MarketParticipantPositionMessage.initFromBytes(payload) },
            'V' => ITCHMessage{ .MWCBDeclineLevelMessage = MWCBDeclineLevelMessage.initFromBytes(payload) },
            'W' => ITCHMessage{ .MWCBStatusMessage = MWCBStatusMessage.initFromBytes(payload) },
            'K' => ITCHMessage{ .QuotingPeriodUpdateMessage = QuotingPeriodUpdateMessage.initFromBytes(payload) },
            'J' => ITCHMessage{ .LULDAuctionCollarMessage = LULDAuctionCollarMessage.initFromBytes(payload) },
            'h' => ITCHMessage{ .OperationalHaltMessage = OperationalHaltMessage.initFromBytes(payload) },
            'A' => ITCHMessage{ .AddOrderNoMPIDMessage = AddOrderNoMPIDMessage.initFromBytes(payload) },
            'F' => ITCHMessage{ .AddOrderWithMPIDMessage = AddOrderWithMPIDMessage.initFromBytes(payload) },
            'E' => ITCHMessage{ .OrderExecutedMessage = OrderExecutedMessage.initFromBytes(payload) },
            'C' => ITCHMessage{ .OrderExecutedwithPriceMessage = OrderExecutedwithPriceMessage.initFromBytes(payload) },
            'X' => ITCHMessage{ .OrderCancelMessage = OrderCancelMessage.initFromBytes(payload) },
            'D' => ITCHMessage{ .OrderDeleteMessage = OrderDeleteMessage.initFromBytes(payload) },
            'U' => ITCHMessage{ .OrderReplaceMessage = OrderReplaceMessage.initFromBytes(payload) },
            'P' => ITCHMessage{ .TradeMessage = TradeMessage.initFromBytes(payload) },
            'Q' => ITCHMessage{ .CrossTradeMessage = CrossTradeMessage.initFromBytes(payload) },
            'B' => ITCHMessage{ .BrokenTradeMessage = BrokenTradeMessage.initFromBytes(payload) },
            'I' => ITCHMessage{ .NOIIMessage = NOIIMessage.initFromBytes(payload) },
            'N' => ITCHMessage{ .DirectListingWithCapitalRaisePriceMessage = DirectListingWithCapitalRaisePriceMessage.initFromBytes(payload) },
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
            .message_type = utils.readU8(payload, 0), // should be Y FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
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
            .message_type = utils.readU8(payload, 0), // should be L FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
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
        std.debug.print("  primary_market_maker = {c}\n", .{self.primary_market_maker});
        std.debug.print("  market_maker_mode = {s}\n", .{utils.printMarketMakerMode(self.market_maker_mode)});
        std.debug.print("  market_participant_state = {s}\n", .{utils.printMarketParticipantState(self.market_participant_state)});
        std.debug.print("}}\n\n", .{});         
    } 
};

// const base = struct {
//     message_type: u8,
//     stock_locate: u16,
//     tracking_number: u16,
//     timestamp: [6]u8,
// };

const MWCBDeclineLevelMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    level_one_price: f32,
    level_two_price: f32,
    level_three_price: f32,

    pub fn initFromBytes(payload: []const u8) MWCBDeclineLevelMessage {
        return MWCBDeclineLevelMessage{
            .message_type = utils.readU8(payload, 0), // should be V FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .level_one_price = utils.readF32(payload, 11),
            .level_two_price = utils.readF32(payload, 15),
            .level_three_price = utils.readF32(payload, 19),
        };
    }

    pub fn printInfo(self: MWCBDeclineLevelMessage) void {
        std.debug.print("MWCBDeclineLevelMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  level_one_price = {d}\n", .{self.level_one_price});
        std.debug.print("  level_two_price = {d}\n", .{self.level_two_price});
        std.debug.print("  level_three_price = {d}\n", .{self.level_three_price});
        std.debug.print("}}\n\n", .{});
    }
};

const MWCBStatusMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    breached_level: u8,

    pub fn initFromBytes(payload: []const u8) MWCBStatusMessage {
        return MWCBStatusMessage{
            .message_type = utils.readU8(payload, 0), // should be V FIXME: dont include this bc its already checked in ITCHMessage.IntFromBytes 
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .breached_level = utils.readU8(payload, 11),
        };
    }

    pub fn printInfo(self: MWCBStatusMessage) void {
        std.debug.print("MWCBStatusMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  breached_level = {d}\n", .{self.breached_level});
        std.debug.print("}}\n\n", .{});
    }
};

const QuotingPeriodUpdateMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    ipo_quotation_release_time: u32,
    ipo_quotation_release_qualifier: u8,
    ipo_price: f32,

    pub fn initFromBytes(payload: []const u8) QuotingPeriodUpdateMessage {
        return QuotingPeriodUpdateMessage {
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .ipo_quotation_release_time = utils.readU32(payload, 11),
            .ipo_quotation_release_qualifier = utils.readU8(payload, 15),
            .ipo_price = utils.readF32(payload, 16),
        };
    }

    pub fn printInfo(self: QuotingPeriodUpdateMessage) void {
        std.debug.print("QuotingPeriodUpdateMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  ipo_quotation_release_time = {d}\n", .{self.ipo_quotation_release_time});
        std.debug.print("  ipo_quotation_release_qualifier = {c}\n", .{self.ipo_quotation_release_qualifier}); // Must be A or C
        std.debug.print("  ipo_price = {d}\n", .{self.ipo_price});
        std.debug.print("}}\n\n", .{});
    }
};

const LULDAuctionCollarMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    stock: [8]u8,
    auction_caller_reference_price: f32,
    upper_auction_collar_price: f32,
    lower_auction_collar_price: f32,
    auction_caller_extension: u32,


    pub fn initFromBytes(payload: []const u8) LULDAuctionCollarMessage {
        return LULDAuctionCollarMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .stock = payload[11..19].*,
            .auction_caller_reference_price = utils.readF32(payload, 19),
            .upper_auction_collar_price = utils.readF32(payload, 23),
            .lower_auction_collar_price = utils.readF32(payload, 27),
            .auction_caller_extension = utils.readU32(payload, 31),
        };
    }
    
    pub fn printInfo(self: LULDAuctionCollarMessage) void {
        std.debug.print("LULDAuctionCollarMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  auction_caller_reference_price = {d}\n", .{self.auction_caller_reference_price});
        std.debug.print("  upper_auction_collar_price = {d}\n", .{self.upper_auction_collar_price});
        std.debug.print("  lower_auction_collar_price = {d}\n", .{self.lower_auction_collar_price});
        std.debug.print("  auction_caller_extension = {d}\n", .{self.auction_caller_extension});
        std.debug.print("}}\n\n", .{});
    }

};

const OperationalHaltMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    stock: [8]u8,
    market_code: u8,
    operation_halt_message: u8,

    pub fn initFromBytes(payload: []const u8) OperationalHaltMessage {
        return OperationalHaltMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .stock = payload[11..19].*,
            .market_code = utils.readU8(payload, 19),
            .operation_halt_message = utils.readU8(payload, 20),
        };
    }

    pub fn printInfo(self: OperationalHaltMessage) void {
        std.debug.print("OperationalHaltMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  market_code = {d}\n", .{self.market_code});
        std.debug.print("  operation_halt_message = {d}\n", .{self.operation_halt_message});
        std.debug.print("}}\n\n", .{});
    }
};

const AddOrderNoMPIDMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,
    buy_sell_indicator: u8,
    shares: u32,
    stock: [8]u8,
    price: f32,

    pub fn initFromBytes(payload: []const u8) AddOrderNoMPIDMessage {
        return AddOrderNoMPIDMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
            .buy_sell_indicator = utils.readU8(payload, 19),
            .shares = utils.readU32(payload, 20),
            .stock = payload[24..32].*,
            .price = utils.readF32(payload, 32),
        };
    }

    pub fn printInfo(self: AddOrderNoMPIDMessage) void {
        std.debug.print("AddOrderNoMPIDMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  buy_sell_indicator = {c}\n", .{self.buy_sell_indicator});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("}}\n\n", .{});
    }
};

const AddOrderWithMPIDMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,
    buy_sell_indicator: u8,
    shares: u32,
    stock: [8]u8,
    price: f32,
    attribution: [4]u8,

    pub fn initFromBytes(payload: []const u8) AddOrderWithMPIDMessage {
        return AddOrderWithMPIDMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
            .buy_sell_indicator = utils.readU8(payload, 19),
            .shares = utils.readU32(payload, 20),
            .stock = payload[24..32].*,
            .price = utils.readF32(payload, 32),
            .attribution = payload[36..40].*,
        };
    }

    pub fn printInfo(self: AddOrderWithMPIDMessage) void {
        std.debug.print("AddOrderWithMPIDMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  buy_sell_indicator = {c}\n", .{self.buy_sell_indicator});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("  attribution = {s}\n", .{self.attribution});
        std.debug.print("}}\n\n", .{});
    }
};

const OrderExecutedMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,
    executed_shares: u32,
    match_number: u64,

    pub fn initFromBytes(payload: []const u8) OrderExecutedMessage {
        return OrderExecutedMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
            .executed_shares = utils.readU32(payload, 19),
            .match_number = utils.readU64(payload, 23),
        };
    }

    pub fn printInfo(self: OrderExecutedMessage) void {
        std.debug.print("OrderExecutedMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  executed_shares = {d}\n", .{self.executed_shares});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("}}\n\n", .{});
    }
};

const OrderExecutedwithPriceMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,
    executed_shares: u32,
    match_number: u64,
    printable: u8,
    execution_price: f32,

    pub fn initFromBytes(payload: []const u8) OrderExecutedwithPriceMessage {
        return OrderExecutedwithPriceMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
            .executed_shares = utils.readU32(payload, 19),
            .match_number = utils.readU64(payload, 23),
            .printable = utils.readU8(payload, 31),
            .execution_price = utils.readF32(payload, 32),
        };
    }

    pub fn printInfo(self: OrderExecutedwithPriceMessage) void {
        std.debug.print("OrderExecutedwithPriceMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  executed_shares = {d}\n", .{self.executed_shares});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("  printable = {c}\n", .{self.printable});
        std.debug.print("  execution_price = {d}\n", .{self.execution_price});
        std.debug.print("}}\n\n", .{});
    }
};

const OrderCancelMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,
    cancelled_shares: u32,

    pub fn initFromBytes(payload: []const u8) OrderCancelMessage {
        return OrderCancelMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
            .cancelled_shares = utils.readU32(payload, 19),
        };
    }

    pub fn printInfo(self: OrderCancelMessage) void {
        std.debug.print("OrderCancelMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  cancelled_shares = {d}\n", .{self.cancelled_shares});
        std.debug.print("}}\n\n", .{});
    }
};

const OrderDeleteMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,

    pub fn initFromBytes(payload: []const u8) OrderDeleteMessage {
        return OrderDeleteMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
        };
    }

    pub fn printInfo(self: OrderDeleteMessage) void {
        std.debug.print("OrderDeleteMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("}}\n\n", .{});
    }
};

const OrderReplaceMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    original_order_reference_number: u64,
    new_order_reference_number: u64,
    shares: u32,
    price: f32,

    pub fn initFromBytes(payload: []const u8) OrderReplaceMessage {
        return OrderReplaceMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .original_order_reference_number = utils.readU64(payload, 11),
            .new_order_reference_number = utils.readU64(payload, 19),
            .shares = utils.readU32(payload, 27),
            .price = utils.readF32(payload, 31),
        };
    }

    pub fn printInfo(self: OrderReplaceMessage) void {
        std.debug.print("OrderReplaceMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  original_order_reference_number = {d}\n", .{self.original_order_reference_number});
        std.debug.print("  new_order_reference_number = {d}\n", .{self.new_order_reference_number});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("}}\n\n", .{});
    }
};

const TradeMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    order_reference_number: u64,
    buy_sell_indicator: u8,
    shares: u32,
    stock: [8]u8,
    price: f32,
    match_number: u64,

    pub fn initFromBytes(payload: []const u8) TradeMessage {
        return TradeMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .order_reference_number = utils.readU64(payload, 11),
            .buy_sell_indicator = utils.readU8(payload, 19),
            .shares = utils.readU32(payload, 20),
            .stock = payload[24..32].*,
            .price = utils.readF32(payload, 32),
            .match_number = utils.readU64(payload, 36),
        };
    }

    pub fn printInfo(self: TradeMessage) void {
        std.debug.print("TradeMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  buy_sell_indicator = {c}\n", .{self.buy_sell_indicator});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("}}\n\n", .{});
    }
};

const CrossTradeMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    shares: u64,
    stock: [8]u8,
    cross_price: f32,
    match_number: u64,
    cross_type: u8,

    pub fn initFromBytes(payload: []const u8) CrossTradeMessage {
        return CrossTradeMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .shares = utils.readU64(payload, 11),
            .stock = payload[19..27].*,
            .cross_price = utils.readF32(payload, 27),
            .match_number = utils.readU64(payload, 31),
            .cross_type = utils.readU8(payload, 39),
        };
    }

    pub fn printInfo(self: CrossTradeMessage) void {
        std.debug.print("CrossTradeMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  cross_price = {d}\n", .{self.cross_price});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("  cross_type = {c}\n", .{self.cross_type});
        std.debug.print("}}\n\n", .{});
    }
};

const BrokenTradeMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    match_number: u64,

    pub fn initFromBytes(payload: []const u8) BrokenTradeMessage {
        return BrokenTradeMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .match_number = utils.readU64(payload, 11),
        };
    }

    pub fn printInfo(self: BrokenTradeMessage) void {
        std.debug.print("BrokenTradeMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("}}\n\n", .{});
    }
};

const NOIIMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    paired_shares: u64,
    imbalance_shares: u64,
    imbalance_direction: u8,
    stock: [8]u8,
    far_price: f32,
    near_price: f32,
    current_reference_price: f32,
    cross_type: u8,
    price_variation_indicator: u8,

    pub fn initFromBytes(payload: []const u8) NOIIMessage {
        return NOIIMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .paired_shares = utils.readU64(payload, 11),
            .imbalance_shares = utils.readU64(payload, 19),
            .imbalance_direction = utils.readU8(payload, 27),
            .stock = payload[28..36].*,
            .far_price = utils.readF32(payload, 36),
            .near_price = utils.readF32(payload, 40),
            .current_reference_price = utils.readF32(payload, 44),
            .cross_type = utils.readU8(payload, 48),
            .price_variation_indicator = utils.readU8(payload, 49),
        };
    }

    pub fn printInfo(self: NOIIMessage) void {
        std.debug.print("NOIIMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  paired_shares = {d}\n", .{self.paired_shares});
        std.debug.print("  imbalance_shares = {d}\n", .{self.imbalance_shares});
        std.debug.print("  imbalance_direction = {c}\n", .{self.imbalance_direction});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  far_price = {d}\n", .{self.far_price});
        std.debug.print("  near_price = {d}\n", .{self.near_price});
        std.debug.print("  current_reference_price = {d}\n", .{self.current_reference_price});
        std.debug.print("  cross_type = {c}\n", .{self.cross_type});
        std.debug.print("  price_variation_indicator = {c}\n", .{self.price_variation_indicator});
        std.debug.print("}}\n\n", .{});
    }
};

const DirectListingWithCapitalRaisePriceMessage = struct {
    message_type: u8,
    stock_locate: u16,
    tracking_number: u16,
    timestamp: [6]u8,
    stock: [8]u8,
    open_eligibility_status: u8,
    minimum_allowable_price: f32,
    maximum_allowable_price: f32,
    near_execution_price: f32,
    near_execution_time: u64,
    lower_price_range_collar: f32,
    upper_price_range_collar: f32,

    pub fn initFromBytes(payload: []const u8) DirectListingWithCapitalRaisePriceMessage {
        return DirectListingWithCapitalRaisePriceMessage{
            .message_type = utils.readU8(payload, 0),
            .stock_locate = utils.readU16(payload, 1),
            .tracking_number = utils.readU16(payload, 3),
            .timestamp = payload[5..11].*,
            .stock = payload[11..19].*,
            .open_eligibility_status = utils.readU8(payload, 19),
            .minimum_allowable_price = utils.readF32(payload, 20),
            .maximum_allowable_price = utils.readF32(payload, 24),
            .near_execution_price = utils.readF32(payload, 28),
            .near_execution_time = utils.readU64(payload, 32),
            .lower_price_range_collar = utils.readF32(payload, 40),
            .upper_price_range_collar = utils.readF32(payload, 44),
        };
    }

    pub fn printInfo(self: DirectListingWithCapitalRaisePriceMessage) void {
        std.debug.print("DirectListingWithCapitalRaisePriceMessage {{\n", .{});
        std.debug.print("  message_type = {c}\n", .{self.message_type});
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  open_eligibility_status = {c}\n", .{self.open_eligibility_status});
        std.debug.print("  minimum_allowable_price = {d}\n", .{self.minimum_allowable_price});
        std.debug.print("  maximum_allowable_price = {d}\n", .{self.maximum_allowable_price});
        std.debug.print("  near_execution_price = {d}\n", .{self.near_execution_price});
        std.debug.print("  near_execution_time = {d}\n", .{self.near_execution_time});
        std.debug.print("  lower_price_range_collar = {d}\n", .{self.lower_price_range_collar});
        std.debug.print("  upper_price_range_collar = {d}\n", .{self.upper_price_range_collar});
        std.debug.print("}}\n\n", .{});
    }
};

pub fn main() void {}
