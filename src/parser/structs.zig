const std = @import("std");
const utils = @import("utils.zig");
const assert = std.debug.assert;

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

pub const MessageHeader = packed struct {
    stock_locate: u16,
    tracking_number: u16,
    timestamp: u48,

    pub fn initFromBytes(payload: []const u8) MessageHeader {
        return std.mem.bytesToValue(MessageHeader, payload.ptr);
    }

    pub fn printInfo(self: MessageHeader) void {
        std.debug.print("  stock_locate = {d}\n", .{self.stock_locate});
        std.debug.print("  tracking_number = {d}\n", .{self.tracking_number});
        std.debug.print("  timestamp = {d}\n", .{self.timestamp});
    }
};

pub const SystemEventMessage = struct {
    header: MessageHeader,
    event_code: u8,

    pub fn initFromBytes(payload: []const u8) SystemEventMessage {
        return SystemEventMessage{
            .header = MessageHeader.initFromBytes(payload),
            .event_code = utils.readU8(payload, 10),
        };
    }

    pub fn printInfo(self: SystemEventMessage) void {
        std.debug.print("SystemEventMessage {{\n", .{});

        self.header.printInfo();
        const event_code_str = switch (self.event_code) {
            'O' => "Start of Messages",
            'S' => "Start of System hours",
            'Q' => "Start of Market hours",
            'M' => "End of Market hours",
            'E' => "End of System hours",
            'C' => "End of Messages",
            else => "Unknown event code",
        };

        std.debug.print(" event_code = {s}\n", .{event_code_str});
        std.debug.print("}}\n\n", .{});
    }
};

