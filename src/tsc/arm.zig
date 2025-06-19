// Run like 3 millions times in a second
const std = @import("std");

pub fn rdtsc() u64 {
    var count: u64 = 0;
    asm volatile ("mrs %[count], cntvct_el0"
        : [count] "=r" (count),
    );
    return count;
}
