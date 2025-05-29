const std = @import("std");

pub fn main() !void {
    const message: [39]u8 = .{
        'R',        // message_type
        0x00, 0x01, // stock_locate
        0x00, 0x02, // tracking_number
        0x00, 0x00, 0x00, 0x00, 0x03, 0x04, // timestamp (6 bytes)
        'A','B','C','D','E','F','G','H',     // stock (8 bytes)
        'Q',        // market_category
        'N',        // financial_status_indicator
        0x00, 0x00, 0x27, 0x10, // round_lot_size (10000)
        'Y',        // round_lots_only
        'E',        // issue_classification
        'X', 'Y',   // issue_sub_type
        'P',        // authenticity
        'N',        // short_sale_threshold_indicator
        'Y',        // ipo_flag
        '1',        // luld_reference_price_tier
        'Y',        // etp_flag
        0x00, 0x00, 0x00, 0x03, // etp_leverage_factor (3)
        'N'         // inverse_indicator
    };

    const total_bytes: usize = 1024 * 1024; // 1 MiB
    const message_count: usize = total_bytes / message.len;

    const file = try std.fs.cwd().createFile("./data/ITCHMessage", .{
        .truncate = true,
        .read = false,
    });
    defer file.close();

    var writer = file.writer();
    var i: usize = 0;
    while (i < message_count) : (i += 1) {
        try writer.writeAll(&message);
    }

    std.debug.print("Written {} messages, {} total bytes to ITCHMessage\n", .{message_count, message_count * message.len});
}
