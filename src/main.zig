const std = @import("std");
const parse = @import("parser/mod.zig");
const tsc = @import("tsc/mod.zig");
const structs = @import("parser/structs.zig");

pub fn main() !void {
    const CHUNK_SIZE: usize = 1024 * 1024;
    // const CHUNKS: usize = 39;

    var file = try std.fs.cwd().openFile("./src/data/ITCHMessage", .{});
    defer file.close();

    var buffer: [CHUNK_SIZE]u8 = undefined;

    const start = tsc.now();

    while (true) {
        const bytesRead = try file.read(buffer[0..]);
        if (bytesRead == 0) break;

        var slice = buffer[0..bytesRead];
        var offset: usize = 0;

        while (offset < bytesRead) {
            if (offset + 1 > bytesRead) {
                std.debug.print("Not enough data to read message type\n", .{});
                break;
            }

            if (!parse.isValidMessageType(slice[offset])) {
                std.debug.print("Invalid message type byte: {x}\n", .{slice[offset]});
                break;
            }

            const msg_size = 39; //parse.getMessageSize(slice[offset..]);
            if (offset + @as(usize, @intCast(msg_size)) > bytesRead) {
                std.debug.print("Incomplete message at end of chunk\n", .{});
                break;
            }

            const msg_slice = slice[offset .. offset + @as(usize, @intCast(msg_size))];
            _ = parse.parseITCHMessage(msg_slice);
            std.debug.print("sizeOf: {d}\n", .{@sizeOf(structs.StockDirectoryMessage)});

            std.debug.print("alignOf: {d}\n", .{@alignOf(structs.StockDirectoryMessage)});
            offset += @as(usize, @intCast(msg_size));
            break; 
        }
    }

    const end = tsc.now();
    std.debug.print("Cycles {d}\n", .{tsc.delta(start, end)});
}

