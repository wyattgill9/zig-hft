const std = @import("std");
const tsc = @import("tsc/mod.zig");
const parse = @import("parser/mod.zig");

pub fn main() !void {
    // const data = [CHUNK_SIZE]u8{ // Example ITCH message
    //     0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    //     0x00, 0x00, 0x00, 0x03, 0xea, 0x00, 0x00, 0x00,
    //     0x00, 0x00, 0x05, 0x00, 0xcd, 0x42, 0x00, 0x00,
    //     0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    //     0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
    // };

    const CHUNK_SIZE: u32 = 38; 

    var file = try std.fs.cwd().openFile("./src/data/ITCHMessage", .{});
    defer file.close();

    var buffer: [CHUNK_SIZE]u8 = undefined;

    while (true) {
        const bytesRead = try file.read(buffer[0..]);
        if (bytesRead == 0) break;

        if (bytesRead != CHUNK_SIZE) {
            std.debug.print("Error: Expected {d} bytes, received {d}\n", .{ CHUNK_SIZE, bytesRead });
            break;
        }

        const message = parse.itch.parseITCHMessage(buffer[0..]);
        message.printInfo();
    }
}
