const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("./input", .{});
    const reader = file.reader();

    var elves = std.ArrayList(usize).init(allocator);
    defer elves.deinit();
    try elves.append(0);
    while (try readLineAlloc(allocator, reader, std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        if (line.len > 0) {
            const n = try std.fmt.parseInt(usize, line, 10);
            elves.items[elves.items.len - 1] += n;
        } else {
            try elves.append(0);
        }
    }

    var elves_slice = try elves.toOwnedSlice();
    defer allocator.free(elves_slice);
    std.sort.sort(usize, elves_slice, {}, comptime std.sort.desc(usize));

    std.debug.print("{}\n", .{elves_slice[0]});

    var top3sum: usize = 0;
    for (elves_slice[0..3]) |n| {
        top3sum += n;
    }

    std.debug.print("{}\n", .{top3sum});
}

fn readLineAlloc(allocator: std.mem.Allocator, reader: std.fs.File.Reader, max_size: usize) !?[]u8 {
    if (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', max_size)) |_line| {
        var line = if (_line.len > 0 and _line[_line.len - 1] == '\r')
            try allocator.realloc(_line, _line.len - 1)
        else
            _line;
        return line;
    } else {
        return null;
    }
}
