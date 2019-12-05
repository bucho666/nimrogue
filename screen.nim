import
  tables,
  coord,
  console,
  entity,
  strformat,
  symbol

# Messages
type Messages = ref object
  messages: seq[string]

proc newMessages(max: uint=4): Messages =
  result = Messages()
  for i in 0 ..< max:
    result.messages.add("")

proc add(self: Messages, message: string) =
  self.messages.insert(message, 0)
  discard self.messages.pop

iterator pairs(self: Messages): (int, string)=
  for n, message in self.messages:
    yield (n, message)

# Screen
type Screen* = ref object
  hero: Hero
  messages: Messages
  map_tile: Table[Coord, Symbol]

proc newScreen*(hero: Hero): Screen =
  Screen(
    hero: hero,
    messages: newMessages(4),
  )
proc update_map*(self: Screen, coord: Coord, symbol: Symbol) =
  self.map_tile[coord] = symbol

proc add_message*(self: Screen, message: string) =
  self.messages.add(message)

proc render*(self: Screen, console: Console) =
  discard console.erase
  for coord, symbol in self.map_tile:
    console.print(coord, $symbol.glyph, symbol.color)
  for i, message in self.messages:
    console.print((0, 24 + i), message)
  console.print((0, 23), fmt"level: {self.hero.floor}")
  console.flush
  self.map_tile.clear
