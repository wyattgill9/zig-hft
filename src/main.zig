const std = @import("std");
const tsc = @import("tsc/mod.zig");
const parse = @import("parser/mod.zig");

pub fn main() !void {
    const CHUNK_SIZE: u32 = 39; 

    var file = try std.fs.cwd().openFile("./src/data/ITCHMessage", .{});
    defer file.close();

    var buffer: [CHUNK_SIZE]u8 = undefined;
   
    const start = tsc.now();

    while (true) {
        const bytesRead = try file.read(buffer[0..]);
        if (bytesRead == 0) break;

        if (bytesRead != CHUNK_SIZE) {
            std.debug.print("Error: Expected {d} bytes, received {d}\n", .{ CHUNK_SIZE, bytesRead });
            break;
        }

        const message = parse.parseITCHMessage(buffer[0..]);
        message.printInfo();
    }

    const end = tsc.now();
    std.debug.print("Cycles {d}\n", .{tsc.delta(start, end)});
}
