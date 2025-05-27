const std = @import("std");
const utils = @import("utils.zig");

const ITCHMessage = union(enum) {
    SystemEventMessage: SystemEventMessage,                             // 11 bytes                              
    
    StockDirectoryMessage: StockDirectoryMessage,                       // 
    StockTradingActionMessage: StockTradingActionMessage,               // 
    ShortSalePriceTestMessage: ShortSalePriceTestMessage,               // 
    MarketParticipantPositionMessage: MarketParticipantPositionMessage, //     
    
    MWCBDeclineLevelMessage: MWCBDeclineLevelMessage,                   // 
    MWCBStatusMessage: MWCBStatusMessage,                               // 
    IPOQuotationPeriodUpdateMessage: IPOQuotationPeriodUpdateMessage,   // 
    LULDAuctionCollarMessage: LULDAuctionCollarMessage,                 // 
    OperationalHaltMessage: OperationalHaltMessage,                     //  
    
    AddOrderNoMPIDMessage: AddOrderNoMPIDMessage,                       // 
    AddOrderWithMPIDMessage: AddOrderWithMPIDMessage,                   // 
    
    OrderExecutedMessage: OrderExecutedMessage,                         // 
    OrderExecutedwithPriceMessage: OrderExecutedwithPriceMessage,       // 
    OrderCancelMessage: OrderCancelMessage,                             // 
    OrderDeleteMessage: OrderDeleteMessage,                             // 
    OrderReplaceMessage: OrderReplaceMessage,                           // 
    
    TradeMessage: TradeMessage,                                         //  
    CrossTradeMessage: CrossTradeMessage,                               // 
    BrokenTradeMessage: BrokenTradeMessage,                             // 
    
    NOIIMessage: NOIIMessage, // Net Order Imballance Indicator         //

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
            'K' => ITCHMessage{ .IPOQuotationPeriodUpdateMessage = IPOQuotationPeriodUpdateMessage.initFromBytes(payload) },
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
                } else {
                    utils.printGenericInfo(msg); 
                }
            },
        }
    }
};



const SystemEventMessage = packed struct {
    stock_locate: u16,
    tracking_number: u16,
    timestamp: u64, // 6 bytes stored here as u64
    event_code: u8,

    pub fn initFromBytes(payload: []const u8) SystemEventMessage {
        return SystemEventMessage{
            .stock_locate = utils.readU16(payload, 0),      // offset 1 in original buffer
            .tracking_number = utils.readU16(payload, 2),   // offset 3
            .timestamp = utils.readU48(payload, 4),         // offset 5
            .event_code = utils.readU8(payload, 10),        // offset 11
        };
    }

    pub fn printInfo(self: SystemEventMessage) void {
        std.debug.print("SystemEventMessage {\n", .{});
        std.debug.print("   message_type        = {c}\n", .{self.message_type});
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

        std.debug.print("   event_code          = {d}\n", .{event_code_str});
        std.debug.print("}\n\n", .{}); 
        
    }
};

// const MarketCatagory = union(enum(u8)) {
//     NasdaqGlobalSelectedMarket,
//     NasdaqGlobalMarket,
//     NasdaqCapitalMarket,
//     NYCE, 
//     NYSEAmerican,
//     NYSEArca,
//     BATSZExchange,
//     InvestorsExchange,
//     NotAvailable
// };
//
// const FinancialStatusIndicator = union(enum(u8)) {
//     Deficient,
//     Delinquent,
//     Bankrupt,
//     Suspended,
//     DeficientAndBankrupt,
//     DeficientAndDelinquent,
//     DelinquentAndBankrupt,
//     DeficientDelinquentAndBankrupt,
//     CRSETP, // Creation and/or Redemption Suspended for Exchange Trading Products 
//     Normal, //Normal (Default): Issuer Is NOT Deficient, Delinquent, or Bankrupt
//     NotAvailable
// };

