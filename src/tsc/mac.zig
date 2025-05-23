const std = @import("std");

pub fn rdtsc() u64 {
    const timestamp = std.time.nanoTimestamp();
    if (timestamp < 0 or timestamp > std.math.maxInt(u64)) {
        @panic("Timestamp out of range for u64");
    }
    return @intCast(timestamp);
}
