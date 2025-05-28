const ITCHMessage = @import("structs.zig").ITCHMessage;

pub fn parseITCHMessage(buffer: []const u8) ITCHMessage {
    return ITCHMessage.initFromBytes(buffer); 
}

// pub fn main() !void {
//     // Dummy message (fill with valid bytes as needed for real test)
//     const message: [39]u8 = .{
//         'R',        // message_type
//         0x00, 0x01, // stock_locate
//         0x00, 0x02, // tracking_number
//         0x00, 0x00, 0x00, 0x00, 0x03, 0x04, // timestamp (6 bytes)
//         'A','B','C','D','E','F','G','H',     // stock (8 bytes)
//         'Q',        // market_category
//         'N',        // financial_status_indicator
//         0x00, 0x00, 0x27, 0x10, // round_lot_size (10000)
//         'Y',        // round_lots_only
//         'E',        // issue_classification
//         'X', 'Y',   // issue_sub_type
//         'P',        // authenticity
//         'N',        // short_sale_threshold_indicator
//         'Y',        // ipo_flag
//         '1',        // luld_reference_price_tier
//         'Y',        // etp_flag
//         0x00, 0x00, 0x00, 0x03, // etp_leverage_factor (3)
//         'N'         // inverse_indicator
//     };
//
//     const parsed_message = parseITCHMessage(&message);
//
//     parsed_message.printInfo();
// }
