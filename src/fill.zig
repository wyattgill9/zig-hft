const std = @import("std");

pub fn main() !void {
    const complete_message = [_]u8{
        // SystemEventMessage (12 bytes)
        'S',             // message_type = 'S' = System Event  
        0x12, 0x34,       // stock_locate = 0x1234 = 4660
        0x56, 0x78,       // tracking_number = 0x5678 = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp = [1, 2, 3, 4, 5, 6]
        'Q',             // event_code = 'Q' = Start of Market hours
        
        // StockDirectoryMessage (39 bytes)
        'R',                   // message_type = 'R'
        0x04, 0xD2,             // stock_locate = 1234
        0x16, 0x2E,             // tracking_number = 5678
        0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12, // timestamp = 0x123456789ABC (48-bit little endian)
        0x45, 0x58, 0x41, 0x4D, 0x50, 0x4C, 0x20, 0x20, // stock = "EXAMPL  "
        0x51,                   // market_category = 'Q'
        0x44,                   // financial_status_indicator = 'D'
        0x64, 0x00, 0x00, 0x00, // round_lot_size = 100
        0x4E,                   // round_lots_only = 'N'
        0x43,                   // issue_classification = 'C'
        0x41, 0x42,             // issue_sub_type = "AB"
        0x41,                   // authenticity = 'A'
        0x59,                   // short_sale_threshold_indicator = 'Y'
        0x4E,                   // ipo_flag = 'N'
        0x31,                   // luld_reference_price_tier = '1'
        0x4E,                   // etp_flag = 'N'
        0x01, 0x00, 0x00, 0x00, // etp_leverage_factor = 1
        0x4E,                   // inverse_indicator = 'N'

        // StockTradingActionMessage (25 bytes)
        0x48,             // 'H' message_type
        0x12, 0x34,       // stock_locate (0x1234)
        0x56, 0x78,       // tracking_number (0x5678)
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp (6 bytes)
        0x54, 0x45, 0x53, 0x54, 0x53, 0x54, 0x4B, 0x20, // stock "TESTSTK "
        0x48,             // trading_state 'H'
        0x00,             // reserved
        0x41, 0x42, 0x43, 0x44, // reason "ABCD"

        // ShortSalePriceTestMessage (20 bytes)
        'Y',                   // message_type = 'Y'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        'A', 'P', 'P', 'L', ' ', ' ', ' ', ' ', // stock = "APPL    "
        '0',                   // reg_sho_action = '0'

        // MarketParticipantPositionMessage (26 bytes)
        'L',                   // message_type = 'L'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        'A', 'R', 'C', 'A',   // market_participant_id = "ARCA"
        'G', 'O', 'O', 'G', 'L', ' ', ' ', ' ', // stock = "GOOGL   "
        'Y',                   // primary_market_maker = 'Y'
        'N',                   // market_maker_mode = 'N'
        'A',                   // market_participant_state = 'A'

        // MWCBDeclineLevelMessage (23 bytes)
        'V',                   // message_type = 'V'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x00, 0x00, 0x96, 0x43, // level_one_price = 300.0
        0x00, 0x00, 0xC8, 0x43, // level_two_price = 400.0
        0x00, 0x00, 0xFA, 0x43, // level_three_price = 500.0

        // MWCBStatusMessage (12 bytes)
        'W',                   // message_type = 'W'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x01,                  // breached_level = 1

        // QuotingPeriodUpdateMessage (20 bytes)
        'K',                   // message_type = 'K'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x10, 0x27, 0x00, 0x00, // ipo_quotation_release_time = 10000
        'A',                   // ipo_quotation_release_qualifier = 'A'
        0x00, 0x00, 0x48, 0x42, // ipo_price = 50.0

        // LULDAuctionCollarMessage (35 bytes)
        'J',                   // message_type = 'J'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        'T', 'S', 'L', 'A', ' ', ' ', ' ', ' ', // stock = "TSLA    "
        0x00, 0x00, 0x20, 0x42, // auction_caller_reference_price = 40.0
        0x00, 0x00, 0x28, 0x42, // upper_auction_collar_price = 42.0
        0x00, 0x00, 0x18, 0x42, // lower_auction_collar_price = 38.0
        0xE8, 0x03, 0x00, 0x00, // auction_caller_extension = 1000

        // OperationalHaltMessage (21 bytes)
        'h',                   // message_type = 'h'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        'A', 'M', 'Z', 'N', ' ', ' ', ' ', ' ', // stock = "AMZN    "
        'Q',                   // market_code = 'Q'
        'H',                   // operation_halt_message = 'H'

        // AddOrderNoMPIDMessage (36 bytes)
        'A',                                        // 1 byte: message_type = 'A'
        0x12, 0x34,                                // 2 bytes: stock_locate = 4660
        0x56, 0x78,                                // 2 bytes: tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06,       // 6 bytes: timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // 8 bytes: order_reference_number
        'B',                                       // 1 byte: buy_sell_indicator = 'B'
        0x00, 0x00, 0x00, 0x64,                   // 4 bytes: shares = 100 (big-endian)
        'M', 'S', 'F', 'T', ' ', ' ', ' ', ' ',    // 8 bytes: stock = "MSFT    "
        0x42, 0xA0, 0x00, 0x00,                   // 4 bytes: price = 80.0 (big-endian float)

        // AddOrderWithMPIDMessage (40 bytes)
        'F',                   // message_type = 'F'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10, // order_reference_number
        'S',                   // buy_sell_indicator = 'S'
        0xC8, 0x00, 0x00, 0x00, // shares = 200
        'N', 'V', 'D', 'A', ' ', ' ', ' ', ' ', // stock = "NVDA    "
        0x00, 0x80, 0x84, 0x44, // price = 1060.0
        'N', 'A', 'S', 'D',   // attribution = "NASD"

        // OrderExecutedMessage (31 bytes)
        'E',                   // message_type = 'E'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // order_reference_number
        0x32, 0x00, 0x00, 0x00, // executed_shares = 50
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, // match_number

        // OrderExecutedwithPriceMessage (36 bytes)
        'C',                   // message_type = 'C'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10, // order_reference_number
        0x19, 0x00, 0x00, 0x00, // executed_shares = 25
        0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, // match_number
        'Y',                   // printable = 'Y'
        0x00, 0x00, 0x96, 0x42, // execution_price = 75.0

        // OrderCancelMessage (23 bytes)
        'X',                   // message_type = 'X'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // order_reference_number
        0x0A, 0x00, 0x00, 0x00, // cancelled_shares = 10

        // OrderDeleteMessage (19 bytes)
        'D',                   // message_type = 'D'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10, // order_reference_number

        // OrderReplaceMessage (35 bytes)
        'U',                   // message_type = 'U'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // original_order_reference_number
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, // new_order_reference_number
        0x96, 0x00, 0x00, 0x00, // shares = 150
        0x00, 0x00, 0x88, 0x42, // price = 68.0

        // TradeMessage (44 bytes)
        'P',                   // message_type = 'P'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x11, 0x22, // order_reference_number
        'B',                   // buy_sell_indicator = 'B'
        0x7D, 0x00, 0x00, 0x00, // shares = 125
        'G', 'M', 'E', ' ', ' ', ' ', ' ', ' ', // stock = "GME     "
        0x00, 0x00, 0xA4, 0x41, // price = 20.5
        0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, // match_number

        // CrossTradeMessage (40 bytes)
        'Q',                   // message_type = 'Q'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x10, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // shares = 10000
        'S', 'P', 'Y', ' ', ' ', ' ', ' ', ' ', // stock = "SPY     "
        0x00, 0x80, 0x5B, 0x44, // cross_price = 879.0
        0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x11, 0x22, 0x33, // match_number
        'O',                   // cross_type = 'O'

        // BrokenTradeMessage (19 bytes)
        'B',                   // message_type = 'B'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, // match_number

        // NOIIMessage (50 bytes)
        'I',                   // message_type = 'I'
        0x12, 0x34,           // stock_locate = 4660
        0x56, 0x78,           // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0xE8, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // paired_shares = 1000
        0xD0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // imbalance_shares = 2000
        'B',                   // imbalance_direction = 'B'
        'Q', 'Q', 'Q', ' ', ' ', ' ', ' ', ' ', // stock = "QQQ     "
        0x00, 0x00, 0x7A, 0x44, // far_price = 1000.0
        0x00, 0x80, 0x76, 0x44, // near_price = 985.0
        0x00, 0x40, 0x77, 0x44, // current_reference_price = 992.0
        'O',                   // cross_type = 'O'
        'I',                   // price_variation_indicator = 'I'

        // DirectListingWithCapitalRaisePriceMessage (48 bytes)
        'N',                   // message_type = 'N'
        0x04, 0xD2,           // stock_locate = 1234
        0x16, 0x2E,           // tracking_number = 5678
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        'R', 'I', 'V', 'N', ' ', ' ', ' ', ' ', // stock = "RIVN    "
        'Y',                   // open_eligibility_status = 'Y'
        0x00, 0x00, 0x14, 0x42, // minimum_allowable_price = 37.0
        0x00, 0x00, 0x2D, 0x42, // maximum_allowable_price = 43.25
        0x00, 0x00, 0x20, 0x42, // near_execution_price = 40.0
        0x40, 0x77, 0x1B, 0x00, 0x00, 0x00, 0x00, 0x00, // near_execution_time = 1800000
        0x00, 0x00, 0x17, 0x42, // lower_price_range_collar = 37.75
        0x00, 0x00, 0x29, 0x42, // upper_price_range_collar = 42.25
    };

    // Create file and write the complete message bundle
    const file = try std.fs.cwd().createFile("./data/ITCHMessage", .{
        .truncate = true,
        .read = false,
    });
    
    defer file.close();

    var writer = file.writer();
    try writer.writeAll(&complete_message);
}
