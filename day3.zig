const std = @import("std");
const Allocator = std.mem.Allocator;

const Symbol = struct { x: usize, y: usize, sym: u8, nums: std.ArrayList(u64) = undefined };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var result = try solve(allocator, "data/day3.txt");
    std.debug.print("answer part 1: {d}\n", .{result});
    result = try solve2(allocator, "data/day3.txt");
    std.debug.print("answer part 2: {d}\n", .{result});
}

fn solve(allocator: Allocator, filepath: []const u8) !u64 {
    var sum: u64 = 0;
    const inputData = try std.fs.cwd().readFileAlloc(allocator, filepath, 1e6);
    defer allocator.free(inputData);
    const inputMatrix = try getMatrix(allocator, inputData);
    defer inputMatrix.deinit();
    const syms = try findSymbols(allocator, inputMatrix);
    for (syms.items) |symbol| {
        if (symbol.nums.items.len > 0) {
            for (symbol.nums.items) |num| sum += num;
        }
    }
    for (syms.items) |item| item.nums.deinit();
    syms.deinit();
    return sum;
}

fn solve2(allocator: Allocator, filepath: []const u8) !u64 {
    var sum: u64 = 0;
    const inputData = try std.fs.cwd().readFileAlloc(allocator, filepath, 1e6);
    defer allocator.free(inputData);
    const inputMatrix = try getMatrix(allocator, inputData);
    defer inputMatrix.deinit();
    const syms = try findSymbols(allocator, inputMatrix);
    for (syms.items) |symbol| {
        if (symbol.nums.items.len == 2 and symbol.sym == '*') {
            var ratio: u64 = 1;
            for (symbol.nums.items) |num| ratio *= num;
            sum += ratio;
        }
    }
    for (syms.items) |item| item.nums.deinit();
    syms.deinit();
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

fn findSymbols(allocator: Allocator, inputMatrix: std.ArrayList([]const u8)) !std.ArrayList(Symbol) {
    var symbols = std.ArrayList(Symbol).init(allocator);
    var i: usize = 0;

    while (i < inputMatrix.items.len) : (i += 1) {
        var j: usize = 0;
        const line = inputMatrix.items[i];

        while (j < line.len) : (j += 1) {
            const char = line[j];
            if (std.ascii.isDigit(char) or char == '.') continue;

            var sym: Symbol = .{ .x = j, .y = i, .sym = char };
            try findNumsAroundSym(allocator, &sym, inputMatrix);
            try symbols.append(sym);
        }
    }
    return symbols;
}

fn findNumsAroundSym(allocator: Allocator, sym: *Symbol, inputMatrix: std.ArrayList([]const u8)) !void {
    sym.nums = std.ArrayList(u64).init(allocator);
    if (sym.y != 0) {
        if (!(try checkForNumAndParse(inputMatrix.items[sym.y - 1], sym, sym.x))) {
            _ = try checkForNumAndParse(inputMatrix.items[sym.y - 1], sym, sym.x - 1);
            _ = try checkForNumAndParse(inputMatrix.items[sym.y - 1], sym, sym.x + 1);
        }
    }
    _ = try checkForNumAndParse(inputMatrix.items[sym.y], sym, sym.x - 1);
    _ = try checkForNumAndParse(inputMatrix.items[sym.y], sym, sym.x + 1);
    if (sym.y != inputMatrix.items.len) {
        if (!(try checkForNumAndParse(inputMatrix.items[sym.y + 1], sym, sym.x))) {
            _ = try checkForNumAndParse(inputMatrix.items[sym.y + 1], sym, sym.x - 1);
            _ = try checkForNumAndParse(inputMatrix.items[sym.y + 1], sym, sym.x + 1);
        }
    }
}

fn checkForNumAndParse(line: []const u8, sym: *Symbol, offset: usize) !bool {
    var start: usize = undefined;
    var end: usize = undefined;
    var index: usize = offset;
    if (std.ascii.isDigit(line[index])) {
        start = while (std.ascii.isDigit(line[index])) : (index -= 1) {
            if (index == 0) break 0;
        } else index + 1;
        index = offset;
        end = while (std.ascii.isDigit(line[index])) : (index += 1) {
            if (index == line.len - 1) break line.len;
        } else index;
        const num = try std.fmt.parseInt(u64, line[start..end], 0);
        try sym.nums.append(num);
        return true;
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

test "find symbols" {
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day3test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    const inputMatrix = try getMatrix(std.testing.allocator, inputData);
    defer inputMatrix.deinit();
    const syms = try findSymbols(std.testing.allocator, inputMatrix);
    try std.testing.expect(syms.items[0].sym == '*' and syms.items[0].x == 3 and syms.items[0].y == 1);
    for (syms.items) |item| item.nums.deinit();
    syms.deinit();
}

test "find nums around sym" {
    const inputData = try std.fs.cwd().readFileAlloc(std.testing.allocator, "data/day3test.txt", 1e3);
    defer std.testing.allocator.free(inputData);
    const inputMatrix = try getMatrix(std.testing.allocator, inputData);
    defer inputMatrix.deinit();
    const syms = try findSymbols(std.testing.allocator, inputMatrix);
    // try findNumsAroundSym(std.testing.allocator, syms[0], inputMatrix);
    try std.testing.expect(syms.items[0].nums.items.len == 2);
    try std.testing.expect(syms.items[0].nums.items[0] == 467);
    for (syms.items) |item| item.nums.deinit();
    syms.deinit();
}

test "solve" {
    const result = try solve(std.testing.allocator, "data/day3test.txt");
    try std.testing.expect(result == 4361);
}

test "solve2" {
    const result = try solve2(std.testing.allocator, "data/day3test.txt");
    try std.testing.expect(result == 467835);
}

//answer 532428