pub const StockDirectoryMessage = struct {
    header: MessageHeader, // 0-9
    stock: [8]u8, // 11-18
    market_category: u8, // 19
    financial_status_indicator: u8, // 20
    round_lot_size: u32, // 21-24
    round_lots_only: u8, // 25
    issue_classification: u8, // 26
    issue_sub_type: [2]u8, // 27-28
    authenticity: u8, // 29
    short_sale_threshold_indicator: u8, // 30
    ipo_flag: u8, // 31
    luld_reference_price_tier: u8, // 32
    etp_flag: u8, // 33
    etp_leverage_factor: u32, // 34-37
    inverse_indicator: u8, // 38

    pub fn initFromBytes(payload: []const u8) StockDirectoryMessage {
        return StockDirectoryMessage{
            .header = MessageHeader.initFromBytes(payload),
            .stock = payload[10..18].*,
            .market_category = utils.readU8(payload, 18),
            .financial_status_indicator = utils.readU8(payload, 19),
            .round_lot_size = utils.readU32(payload, 20),
            .round_lots_only = utils.readU8(payload, 24),
            .issue_classification = utils.readU8(payload, 25),
            .issue_sub_type = payload[26..28].*,
            .authenticity = utils.readU8(payload, 28),
            .short_sale_threshold_indicator = utils.readU8(payload, 29),
            .ipo_flag = utils.readU8(payload, 30),
            .luld_reference_price_tier = utils.readU8(payload, 31),
            .etp_flag = utils.readU8(payload, 32),
            .etp_leverage_factor = utils.readU32(payload, 33),
            .inverse_indicator = utils.readU8(payload, 37),
        };
    }

    pub fn printInfo(self: StockDirectoryMessage) void {
        std.debug.print("StockDirectoryMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  market_category = {s}\n", .{utils.printMarketCategory(self.market_category)});
        std.debug.print("  financial_status_indicator = {s}\n", .{utils.printFinancialStatusIndicator(self.financial_status_indicator)});
        std.debug.print("  round_lot_size = {d}\n", .{self.round_lot_size});
        std.debug.print("  round_lots_only = {c}\n", .{self.round_lots_only});
        std.debug.print("  issue_classification = {c}\n", .{self.issue_classification});
        std.debug.print("  issue_sub_type = {c}{c}\n", .{ self.issue_sub_type[0], self.issue_sub_type[1] });
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

pub const StockTradingActionMessage = struct {
    header: MessageHeader,
    stock: [8]u8,
    trading_state: u8,
    reserved: u8,
    reason: [4]u8,

    pub fn initFromBytes(payload: []const u8) StockTradingActionMessage {
        return StockTradingActionMessage{
            .header = MessageHeader.initFromBytes(payload),
            .stock = payload[10..18].*,
            .trading_state = utils.readU8(payload, 18),
            .reserved = utils.readU8(payload, 19),
            .reason = payload[20..24].*,
        };
    }

    pub fn printInfo(self: StockTradingActionMessage) void {
        std.debug.print("StockTradingActionMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  trading_state = {s}\n", .{utils.printTradingState(self.trading_state)});
        std.debug.print("  reserved = {c}\n", .{self.reserved});
        std.debug.print("  reason = {s}\n", .{self.reason});
        std.debug.print("}}\n\n", .{});
    }
};

pub const ShortSalePriceTestMessage = struct {
    header: MessageHeader,
    stock: [8]u8,
    reg_sho_action: u8,

    pub fn initFromBytes(payload: []const u8) ShortSalePriceTestMessage {
        return ShortSalePriceTestMessage{
            .header = MessageHeader.initFromBytes(payload),
            .stock = payload[10..18].*,
            .reg_sho_action = utils.readU8(payload, 18),
        };
    }

    pub fn printInfo(self: ShortSalePriceTestMessage) void {
        std.debug.print("ShortSalePriceTestMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  reg_sho_action = {s}\n", .{utils.printRegSHOAction(self.reg_sho_action)});
        std.debug.print("}}\n\n", .{});
    }
};

pub const MarketParticipantPositionMessage = struct {
    header: MessageHeader,
    market_participant_id: [4]u8,
    stock: [8]u8,
    primary_market_maker: u8,
    market_maker_mode: u8,
    market_participant_state: u8,

    pub fn initFromBytes(payload: []const u8) MarketParticipantPositionMessage {
        return MarketParticipantPositionMessage{
            .header = MessageHeader.initFromBytes(payload),
            .market_participant_id = payload[10..14].*,
            .stock = payload[14..22].*,
            .primary_market_maker = utils.readU8(payload, 22),
            .market_maker_mode = utils.readU8(payload, 23),
            .market_participant_state = utils.readU8(payload, 24),
        };
    }

    pub fn printInfo(self: MarketParticipantPositionMessage) void {
        std.debug.print("MarketParticipantPositionMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  market_participant_id = {s}\n", .{self.market_participant_id});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  primary_market_maker = {c}\n", .{self.primary_market_maker});
        std.debug.print("  market_maker_mode = {s}\n", .{utils.printMarketMakerMode(self.market_maker_mode)});
        std.debug.print("  market_participant_state = {s}\n", .{utils.printMarketParticipantState(self.market_participant_state)});
        std.debug.print("}}\n\n", .{});
    }
};

pub const MWCBDeclineLevelMessage = struct {
    header: MessageHeader,
    level_one_price: f32,
    level_two_price: f32,
    level_three_price: f32,

    pub fn initFromBytes(payload: []const u8) MWCBDeclineLevelMessage {
        return MWCBDeclineLevelMessage{
            .header = MessageHeader.initFromBytes(payload),
            .level_one_price = utils.readF32(payload, 10),
            .level_two_price = utils.readF32(payload, 14),
            .level_three_price = utils.readF32(payload, 18),
        };
    }

    pub fn printInfo(self: MWCBDeclineLevelMessage) void {
        std.debug.print("MWCBDeclineLevelMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  level_one_price = {d}\n", .{self.level_one_price});
        std.debug.print("  level_two_price = {d}\n", .{self.level_two_price});
        std.debug.print("  level_three_price = {d}\n", .{self.level_three_price});
        std.debug.print("}}\n\n", .{});
    }
};

pub const MWCBStatusMessage = struct {
    header: MessageHeader,
    breached_level: u8,

    pub fn initFromBytes(payload: []const u8) MWCBStatusMessage {
        return MWCBStatusMessage{
            .header = MessageHeader.initFromBytes(payload),
            .breached_level = utils.readU8(payload, 10),
        };
    }

    pub fn printInfo(self: MWCBStatusMessage) void {
        std.debug.print("MWCBStatusMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  breached_level = {d}\n", .{self.breached_level});
        std.debug.print("}}\n\n", .{});
    }
};

pub const QuotingPeriodUpdateMessage = struct {
    header: MessageHeader,
    ipo_quotation_release_time: u32,
    ipo_quotation_release_qualifier: u8,
    ipo_price: f32,

    pub fn initFromBytes(payload: []const u8) QuotingPeriodUpdateMessage {
        return QuotingPeriodUpdateMessage{
            .header = MessageHeader.initFromBytes(payload),
            .ipo_quotation_release_time = utils.readU32(payload, 10),
            .ipo_quotation_release_qualifier = utils.readU8(payload, 14),
            .ipo_price = utils.readF32(payload, 15),
        };
    }

    pub fn printInfo(self: QuotingPeriodUpdateMessage) void {
        std.debug.print("QuotingPeriodUpdateMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  ipo_quotation_release_time = {d}\n", .{self.ipo_quotation_release_time});

        // FIXME: return a enum, instead of this shit
        if (self.ipo_quotation_release_qualifier != 'A' and self.ipo_quotation_release_qualifier != 'C') {
            std.debug.print("  WARNING: Invalid ipo_quotation_release_qualifier: {d} (expected 'A' or 'C')\n", .{self.ipo_quotation_release_qualifier});
        }

        // std.debug.print("  ipo_quotation_release_qualifier = {c}\n", .{self.ipo_quotation_release_qualifier}); // Must be A or C
        std.debug.print("  ipo_price = {d}\n", .{self.ipo_price});
        std.debug.print("}}\n\n", .{});
    }
};

pub const LULDAuctionCollarMessage = struct {
    header: MessageHeader,
    stock: [8]u8,
    auction_caller_reference_price: f32,
    upper_auction_collar_price: f32,
    lower_auction_collar_price: f32,
    auction_caller_extension: u32,

    pub fn initFromBytes(payload: []const u8) LULDAuctionCollarMessage {
        return LULDAuctionCollarMessage{
            .header = MessageHeader.initFromBytes(payload),
            .stock = payload[10..18].*,
            .auction_caller_reference_price = utils.readF32(payload, 18),
            .upper_auction_collar_price = utils.readF32(payload, 22),
            .lower_auction_collar_price = utils.readF32(payload, 26),
            .auction_caller_extension = utils.readU32(payload, 30),
        };
    }

    pub fn printInfo(self: LULDAuctionCollarMessage) void {
        std.debug.print("LULDAuctionCollarMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  auction_caller_reference_price = {d}\n", .{self.auction_caller_reference_price});
        std.debug.print("  upper_auction_collar_price = {d}\n", .{self.upper_auction_collar_price});
        std.debug.print("  lower_auction_collar_price = {d}\n", .{self.lower_auction_collar_price});
        std.debug.print("  auction_caller_extension = {d}\n", .{self.auction_caller_extension});
        std.debug.print("}}\n\n", .{});
    }
};

pub const OperationalHaltMessage = struct {
    header: MessageHeader,
    stock: [8]u8,
    market_code: u8,
    operation_halt_message: u8,

    pub fn initFromBytes(payload: []const u8) OperationalHaltMessage {
        return OperationalHaltMessage{
            .header = MessageHeader.initFromBytes(payload),
            .stock = payload[10..18].*,
            .market_code = utils.readU8(payload, 18),
            .operation_halt_message = utils.readU8(payload, 19),
        };
    }

    pub fn printInfo(self: OperationalHaltMessage) void {
        std.debug.print("OperationalHaltMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  market_code = {d}\n", .{self.market_code});
        std.debug.print("  operation_halt_message = {d}\n", .{self.operation_halt_message});
        std.debug.print("}}\n\n", .{});
    }
};

pub const AddOrderNoMPIDMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,
    buy_sell_indicator: u8,
    shares: u32,
    stock: [8]u8,
    price: f32,

    pub fn initFromBytes(payload: []const u8) AddOrderNoMPIDMessage {
        return AddOrderNoMPIDMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
            .buy_sell_indicator = utils.readU8(payload, 18),
            .shares = utils.readU32(payload, 19),
            .stock = payload[23..31].*,
            .price = utils.readF32(payload, 31),
        };
    }

    pub fn printInfo(self: AddOrderNoMPIDMessage) void {
        std.debug.print("AddOrderNoMPIDMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  buy_sell_indicator = {c}\n", .{self.buy_sell_indicator});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("}}\n\n", .{});
    }
};

