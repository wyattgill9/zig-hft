pub const now = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @import("x86.zig").rdtsc,
    .aarch64 => @import("arm.zig").rdtsc,
    else => @compileError("unsupported platform"),
};

pub fn delta(comptime T: type, start: T, end: T) u64 {
    return @as(u64, @intCast(end - start));
}
