pub const now = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @import("linux.zig").rdtsc,
    .aarch64 => @import("mac.zig").rdtsc,
    else => @compileError("unsupported platform"),
};

pub fn delta(start: u64, end: u64) u64 {
    return end - start;
}
