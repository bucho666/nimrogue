import entity/[coord, tile]

type
  Console* = ref object of RootObj
  Color* {.pure.} = enum
    Default
    Black
    Red
    Green
    Yellow
    Blue
    Magenta
    Cyan
    White

method cleanup*(self: Console) {.base.} = discard
method erase*(self: Console): Console{.base.} = discard
method move*(self: Console, coord: Coord): Console {.base.} = discard
method print*(self: Console, coord: Coord, str: string, fg: Color = Color.Default): Console {.discardable base.} = discard
method print*(self: Console, coord: Coord, tile: Tile): Console {.discardable base.} = discard
method flush*(self: Console) {.base.} = discard
method inputKey*(self: Console, timeout: int = -1): char {.base.} = discard
