const std = @import("std");
const testData = "two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen";

const digitWords = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const data = try std.fs.cwd().readFileAlloc(allocator, "data/day1.txt", 1e5);

    const sum = solve(data);
    std.debug.print("{d}", .{sum});
}

fn solve(data: []const u8) u32 {
    var sum: u32 = 0;
    var lines = std.mem.splitSequence(u8, data, "\n");
    while (lines.next()) |line| {
        sum += getFirstDigit(line).? * 10 + getLastDigit(line).?;
    }
    return sum;
}

fn getFirstDigit(line: []const u8) ?u8 {
    var i: u64 = 0;
    while (i < line.len) : (i += 1) {
        if (charToDigit(line[i])) |value| {
            return value;
        } else {
            for (digitWords, 0..) |word, idx| {
                if (std.mem.startsWith(u8, line[i..], word)) {
                    return @intCast(idx);
                }
            }
        }
    }
    return null;
}
fn getLastDigit(line: []const u8) ?u8 {
    var i: u64 = line.len - 1;
    while (i >= 0) : (i -= 1) {
        if (charToDigit(line[i])) |value| {
            return value;
        } else {
            for (digitWords, 0..) |word, idx| {
                if (std.mem.startsWith(u8, line[i..], word)) {
                    return @intCast(idx);
                }
            }
        }
    }
    return null;
}

fn charToDigit(char: u8) ?u8 {
    if (std.ascii.isDigit(char))
        return char - '0'
    else
        return null;
}

test "char to digit" {
    try std.testing.expect(charToDigit('5') == 5);
}

test "charn't to digit" {
    try std.testing.expect(charToDigit('b') == null);
}

test "first digit" {
    try std.testing.expect(getFirstDigit("hello1als") == 1);
}

test "last digit" {
    try std.testing.expect(getLastDigit("hello1als2aas") == 2);
}

test "first digit word" {
    try std.testing.expect(getFirstDigit("one21two") == 1);
}

test "last digit word" {
    try std.testing.expect(getLastDigit("one21four") == 4);
}

test "solve" {
    try std.testing.expect(solve(testData) == 281);
}
