import tables, nimbox, app/console, app/entity/[coord, tile]
export nimbox.Color

const colorTable = {
  console.Color.Default: clrDefault,
  console.Color.Black: clrBlack,
  console.Color.Red: clrRed,
  console.Color.Green: clrGreen,
  console.Color.Yellow: clrYellow,
  console.Color.Blue: clrBlue,
  console.Color.Magenta: clrMagenta,
  console.Color.Cyan: clrCyan,
  console.Color.White: clrWhite
}.toTable

const tileTable = {
  Tile.Blank: (" ", clrDefault),
  Tile.Hero:  ("@", clrWhite),
  Tile.Wall: ("#", clrDefault),
  Tile.Floor: (".", clrGreen),
  Tile.Passage: (".", clrDefault),
  Tile.Door: ("+", clrYellow),
  Tile.DownStairs: (">", clrWhite),
  Tile.Gold: ("$", clrYellow),
  Tile.Bat: ("b", clrYellow)
}.toTable

type NimBoxConsole* = ref object of Console
  nb: Nimbox

proc newNimBoxConsole*(): NimBoxConsole =
  NimBoxConsole(nb: newNimbox())

method cleanup*(self: NimBoxConsole) =
  self.nb.shutdown()

method erase*(self: NimBoxConsole): Console =
  self.nb.clear
  self

method move*(self: NimBoxConsole, coord: Coord): Console =
  self.nb.cursor = coord
  self

method print*(self: NimBoxConsole, coord: Coord, str: string, fg: console.Color = console.Color.Default): Console {.discardable.} =
  self.nb.print(coord.x, coord.y, str, colorTable[fg])
  self

method print*(self: NimBoxConsole, coord: Coord, tile: Tile): Console  =
  let (glyph, color) = tileTable[tile]
  self.nb.print(coord.x, coord.y, glyph, color)
  self

method flush*(self: NimBoxConsole) =
  self.nb.present

method inputKey*(self: NimBoxConsole, timeout: int = -1): char =
  let event = if timeout == -1:
    self.nb.pollEvent
  else:
    self.nb.peekEvent(timeout)
  if event.kind == EventType.Key: event.ch else: '\0'
