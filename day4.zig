const std = @import("std");
const Allocator = std.mem.Allocator;

var card_matches: std.AutoHashMap(u64, u64) = undefined;
var card_total: std.AutoHashMap(u64, u64) = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const inputData = try std.fs.cwd().readFileAlloc(allocator, "data/day4.txt", 1e6);
    defer allocator.free(inputData);

    card_total = std.AutoHashMap(u64, u64).init(allocator);
    defer card_total.deinit();
    card_matches = std.AutoHashMap(u64, u64).init(allocator);
    defer card_matches.deinit();

    var solve_timer = try std.time.Timer.start();
    const result = try solve(allocator, inputData);
    std.debug.print("result: {d}, time taken: {d} us\n", .{ result, solve_timer.lap() / 1000 });
    const result2 = try solve2(allocator, inputData);
    std.debug.print("result2: {d}, time taken: {d} us\n", .{ result2, solve_timer.lap() / 1000 });
}

fn getCardMatches(allocator: Allocator, card: []const u8, index: u64) !u64 {
    var matches: u64 = 0;
    if (card_matches.get(index)) |m| {
        return m;
    } else {
        var card_parts = std.mem.splitAny(u8, card, ":|");
        _ = card_parts.first();
        const winning_numbers_str = card_parts.next().?;
        var winning_numbers_iter = std.mem.splitAny(u8, winning_numbers_str, " ");
        var winning_numbers = std.ArrayList(u64).init(allocator);
        defer winning_numbers.deinit();
        while (winning_numbers_iter.next()) |num_str| {
            if (num_str.len > 0) {
                const num_int = try std.fmt.parseInt(u64, num_str, 10);
                try winning_numbers.append(num_int);
            }
        }
        const card_numbers_str = card_parts.next().?;
        var card_numbers_iter = std.mem.split(u8, card_numbers_str, " ");

        while (card_numbers_iter.next()) |num_str| {
            if (num_str.len > 0) {
                const num_int = try std.fmt.parseInt(u8, num_str, 10);
                for (winning_numbers.items) |winning_num| {
                    if (num_int == winning_num) {
                        matches += 1;
                    }
                }
            }
        }
        try card_matches.put(index, matches);
    }
    return matches;
}

fn getTotalCards(allocator: Allocator, cards: std.ArrayList([]const u8), index: usize) !u64 {
    var total: u64 = 0;
    if (card_total.get(index)) |t| return t else {
        const matches = try getCardMatches(allocator, cards.items[index], index);
        total += matches;
        for (index + 1..index + @as(usize, @intCast(matches)) + 1) |i| {
            total += try getTotalCards(allocator, cards, i);
        }
    }
    try card_total.put(index, total);
    return total;
}

fn solve(allocator: Allocator, input: []const u8) !u64 {
    var points: u64 = 0;
    var lines = std.mem.splitScalar(u8, input, '\n');

    var i: u64 = 0;
    while (lines.next()) |line| : (i += 1) {
        if (line.len > 0) {
            const matches = try getCardMatches(allocator, line, i);
            if (matches > 0) points += std.math.pow(u64, 2, matches - 1);
        }
    }
    return points;
}

fn solve2(allocator: Allocator, input: []const u8) !u64 {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();
    while (lines_iter.next()) |line| {
        try lines.append(line);
    }

    var cards: u64 = 0;
    for (0..lines.items.len) |i| {
        if (lines.items[i].len > 0) {
            std.debug.print("getting total for card: {d}\n", .{i});
            cards += 1;
            cards += try getTotalCards(allocator, lines, i);
        }
    }
    return cards;
}

test "card point value" {
    card_matches = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer card_matches.deinit();
    const res = try getCardMatches(std.testing.allocator, "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", 0);
    try std.testing.expect(res == 4);
}

test "solve" {
    card_matches = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer card_matches.deinit();
    card_total = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer card_total.deinit();
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day4test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    try std.testing.expect(try solve(std.testing.allocator, inputData) == 13);
}

test "solve2" {
    card_total = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer card_total.deinit();
    card_matches = std.AutoHashMap(u64, u64).init(std.testing.allocator);
    defer card_matches.deinit();
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day4test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    try std.testing.expectEqual(30, try solve2(std.testing.allocator, inputData));
}