const StockDirectoryMessage = packed struct {
    message_type: u8,          // 'R'
    stock_locate: u16,         // 0
    tracking_number: u16,      // 2
    timestamp: u64,            // 4 (6 bytes u48)
    stock: [8]u8,              // 10
    market_category: u8,       // 18
    financial_status_indicator: u8, // 19
    round_lot_size: u32,       // 20
    round_lots_only: u8,       // 24
    issue_classification: u8,  // 25
    issue_sub_type: [2]u8,     // 26
    authenticity: u8,          // 28
    short_sale_threshold_indicator: u8, // 29
    ipo_flag: u8,              // 30
    luld_reference_price_tier: u8, // 31
    etp_flag: u8,              // 32
    etp_leverage_factor: u32,  // 33
    inverse_indicator: u8,     // 37

    pub fn initFromBytes(payload: []const u8) StockDirectoryMessage {
        return StockDirectoryMessage{
            .message_type = 'R',
            .stock_locate = utils.readU16(payload, 0),
            .tracking_number = utils.readU16(payload, 2),
            .timestamp = utils.readU48(payload, 4),
            .stock = [8]u8{
                payload[10], payload[11], payload[12], payload[13],
                payload[14], payload[15], payload[16], payload[17]
            },
            .market_category = utils.readU8(payload, 18),
            .financial_status_indicator =
                utils.readU8(payload, 19), 
            .round_lot_size = utils.readU32(payload, 20),
            .round_lots_only = utils.readU8(payload, 24),
            .issue_classification = utils.readU8(payload, 25),
            .issue_sub_type = [2]u8{
                payload[26], payload[27]
            },
            .authenticity = utils.readU8(payload, 28),
            .short_sale_threshold_indicator = utils.readU8(payload, 29),
            .ipo_flag = utils.readU8(payload, 30),
            .luld_reference_price_tier = utils.readU8(payload, 31),
            .etp_flag = utils.readU8(payload, 32),
            .etp_leverage_factor = utils.readU32(payload, 33),
            .inverse_indicator = utils.readU8(payload, 37),
        };
    }
};


const StockTradingActionMessage = packed struct {
    
    pub fn initFromBytes(payload: []const u8) StockTradingActionMessage {
        
    }
};

const ShortSalePriceTestMessage = packed struct {
   pub fn initFromBytes(payload: []const u8) ShortSalePriceTestMessage {
       
   } 
};

const MarketParticipantPositionMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) MarketParticipantPositionMessage {
        
    }
};

const MWCBDeclineLevelMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) MWCBDeclineLevelMessage {
        
    }
};

const MWCBStatusMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) MWCBStatusMessage {
        
    }
};

const IPOQuotationPeriodUpdateMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) IPOQuotationPeriodUpdateMessage {
        
    }
};

const LULDAuctionCollarMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) LULDAuctionCollarMessage {
        
    }
};

const OperationalHaltMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) OperationalHaltMessage {
        
    }
};

const AddOrderNoMPIDMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) AddOrderNoMPIDMessage {
        
    }
};

const AddOrderWithMPIDMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) AddOrderWithMPIDMessage {
        
    }
};

const OrderExecutedMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) OrderExecutedMessage {
        
    }
};

const OrderExecutedwithPriceMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) OrderExecutedwithPriceMessage {
        
    }
};

const OrderCancelMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) OrderCancelMessage {
        
    }
};

const OrderDeleteMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) OrderDeleteMessage {
        
    }
};

const OrderReplaceMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) OrderReplaceMessage {
        
    }
};

const TradeMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) TradeMessage {
        
    }
};

const CrossTradeMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) CrossTradeMessage {
        
    }
};

const BrokenTradeMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) BrokenTradeMessage {
        
    }
};

const NOIIMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) NOIIMessage {
        
    }
};

const DirectListingWithCapitalRaisePriceMessage = packed struct {
    pub fn initFromBytes(payload: []const u8) DirectListingWithCapitalRaisePriceMessage {
        
    }
};