pub const AddOrderWithMPIDMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,
    buy_sell_indicator: u8,
    shares: u32,
    stock: [8]u8,
    price: f32,
    attribution: [4]u8,

    pub fn initFromBytes(payload: []const u8) AddOrderWithMPIDMessage {
        return AddOrderWithMPIDMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
            .buy_sell_indicator = utils.readU8(payload, 18),
            .shares = utils.readU32(payload, 19),
            .stock = payload[23..31].*,
            .price = utils.readF32(payload, 31),
            .attribution = payload[35..39].*,
        };
    }

    pub fn printInfo(self: AddOrderWithMPIDMessage) void {
        std.debug.print("AddOrderWithMPIDMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  buy_sell_indicator = {c}\n", .{self.buy_sell_indicator});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("  attribution = {s}\n", .{self.attribution});
        std.debug.print("}}\n\n", .{});
    }
};

pub const OrderExecutedMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,
    executed_shares: u32,
    match_number: u64,

    pub fn initFromBytes(payload: []const u8) OrderExecutedMessage {
        return OrderExecutedMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
            .executed_shares = utils.readU32(payload, 18),
            .match_number = utils.readU64(payload, 22),
        };
    }

    pub fn printInfo(self: OrderExecutedMessage) void {
        std.debug.print("OrderExecutedMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  executed_shares = {d}\n", .{self.executed_shares});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("}}\n\n", .{});
    }
};

pub const OrderExecutedwithPriceMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,
    executed_shares: u32,
    match_number: u64,
    printable: u8,
    execution_price: f32,

    pub fn initFromBytes(payload: []const u8) OrderExecutedwithPriceMessage {
        return OrderExecutedwithPriceMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
            .executed_shares = utils.readU32(payload, 18),
            .match_number = utils.readU64(payload, 22),
            .printable = utils.readU8(payload, 30),
            .execution_price = utils.readF32(payload, 31),
        };
    }

    pub fn printInfo(self: OrderExecutedwithPriceMessage) void {
        std.debug.print("OrderExecutedwithPriceMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  executed_shares = {d}\n", .{self.executed_shares});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("  printable = {c}\n", .{self.printable});
        std.debug.print("  execution_price = {d}\n", .{self.execution_price});
        std.debug.print("}}\n\n", .{});
    }
};

pub const OrderCancelMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,
    cancelled_shares: u32,

    pub fn initFromBytes(payload: []const u8) OrderCancelMessage {
        return OrderCancelMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
            .cancelled_shares = utils.readU32(payload, 18),
        };
    }

    pub fn printInfo(self: OrderCancelMessage) void {
        std.debug.print("OrderCancelMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  cancelled_shares = {d}\n", .{self.cancelled_shares});
        std.debug.print("}}\n\n", .{});
    }
};

pub const OrderDeleteMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,

    pub fn initFromBytes(payload: []const u8) OrderDeleteMessage {
        return OrderDeleteMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
        };
    }

    pub fn printInfo(self: OrderDeleteMessage) void {
        std.debug.print("OrderDeleteMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("}}\n\n", .{});
    }
};

pub const OrderReplaceMessage = struct {
    header: MessageHeader,
    original_order_reference_number: u64,
    new_order_reference_number: u64,
    shares: u32,
    price: f32,

    pub fn initFromBytes(payload: []const u8) OrderReplaceMessage {
        return OrderReplaceMessage{
            .header = MessageHeader.initFromBytes(payload),
            .original_order_reference_number = utils.readU64(payload, 10),
            .new_order_reference_number = utils.readU64(payload, 18),
            .shares = utils.readU32(payload, 26),
            .price = utils.readF32(payload, 30),
        };
    }

    pub fn printInfo(self: OrderReplaceMessage) void {
        std.debug.print("OrderReplaceMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  original_order_reference_number = {d}\n", .{self.original_order_reference_number});
        std.debug.print("  new_order_reference_number = {d}\n", .{self.new_order_reference_number});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("}}\n\n", .{});
    }
};

