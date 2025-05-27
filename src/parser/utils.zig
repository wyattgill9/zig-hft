const std = @import("std");

fn readU8(bytes: []const u8, offset: usize) u8 {
    return bytes[offset];
}

fn readU16(bytes: []const u8, offset: usize) u16 {
    return std.mem.readInt(u16, bytes[offset..offset+2][0..2], .big);
}

fn readU32(bytes: []const u8, offset: usize) u32 {
    return std.mem.readInt(u32, bytes[offset..offset+4][0..4], .big);
}

fn readU48(bytes: []const u8, offset: usize) u48 {
    return std.mem.readInt(u48, bytes[offset..offset+6][0..6], .big);
}

fn readU64(bytes: []const u8, offset: usize) u64 {
    return std.mem.readInt(u64, bytes[offset..offset+8][0..8], .big);
}

fn readF8(bytes: []const u8, offset: usize) f16 {
    const raw = readU16(bytes, offset);
    return @as(f16, @bitCast(raw));
}

fn readF32(bytes: []const u8, offset: usize) f32 {
    const raw = readU32(bytes, offset);
    return @as(f32, @bitCast(raw));
}

fn readF64(bytes: []const u8, offset: usize) f64 {
    const raw = readU64(bytes, offset);
    return @as(f64, @bitCast(raw));
}

fn printGenericInfo(self: anytype) void {
    const T = @TypeOf(self);
    const info = @typeInfo(T);
    std.debug.print("{} {\n", .{ @typeName(T) });

    if (info != null and info.* == .Struct) {
        const s = info.Struct;
        inline for (s.fields) |field| {
            const field_name = field.name;
            const field_value = @field(self, field_name);
            std.debug.print("  {s} = {any}\n", .{ field_name, field_value });
        }
    } else {
        std.debug.print("  <non-struct type, cannot print fields>\n", .{});
    }

    std.debug.print("}\n", .{});
}
