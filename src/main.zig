const std = @import("std");
const log = std.log.scoped(.numto);

const Mode = enum {
    hex,
    dec,
    bin,
    oct,
};

const help =
    \\usage: numto [FLAG] [NUMBER]
    \\
    \\Copyright (c) 2024 Andrij Glyko. All Rights Reserved.
    \\
    \\This software is licensed under BSD-3-clause license:
    \\  https://opensource.org/license/BSD-3-clause
    \\
    \\Represent numbers in different systems
    \\
    \\Valid flags:
    \\  -h      Represent NUMBER in hexadecimal
    \\  -d      Represent NUMBER in decimal
    \\  -b      Represent NUMBER in binary
    \\  -o      Represent NUMBER in octal
    \\  --help  Print this message and exit
    \\  --max   Print max value for a 64-bit integer and exit
;

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
        if (arg.len > 2) {
            if (arg[0] == '-' and arg[1] == '-') {
                switch (arg[2]) {
                    'h' => {
                        try stdout.print("{s}\n", .{help});
                        return;
                    },
                    'm' => {
                        const max = std.math.maxInt(i64);
                        try stdout.print("dec: {d}\nhex: 0x{x}\noct: {o}\nbin: {b}\n", .{ max, max, max, max });
                        return;
                    },
                    else => {
                        log.err("unknown flag: {s}", .{arg});
                        return;
                    },
                }
            }
        }
        if (arg[0] == '-') {
            mode = switch (arg[1]) {
                'h' => .hex,
                'b' => .bin,
                'o' => .oct,
                'd' => .dec,
                else => {
                    log.err("unknown flag: {s}", .{arg[0..2]});
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
