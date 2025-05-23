pub fn rdtsc() u64 {
    var low: u32 = 0;
    var high: u32 = 0;
    asm volatile ("rdtsc"
        : [low] "=a" (low),
          [high] "=d" (high)
    );
    return (@as(u64, high) << 32) | @as(u64, low);
}
