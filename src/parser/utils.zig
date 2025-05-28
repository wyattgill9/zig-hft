const std = @import("std");

pub fn readU8(bytes: []const u8, offset: usize) u8 {
    return bytes[offset];
}

pub fn readU16(bytes: []const u8, offset: usize) u16 {
    return std.mem.readInt(u16, bytes[offset..offset+2][0..2], .big);
}

pub fn readU32(bytes: []const u8, offset: usize) u32 {
    return std.mem.readInt(u32, bytes[offset..offset+4][0..4], .big);
}

pub fn readU48(bytes: []const u8, offset: usize) u48 {
    return std.mem.readInt(u48, bytes[offset..offset+6][0..6], .big);
}

pub fn readU64(bytes: []const u8, offset: usize) u64 {
    return std.mem.readInt(u64, bytes[offset..offset+8][0..8], .big);
}

pub fn readF8(bytes: []const u8, offset: usize) f16 {
    const raw = readU16(bytes, offset);
    return @as(f16, @bitCast(raw));
}

pub fn readF32(bytes: []const u8, offset: usize) f32 {
    const raw = readU32(bytes, offset);
    return @as(f32, @bitCast(raw));
}

pub fn readF64(bytes: []const u8, offset: usize) f64 {
    const raw = readU64(bytes, offset);
    return @as(f64, @bitCast(raw));
}

pub fn printMarketCategory(code: u8) []const u8 {
    return switch (code) {
        'Q' => "Nasdaq Global Select MarketSM",
        'G' => "Nasdaq Global MarketSM",
        'S' => "Nasdaq Capital Market®",
        'N' => "New York Stock Exchange (NYSE)",
        'A' => "NYSE American",
        'P' => "NYSE Arca",
        'Z' => "BATS Z Exchange",
        'V' => "Investors’ Exchange, LLC",
        ' ' => "Not available",
        else => "Unknown Market Category Code",
    };
}

pub fn printFinancialStatusIndicator(code: u8) []const u8 {
    return switch (code) {
        'D' => "Deficient",
        'E' => "Delinquent",
        'Q' => "Bankrupt",
        'S' => "Suspended",
        'G' => "Deficient and Bankrupt",
        'H' => "Deficient and Delinquent",
        'J' => "Delinquent and Bankrupt",
        'K' => "Deficient, Delinquent and Bankrupt",
        'C' => "Creations and/or Redemptions Suspended for ETP",
        'N' => "Normal (Default): Not Deficient, Delinquent, or Bankrupt",
        ' ' => "Not available. See SIAC feed if needed",
        else => "Unknown Financial Status Indicator",
    };
}

pub fn printTradingState(code: u8) []const u8 {
    return switch (code) {
        'H' => "Halted across all U.S. equity markets / SROs",
        'P' => "Paused across all U.S. equity markets / SROs (Nasdaq---listed securities only)",
        'Q' => "Quotation only period for cross-•-SRO halt or pause",
        'T' => "Trading on Nasdaq", 
        else => "Unknown Trading State Code",
    };
}

pub fn printRegSHOAction(code: u8) []const u8 {
    return switch (code) {
        '0' => "No price test in place",
        '1' => "Reg SHO Short Sale Price Test Restriction in effect due to an intra-day price drop in security",
        '2' => "Reg SHO Short Sale Price Test Restriction remains in effect",
        else => "Unknown RegSHOAction Code",
    };
}

pub fn printMarketMakerMode(code: u8) []const u8 {
    return switch (code) {
        'N' => "normal",
        'P' => "passive",
        'S' => "syndicate",
        'R' => "pre-syndicate",
        'L' => "penalty",
        else => "Unknown Market Maker Code",
    };
}

pub fn printMarketParticipantState(code: u8) []const u8 {
    return switch (code) {
        'A' => "Active",
        'E' => "Excused/Withdrawn",
        'W' => "Withdrawn",
        'S' => "Suspended",
        'D' => "Deleted",
        else => "Unknown Market Participant State Code",
    };
}
