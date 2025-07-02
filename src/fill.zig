const std = @import("std");

pub fn main() !void {
    const message_sequence = [_]u8{
        // 1. AddOrderNoMPIDMessage - Buy order for AAPL (36 bytes)
        'A', // message_type = 'A'
        0x12, 0x34, // stock_locate = 4660
        0x56, 0x78, // tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // order_reference_number = 1
        'B', // buy_sell_indicator = 'B' (Buy)
        0x00, 0x00, 0x01, 0x2C, // shares = 300
        'A', 'A', 'P', 'L', ' ', ' ', ' ', ' ', // stock = "AAPL    "
        0x42, 0xC8, 0x00, 0x00, // price = 100.0

        // 2. AddOrderWithMPIDMessage - Sell order for AAPL with MPID (39 bytes)
        'F', // message_type = 'F'
        0x12, 0x34, // stock_locate = 4660
        0x56, 0x79, // tracking_number = 22137
        0x01, 0x02, 0x03, 0x04, 0x05, 0x07, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF0, // order_reference_number = 2
        'S', // buy_sell_indicator = 'S' (Sell)
        0x00, 0x00, 0x01, 0x90, // shares = 400
        'A', 'A', 'P', 'L', ' ', ' ', ' ', ' ', // stock = "AAPL    "
        0x42, 0xCA, 0x00, 0x00, // price = 101.0
        'G', 'S', 'C', 'O', // attribution = "GSCO" (Goldman Sachs)

        // 3. AddOrderNoMPIDMessage - Another buy order for MSFT (36 bytes)
        'A', // message_type = 'A'
        0x12, 0x35, // stock_locate = 4661
        0x56, 0x7A, // tracking_number = 22138
        0x01, 0x02, 0x03, 0x04, 0x05, 0x08, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF1, // order_reference_number = 3
        'B', // buy_sell_indicator = 'B' (Buy)
        0x00, 0x00, 0x00, 0xC8, // shares = 200
        'M', 'S', 'F', 'T', ' ', ' ', ' ', ' ', // stock = "MSFT    "
        0x43, 0x48, 0x00, 0x00, // price = 200.0

        // 4. OrderExecutedMessage - Partial execution of first order (30 bytes)
        'E', // message_type = 'E'
        0x12, 0x34, // stock_locate = 4660
        0x56, 0x7B, // tracking_number = 22139
        0x01, 0x02, 0x03, 0x04, 0x05, 0x09, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // order_reference_number = 1
        0x00, 0x00, 0x00, 0x64, // executed_shares = 100
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, // match_number = 1

        // 5. OrderExecutedwithPriceMessage - Execution with price (35 bytes)
        'C', // message_type = 'C'
        0x12, 0x35, // stock_locate = 4661
        0x56, 0x7C, // tracking_number = 22140
        0x01, 0x02, 0x03, 0x04, 0x05, 0x0A, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF1, // order_reference_number = 3
        0x00, 0x00, 0x00, 0x32, // executed_shares = 50
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, // match_number = 2
        'Y', // printable = 'Y' (Yes, printable)
        0x43, 0x47, 0x80, 0x00, // execution_price = 199.5

        // 6. OrderCancelMessage - Cancel part of remaining first order (22 bytes)
        'X', // message_type = 'X'
        0x12, 0x34, // stock_locate = 4660
        0x56, 0x7D, // tracking_number = 22141
        0x01, 0x02, 0x03, 0x04, 0x05, 0x0B, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // order_reference_number = 1
        0x00, 0x00, 0x00, 0x96, // cancelled_shares = 150

        // 7. OrderReplaceMessage - Replace second order with new price and quantity (34 bytes)
        'U', // message_type = 'U'
        0x12, 0x34, // stock_locate = 4660
        0x56, 0x7E, // tracking_number = 22142
        0x01, 0x02, 0x03, 0x04, 0x05, 0x0C, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF0, // original_order_reference_number = 2
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF2, // new_order_reference_number = 4
        0x00, 0x00, 0x01, 0xF4, // shares = 500 (increased quantity)
        0x42, 0xC9, 0x80, 0x00, // price = 100.75 (reduced price)

        // 8. AddOrderWithMPIDMessage - New order from different MPID (39 bytes)
        'F', // message_type = 'F'
        0x12, 0x36, // stock_locate = 4662
        0x56, 0x7F, // tracking_number = 22143
        0x01, 0x02, 0x03, 0x04, 0x05, 0x0D, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF3, // order_reference_number = 5
        'B', // buy_sell_indicator = 'B' (Buy)
        0x00, 0x00, 0x03, 0xE8, // shares = 1000
        'T', 'S', 'L', 'A', ' ', ' ', ' ', ' ', // stock = "TSLA    "
        0x43, 0x70, 0x00, 0x00, // price = 240.0
        'M', 'S', 'C', 'O', // attribution = "MSCO" (Morgan Stanley)

        // 9. OrderDeleteMessage - Delete remaining shares of third order (18 bytes)
        'D', // message_type = 'D'
        0x12, 0x35, // stock_locate = 4661
        0x56, 0x80, // tracking_number = 22144
        0x01, 0x02, 0x03, 0x04, 0x05, 0x0E, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF1, // order_reference_number = 3

        // 10. OrderExecutedMessage - Execute part of the Tesla order (30 bytes)
        'E', // message_type = 'E'
        0x12, 0x36, // stock_locate = 4662
        0x56, 0x81, // tracking_number = 22145
        0x01, 0x02, 0x03, 0x04, 0x05, 0x0F, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF3, // order_reference_number = 5
        0x00, 0x00, 0x01, 0x2C, // executed_shares = 300
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, // match_number = 3

        // 11. OrderCancelMessage - Cancel remaining Tesla order (22 bytes)
        'X', // message_type = 'X'
        0x12, 0x36, // stock_locate = 4662
        0x56, 0x82, // tracking_number = 22146
        0x01, 0x02, 0x03, 0x04, 0x05, 0x10, // timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xF3, // order_reference_number = 5
        0x00, 0x00, 0x02, 0xBC, // cancelled_shares = 700 (remaining shares)
    };

    // Create data directory if it doesn't exist
    std.fs.cwd().makeDir("./src/data") catch |err| switch (err) {
        error.PathAlreadyExists => {}, // Directory already exists, continue
        else => return err, // Other errors should be propagated
    };

    // Create file and write the message sequence
    const file = try std.fs.cwd().createFile("./src/data/ComprehensiveOrderBookOps", .{
        .truncate = true,
        .read = false,
    });
    defer file.close();

    var writer = file.writer();
    try writer.writeAll(&message_sequence);

    // Print summary of what was created
    std.debug.print("Created comprehensive order book operations test file with {} bytes\n", .{message_sequence.len});
}
