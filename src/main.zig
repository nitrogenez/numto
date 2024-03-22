const std = @import("std");
const log = std.log.scoped(.numto);

const Mode = enum {
    hex,
    dec,
    bin,
    oct,
};

pub fn main() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(allocator.allocator());

    defer {
        arena.deinit();
        _ = allocator.deinit();
    }
    const gpa = allocator.allocator();
    const stdout = std.io.getStdOut().writer();

    var mode: ?Mode = null;
    var num: ?[]const u8 = null;
    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();

    _ = args.skip();

    while (args.next()) |arg| {
        if (arg[0] == '-') {
            mode = switch (arg[1]) {
                'h' => .hex,
                'b' => .bin,
                'o' => .oct,
                'd' => .dec,
                else => {
                    log.err("unknown type: {s}", .{arg[0..2]});
                    return;
                },
            };
        } else if (std.ascii.isDigit(arg[0])) {
            num = arg;
        } else {
            log.err("unknown argument: {s}", .{arg});
            return;
        }
    }

    if (num == null) {
        log.err("no input", .{});
        return;
    }

    const number: i64 = std.fmt.parseInt(i64, num.?, 0) catch |err| {
        log.err("{s}", .{@errorName(err)});
        return;
    };

    switch (mode.?) {
        .hex => try stdout.print("0x{x:.6}\n", .{number}),
        .oct => try stdout.print("{o}\n", .{number}),
        .dec => try stdout.print("{d}\n", .{number}),
        .bin => try stdout.print("{b}\n", .{number}),
    }
}
