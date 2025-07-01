const std = @import("std");

pub fn main() !void {
    const message_sequence = [_]u8{
        // AddOrderNoMPIDMessage (36 bytes)
        'A', // 1 byte: message_type = 'A'
        0x12, 0x34, // 2 bytes: stock_locate = 4660
        0x56, 0x78, // 2 bytes: tracking_number = 22136
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // 6 bytes: timestamp
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // 8 bytes: order_reference_number
        'B', // 1 byte: buy_sell_indicator = 'B' (Buy)
        0x00, 0x00, 0x01, 0x2C, // 4 bytes: shares = 300 (big-endian)
        'A', 'A', 'P', 'L', ' ', ' ', ' ', ' ', // 8 bytes: stock = "AAPL    "
        0x42, 0xC8, 0x00, 0x00, // 4 bytes: price = 100.0 (big-endian float)

        // OrderCancelMessage (23 bytes)
        'X', // message_type = 'X'
        0x12, 0x34, // stock_locate = 4660 (same as add order)
        0x56, 0x79, // tracking_number = 22137 (incremented)
        0x01, 0x02, 0x03, 0x04, 0x05, 0x07, // timestamp (slightly later)
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, // order_reference_number (same as add order)
        0x00, 0x00, 0x00, 0x96, // cancelled_shares = 150 (big-endian)
    };

    // Create data directory if it doesn't exist
    std.fs.cwd().makeDir("data") catch |err| switch (err) {
        error.PathAlreadyExists => {}, // Directory already exists, continue
        else => return err, // Other errors should be propagated
    };

    // Create file and write the message sequence
    const file = try std.fs.cwd().createFile("./data/AddOrderAndCancel", .{
        .truncate = true,
        .read = false,
    });

    defer file.close();

    var writer = file.writer();
    try writer.writeAll(&message_sequence);

}
