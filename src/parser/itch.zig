const std = @import("std");

pub const ITCHMessage = packed struct {
    message_type: u8, // instead of c_char 
    timestamp: u64,
    order_reference_num: u32,
    transaction_id: u32,
    order_book_id: u32,
    side: u8,
    quantity: u32,
    price: f64,
    yield_: f32,
  
    pub fn init() ITCHMessage {
        return ITCHMessage{
            .message_type = ' ', 
            .timestamp = 0, 
            .order_reference_num = 0, 
            .transaction_id = 0, 
            .order_book_id = 0, 
            .side = ' ', 
            .quantity = 0, 
            .price = 0.0,
            .yield_ = 0.0
        };
    }

    pub fn initWithValues(
        message_type: u8,
        timestamp: u64,
        order_reference_num: u32,
        transaction_id: u32,
        order_book_id: u32,
        side: u8,
        quantity: u32,
        price: f64,
        yield_: f32,
    ) ITCHMessage {
        return ITCHMessage{
            .message_type = message_type,
            .timestamp = timestamp,
            .order_reference_num = order_reference_num,
            .transaction_id = transaction_id,
            .order_book_id = order_book_id,
            .side = side,
            .quantity = quantity,
            .price = price,
            .yield_ = yield_,
        };
    }

    pub fn getMessageType(self: ITCHMessage) u8 {
        return self.message_type;        
    }

    pub fn getTimestamp(self: ITCHMessage) u64 {
        return self.timestamp;
    }

    pub fn getOrderReferenceNum(self: ITCHMessage) u32 {
        return self.order_reference_num;
    }

    pub fn getTransactionId(self: ITCHMessage) u32 {
        return self.transaction_id;
    }

    pub fn getOrderBookId(self: ITCHMessage) u32 {
        return self.order_book_id;
    }

    pub fn getSide(self: ITCHMessage) u8 {
        return self.side;
    }

    pub fn getQuantity(self: ITCHMessage) u32 {
        return self.quantity;
    }

    pub fn getPrice(self: ITCHMessage) f64 {
        return self.price;
    }

    pub fn getYield(self: ITCHMessage) f32 {
        return self.yield_;
    }

    pub fn printInfo(self: ITCHMessage) void {
        std.debug.print("ITCHMessage {{\n", .{});
        std.debug.print("   message_type        = {c}\n", .{self.message_type});
        std.debug.print("   timestamp           = {d}\n", .{self.timestamp});
        std.debug.print("   order_reference_num = {d}\n", .{self.order_reference_num});
        std.debug.print("   transaction_id      = {d}\n", .{self.transaction_id});
        std.debug.print("   order_book_id       = {d}\n", .{self.order_book_id});
        std.debug.print("   side                = {c}\n", .{self.side});
        std.debug.print("   quantity            = {d}\n", .{self.quantity});
        std.debug.print("   price               = {d:.2}\n", .{self.price});
        std.debug.print("   yield_              = {d:.2}\n", .{self.yield_});
        std.debug.print("}}\n\n", .{});
    }
};

fn readU8(bytes: []const u8, offset: usize) u8 {
    return bytes[offset];
}

fn readU32(bytes: []const u8, offset: usize) u32 {
    return (@as(u32, @intCast(bytes[offset])) << 24) |
           (@as(u32, @intCast(bytes[offset + 1])) << 16) |
           (@as(u32, @intCast(bytes[offset + 2])) << 8)  |
           (@as(u32, @intCast(bytes[offset + 3])));
}

fn readU64(bytes: []const u8, offset: usize) u64 {
    return (@as(u64, @intCast(bytes[offset])) << 56) |
           (@as(u64, @intCast(bytes[offset + 1])) << 48) |
           (@as(u64, @intCast(bytes[offset + 2])) << 40) |
           (@as(u64, @intCast(bytes[offset + 3])) << 32) |
           (@as(u64, @intCast(bytes[offset + 4])) << 24) |
           (@as(u64, @intCast(bytes[offset + 5])) << 16) |
           (@as(u64, @intCast(bytes[offset + 6])) << 8)  |
           (@as(u64, @intCast(bytes[offset + 7])));
}

fn readF64(bytes: []const u8, offset: usize) f64 {
    const raw = readU64(bytes, offset);
    return @as(f64, @bitCast(raw));
}

fn readF32(bytes: []const u8, offset: usize) f32 {
    const raw = readU32(bytes, offset);
    return @as(f32, @bitCast(raw));
}

pub fn parseITCHMessage(bytes: []const u8) ITCHMessage {
    return ITCHMessage.initWithValues(
        readU8(bytes, 0),       // message_type
        readU64(bytes, 1),      // timestamp
        readU32(bytes, 9),      // order_reference_num
        readU32(bytes, 13),     // transaction_id
        readU32(bytes, 17),     // order_book_id
        readU8(bytes, 21),      // side
        readU32(bytes, 22),     // quantity
        readF64(bytes, 26),     // price
        readF32(bytes, 34),     // yield
    );
}
