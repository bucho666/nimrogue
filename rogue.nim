import
  nimbox,
  tables,
  random

# Constant
const
  dirN* = (0, -1)
  dirE* = (1,  0)
  dirS* = (0,  1)
  dirW* = (-1, 0)
  dirNE* = (1, -1)
  dirSE* = (1, 1)
  dirSW* = (-1, 1)
  dirNW* = (-1, -1)
  dirKeyTable = {
    'h': dirW,
    'j': dirS,
    'k': dirN,
    'l': dirE,
    'y': dirNW,
    'u': dirNE,
    'b': dirSW,
    'n': dirSE,
  }.toTable

# Coord
type Coord = tuple[x, y: int]
proc `+`(self: Coord, other: Coord): Coord =
  (self.x + other.x, self.y + other.y)

# Size
type Size = tuple[w, h: int]

# Rect
type Rect = tuple[coord: Coord, size: Size]
proc x(self: Rect): int = self.coord.x
proc y(self: Rect): int = self.coord.y
proc w(self: Rect): int = self.size.w
proc h(self: Rect): int = self.size.h
proc right(self: Rect): int = self.x + self.w - 1
proc bottom(self: Rect): int  = self.y + self.h - 1

# Utility
proc toEven(n: int): int =
  if (n mod 2) == 0: n else: n - 1

proc toOdd(n: int): int =
  if (n mod 2) == 1: n else: n - 1

proc isDirKey(key: char): bool =
  key in dirKeyTable

proc toDir(key: char): Coord =
  dirKeyTable[key]

# Matrix
type Matrix*[T; W, H: static[int]] = array[H, array[W, T]]

# Console
type Console = Nimbox

proc newConsole(): Console =
  newNimbox()

proc cleanup(self: Console) =
  self.shutdown()

proc erase(self: Console): Console =
  self.clear
  self

proc move(self: Console, coord: Coord): Console =
  self.cursor = coord
  self

proc print(self: Console, coord: Coord, str: string, fg: Color = clrDefault): Console {.discardable.} =
  self.print(coord.x, coord.y, str, fg)
  self

template render[T](self: Console, renderable: T): Console =
  renderable.render(self)

proc flush(self: Console) =
  self.present

proc inputKey(self: Console, timeout: int = -1): char =
  let event = if timeout == -1:
    self.pollEvent
  else:
    self.peekEvent(timeout)
  if event.kind == EventType.Key: event.ch else: '\0'

# Hero
type Hero = ref object
  glyph: char
  color: Color
  coord: Coord

proc walk(self: Hero, dir: Coord) =
  self.coord = self.coord + dir

proc render(self: Hero, console: Console): Console =
  console
    .print(self.coord, $self.glyph, self.color)
    .move(self.coord)

# Messages
type Messages = ref object
  coord: Coord
  messages: seq[string]

proc newMessages(coord: Coord, max: uint=4): Messages =
  result = Messages(coord: coord)
  for i in 0 ..< max:
    result.messages.add("")

proc add(self: Messages, message: string) =
  self.messages.insert(message, 0)
  discard self.messages.pop

proc render(self: Messages, console: Console): Console =
  let (x, y) = self.coord
  for index, message in self.messages:
    console.print((x, y + index), message)
  console


# Room
type Room = Rect

iterator frame(self: Room): Coord =
  for x in self.x .. self.right:
    yield (x, self.y)
    yield (x, self.bottom)
  for y in self.y + 1 .. self.bottom - 1:
    yield (self.x, y)
    yield (self.right, y)

iterator inside(self: Room): Coord =
  for y in self.y + 1 .. self.bottom - 1:
    for x in self.x + 1 .. self.right - 1:
      yield (x, y)

# Map
const MAP_SIZE: Size = (80, 24)
type MapCell = string
type Map = ref object
  cells: Matrix[MapCell, MAP_SIZE.w, MAP_SIZE.h]
  coord: Coord

proc `[]`(self: Map, index: int): array[MAP_SIZE.w, MapCell] =
  self.cells[index]

proc put(self: var Map, coord: Coord, cell: MapCell) =
  self.cells[coord.y][coord.x] = cell

proc putRoom(self: var Map, room: Room) =
  for c in room.frame:
    self.put(c, "#")
  for c in room.inside:
    self.put(c, ".")

proc render(self: Map, console: Console): Console =
  for y in 0 ..< self.cells.len:
    for x in 0 ..< self[y].len:
      console.print((x, y) + self.coord, self.cells[y][x])

# Generator
type Generator = ref object
  size: Size
  rooms: seq[seq[Rect]]

proc generateRoom(self: Generator, area: Rect): Rect =
  const MIN_ROOM_SIZE: Size = (5, 5)
  let
    w = rand(MIN_ROOM_SIZE.w .. area.w).toOdd
    h = rand(MIN_ROOM_SIZE.h .. area.h).toOdd
    x = rand(area.x .. area.right - w).toEven
    y = rand(area.y .. area.bottom - h).toEven
  (coord:(x, y), size:(w, h))

proc generate(self: Generator, splitSize: Size): Map =
  result = Map()
  let areaSize: Size = (int(self.size.w / splitSize.w), int(self.size.h / splitSize.h))
  for y in 0 ..< splitSize.h:
    self.rooms.add(newSeq[Rect]())
    for x in 0 ..< splitSize.w:
      let area = (coord: (areaSize.w * x, areaSize.h * y), size: areaSize)
      self.rooms[y].add(self.generateRoom(area))
  for y in 0 ..< splitSize.h:
    for x in 0 ..< splitSize.w:
      result.putRoom(self.rooms[y][x])

# Rogue
type Rogue = ref object
  console: Console
  isRunning: bool
  hero: Hero
  messages: Messages
  map: Map

proc newRogue(): Rogue =
  randomize()
  result = Rogue(console: newConsole(),
       isRunning: true,
       hero: Hero(glyph: '@', color: clrDefault, coord: (1, 1)),
       messages: newMessages((0, 23), 4))

proc render(self: Rogue) =
  self.console
    .erase
    .render(self.messages)
    .render(self.map)
    .render(self.hero)
    .flush

proc quit(self: Rogue) =
  self.isRunning = false

proc input(self: Rogue) =
  let key = self.console.inputKey(500)
  if key.isDirKey:
    self.hero.walk(key.toDir)
    self.messages.add($key)
  elif key == 'q':
    self.quit

proc update(self: Rogue) =
  self.render
  self.input

proc run(self: Rogue) =
  defer: self.console.cleanup
  self.map = Generator(size: MAP_SIZE).generate((3, 3))
  while self.isRunning:
    self.update

when isMainModule:
  newRogue().run()