pub const TradeMessage = struct {
    header: MessageHeader,
    order_reference_number: u64,
    buy_sell_indicator: u8,
    shares: u32,
    stock: [8]u8,
    price: f32,
    match_number: u64,

    pub fn initFromBytes(payload: []const u8) TradeMessage {
        return TradeMessage{
            .header = MessageHeader.initFromBytes(payload),
            .order_reference_number = utils.readU64(payload, 10),
            .buy_sell_indicator = utils.readU8(payload, 18),
            .shares = utils.readU32(payload, 19),
            .stock = payload[23..31].*,
            .price = utils.readF32(payload, 31),
            .match_number = utils.readU64(payload, 35),
        };
    }

    pub fn printInfo(self: TradeMessage) void {
        std.debug.print("TradeMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  order_reference_number = {d}\n", .{self.order_reference_number});
        std.debug.print("  buy_sell_indicator = {c}\n", .{self.buy_sell_indicator});
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  price = {d}\n", .{self.price});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("}}\n\n", .{});
    }
};

pub const CrossTradeMessage = struct {
    header: MessageHeader,
    shares: u64,
    stock: [8]u8,
    cross_price: f32,
    match_number: u64,
    cross_type: u8,

    pub fn initFromBytes(payload: []const u8) CrossTradeMessage {
        return CrossTradeMessage{
            .header = MessageHeader.initFromBytes(payload),
            .shares = utils.readU64(payload, 10),
            .stock = payload[18..26].*,
            .cross_price = utils.readF32(payload, 26),
            .match_number = utils.readU64(payload, 30),
            .cross_type = utils.readU8(payload, 38),
        };
    }

    pub fn printInfo(self: CrossTradeMessage) void {
        std.debug.print("CrossTradeMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  shares = {d}\n", .{self.shares});
        std.debug.print("  stock = {s}\n", .{self.stock});
        std.debug.print("  cross_price = {d}\n", .{self.cross_price});
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("  cross_type = {c}\n", .{self.cross_type});
        std.debug.print("}}\n\n", .{});
    }
};

pub const BrokenTradeMessage = struct {
    header: MessageHeader,
    match_number: u64,

    pub fn initFromBytes(payload: []const u8) BrokenTradeMessage {
        return BrokenTradeMessage{
            .header = MessageHeader.initFromBytes(payload),
            .match_number = utils.readU64(payload, 10),
        };
    }

    pub fn printInfo(self: BrokenTradeMessage) void {
        std.debug.print("BrokenTradeMessage {{\n", .{});
        self.header.printInfo();
        std.debug.print("  match_number = {d}\n", .{self.match_number});
        std.debug.print("}}\n\n", .{});
    }
};

pub const NOIIMessage = struct {
    header: MessageHeader,
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
            .header = MessageHeader.initFromBytes(payload),
            .paired_shares = utils.readU64(payload, 10),
            .imbalance_shares = utils.readU64(payload, 18),
            .imbalance_direction = utils.readU8(payload, 26),
            .stock = payload[27..35].*,
            .far_price = utils.readF32(payload, 35),
            .near_price = utils.readF32(payload, 39),
            .current_reference_price = utils.readF32(payload, 43),
            .cross_type = utils.readU8(payload, 47),
            .price_variation_indicator = utils.readU8(payload, 48),
        };
    }

    pub fn printInfo(self: NOIIMessage) void {
        std.debug.print("NOIIMessage {{\n", .{});
        self.header.printInfo();
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

pub const DirectListingWithCapitalRaisePriceMessage = struct {
    header: MessageHeader,
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
            .header = MessageHeader.initFromBytes(payload),
            .stock = payload[10..18].*,
            .open_eligibility_status = utils.readU8(payload, 18),
            .minimum_allowable_price = utils.readF32(payload, 19),
            .maximum_allowable_price = utils.readF32(payload, 23),
            .near_execution_price = utils.readF32(payload, 27),
            .near_execution_time = utils.readU64(payload, 31),
            .lower_price_range_collar = utils.readF32(payload, 39),
            .upper_price_range_collar = utils.readF32(payload, 43),
        };
    }

    pub fn printInfo(self: DirectListingWithCapitalRaisePriceMessage) void {
        std.debug.print("DirectListingWithCapitalRaisePriceMessage {{\n", .{});
        self.header.printInfo();
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
