const std = @import("std");

const testInput =
    \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const data = try std.fs.cwd().readFileAlloc(allocator, "data/day2.txt", 5e4);

    const sum = try solve(data);
    std.debug.print("{d}\n", .{sum});
}

const Game = struct { maxGreen: u16 = 0, maxBlue: u16 = 0, maxRed: u16 = 0, index: u16 = 0 };

const maxBlocks: Game = .{ .maxRed = 12, .maxGreen = 13, .maxBlue = 14 };

fn parseGame(game: []const u8) !Game {
    var gameData: Game = .{};

    var gameString = std.mem.splitSequence(u8, game, ": ");

    const idxString = gameString.first()[5..];
    gameData.index = try std.fmt.parseInt(u16, idxString, 0);

    var gamesIter = std.mem.splitSequence(u8, gameString.rest(), "; ");
    while (gamesIter.next()) |handful| {
        var handfulIter = std.mem.splitSequence(u8, handful, ", ");

        while (handfulIter.next()) |colourString| {
            var colourIter = std.mem.splitSequence(u8, colourString, " ");
            const num = colourIter.first();
            const colour = colourIter.rest();

            if (std.mem.count(u8, colour, "red") > 0) {
                gameData.maxRed = @max(gameData.maxRed, try std.fmt.parseInt(u8, num, 0));
            } else if (std.mem.count(u8, colour, "green") > 0) {
                gameData.maxGreen = @max(gameData.maxGreen, try std.fmt.parseInt(u8, num, 0));
            } else if (std.mem.count(u8, colour, "blue") > 0) {
                gameData.maxBlue = @max(gameData.maxBlue, try std.fmt.parseInt(u8, num, 0));
            }
        }
    }

    return gameData;
}

fn isGameValid(game: Game) bool {
    return (game.maxRed <= maxBlocks.maxRed and game.maxGreen <= maxBlocks.maxGreen and game.maxBlue <= maxBlocks.maxBlue);
}

fn gamePower(game: Game) u32 {
    return game.maxRed * game.maxBlue * game.maxGreen;
}

fn solve(games: []const u8) !u32 {
    var power_sum: u32 = 0;
    var valid_sum: u32 = 0;
    var gameIter = std.mem.splitSequence(u8, games, "\n");
    while (gameIter.next()) |game| {
        const gameData: Game = try parseGame(game);
        power_sum += gamePower(gameData);
        if (isGameValid(gameData)) valid_sum += gameData.index;
    }
    return power_sum;
}

test "get game index" {
    const game: Game = try parseGame("Game 22: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green");
    try std.testing.expect(game.index == 22);
    try std.testing.expect(game.maxBlue == 6);
    try std.testing.expect(game.maxRed == 4);
    try std.testing.expect(game.maxGreen == 2);
}

test "solve test" {
    const sum = try solve(testInput);
    try std.testing.expect(sum == 8);
}
