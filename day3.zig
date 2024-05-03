const std = @import("std");
const Allocator = std.mem.Allocator;
const testInput =
    \\467..114..
    \\...*......
    \\..35..633.
    \\......#...
    \\617*......
    \\.....+.58.
    \\..592.....
    \\......755.
    \\...$.*....
    \\.664.598..
;

const Point = struct { x: usize, y: usize };

pub fn main() void {}

fn findSymbols(allocator: Allocator, schematic: []const u8) !std.ArrayList(Point) {
    var lines = std.mem.splitScalar(u8, schematic, '\n');
    var symbols = std.ArrayList(Point).init(allocator);
    var i: u32 = 0;
    while (lines.next()) |row| : (i += 1) {
        for (row, 0..) |char, col| {
            if (!std.ascii.isDigit(char) and char != '.') {
                try symbols.append(Point{ .x = i, .y = col });
            }
        }
    }
    return symbols;
}

test "find symbols basic" {
    const symlist = try findSymbols(std.testing.allocator, "...*....\n....*...");
    defer symlist.deinit();
    try std.testing.expect(symlist.items[0].x == 0);
    try std.testing.expect(symlist.items[0].y == 3);
    try std.testing.expect(symlist.items[1].x == 1);
    try std.testing.expect(symlist.items[1].y == 4);
}

test "find symbols test input" {
    const symlist = try findSymbols(std.testing.allocator, testInput);
    defer symlist.deinit();
    try std.testing.expect(symlist.items[0].x == 1 and symlist.items[0].y == 3);
    try std.testing.expect(symlist.items[1].x == 3 and symlist.items[1].y == 6);
}
