const std = @import("std");
const Allocator = std.mem.Allocator;

const Number = struct { x: usize, y: usize, xspan: usize, num: u64, symbol: u8 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const result = try solve(allocator, "data/day3.txt");
    std.debug.print("answer: {d}\n", .{result});
}

fn solve(allocator: Allocator, filepath: []const u8) !u64 {
    var sum: u64 = 0;
    const inputData = try std.fs.cwd().readFileAlloc(allocator, filepath, 1e6);
    defer allocator.free(inputData);
    const inputMatrix = try getMatrix(allocator, inputData);
    defer inputMatrix.deinit();
    const numbers = try findNumbers(allocator, inputMatrix);
    defer numbers.deinit();
    for (numbers.items) |*number| {
        if (try isTouchingSymbol(number, inputMatrix)) {
            sum += number.num;
        }
    }
    return sum;
}

fn getMatrix(allocator: Allocator, inputData: []const u8) !std.ArrayList([]const u8) {
    var inputLines = std.mem.splitScalar(u8, inputData, '\n');
    var inputMatrix = std.ArrayList([]const u8).init(allocator);
    while (inputLines.next()) |line| {
        if (line.len > 0)
            try inputMatrix.append(line);
    }
    return inputMatrix;
}

fn findNumbers(allocator: Allocator, inputMatrix: std.ArrayList([]const u8)) !std.ArrayList(Number) {
    var numbers = std.ArrayList(Number).init(allocator);
    var num: Number = undefined;
    var midNumber: bool = false;
    const input = inputMatrix.items;
    for (input, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (std.ascii.isDigit(char)) {
                if (!midNumber) {
                    midNumber = true;
                    num.x = j;
                    num.y = i;
                    num.xspan = 1;
                } else {
                    num.xspan += 1;
                    if (j == line.len - 1) {
                        num.num = try std.fmt.parseInt(u64, line[num.x..(num.x + num.xspan)], 0);
                        try numbers.append(num);
                        midNumber = false;
                    }
                }
            } else {
                if (midNumber) {
                    num.num = std.fmt.parseInt(u64, line[num.x..(num.x + num.xspan)], 0) catch |e| switch (e) {
                        std.fmt.ParseIntError.InvalidCharacter => {
                            std.debug.print("Couldn't parse integer: {s}, xpos: {d}, ypos: {d}.\n Line: {s}", .{ line[num.x..(num.x + num.xspan)], num.x, num.y, line });
                            return e;
                        },
                        std.fmt.ParseIntError.Overflow => {
                            std.debug.print("Integer overflow on type.", .{});
                            return e;
                        },
                    };

                    try numbers.append(num);
                    midNumber = false;
                }
            }
        }
    }
    return numbers;
}

fn isTouchingSymbol(number: *Number, inputMatrix: std.ArrayList([]const u8)) !bool {
    const miny: usize = if (@as(isize, @intCast(number.y)) - 1 < 0) 0 else number.y - 1;
    const maxy: usize = if (number.y + 2 >= inputMatrix.items.len) (inputMatrix.items.len) else number.y + 2;
    for (inputMatrix.items[miny..maxy]) |line| {
        const minx: usize = if (@as(isize, @intCast(number.x)) - 1 < 0) 0 else number.x - 1;
        const maxx: usize = if (number.x + number.xspan + 1 >= line.len) (line.len) else number.x + number.xspan + 1;
        for (line[minx..maxx]) |char| {
            if (!std.ascii.isDigit(char) and (char != '.')) {
                number.symbol = char;
                return true;
            }
        }
    }
    return false;
}

test "get input matrix" {
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day3test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    const inputMatrix = try getMatrix(std.testing.allocator, inputData);
    defer inputMatrix.deinit();
    try std.testing.expect(inputMatrix.items[1][3] == '*');
}

test "get first nums" {
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day3test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    const inputMatrix = try getMatrix(std.testing.allocator, inputData);
    defer inputMatrix.deinit();
    const numbers = try findNumbers(std.testing.allocator, inputMatrix);
    defer numbers.deinit();
    try std.testing.expect(numbers.items[0].num == 467);
    try std.testing.expect(numbers.items[0].xspan == 3);
}

test "get num symbol" {
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day3test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    const inputMatrix = try getMatrix(std.testing.allocator, inputData);
    defer inputMatrix.deinit();
    var numbers = try findNumbers(std.testing.allocator, inputMatrix);
    defer numbers.deinit();
    try std.testing.expect(try isTouchingSymbol(&numbers.items[0], inputMatrix));
    try std.testing.expect(numbers.items[0].symbol == '*');
}

test "solve" {
    const result = try solve(std.testing.allocator, "data/day3test.txt");
    try std.testing.expect(result == 4361);
}

//answer 532428
