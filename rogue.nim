import
  nimbox,
  tables,
  random,
  sets,
  sequtils

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

# Coord/Direction
type
  Coord = tuple[x, y: int]
  Direction = Coord

proc `+`(self: Coord, other: Coord): Coord =
  (self.x + other.x, self.y + other.y)

proc `+=`(self: var Coord, other: Coord) =
  self = self + other

proc `-`(self: Coord, other: Coord): Coord =
  (self.x - other.x, self.y - other.y)

proc abs(self: Coord): Coord =
  (self.x.abs, self.y.abs)

proc sum(self: Coord): int =
  self.x + self.y

proc directionTo(self: Coord, other: Coord): Direction =
  let
    v = other - self
    x = if v.x > 0: 1 elif v.x < 0: -1 else: 0
    y = if v.y > 0: 1 elif v.y < 0: -1 else: 0
  (x, y)

proc reverse(self: Direction): Direction =
  (self.x * -1, self.y * -1)

# Size
type Size = tuple[width, height: int]

# Rect
type Rect = tuple[coord: Coord, size: Size]
proc x(self: Rect): int = self.coord.x
proc y(self: Rect): int = self.coord.y
proc width(self: Rect): int = self.size.width
proc height(self: Rect): int = self.size.height
proc right(self: Rect): int = self.x + self.width - 1
proc bottom(self: Rect): int  = self.y + self.height - 1

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

type Room = ref object of RootObj
  exit: Table[Direction, Coord]

method isConnected(self: Room): bool {.base.} = self.exit.len != 0
method isNotConnected(self: Room): bool {.base.} = not self.isConnected
method isConnectedTo(self: Room, dir: Direction): bool {.base.} = dir in self.exit
method floors(self: Room): seq[Coord] {.base.} = discard
method walls(self: Room): seq[Coord] {.base.} = discard
method wallCoordAtRandom(self: Room, dir: Direction): Coord {.base.} = discard
method setExit(self: Room, dir: Direction, coord: Coord) {.base.} = self.exit[dir] = coord
method exits(self: Room): seq[(Direction, Coord)] {.base.} = @[]

# NormalRoom
type NormalRoom = ref object of Room
  area: Rect

proc x(self: NormalRoom): int = self.area.x
proc y(self: NormalRoom): int = self.area.y
proc right(self: NormalRoom): int = self.area.right
proc bottom(self: NormalRoom): int  = self.area.bottom
method walls(self: NormalRoom): seq[Coord] =
  for x in self.x .. self.right:
    result.add((x, self.y))
    result.add((x, self.bottom))
  for y in self.y + 1 .. self.bottom - 1:
    result.add((self.x, y))
    result.add((self.right, y))

method floors(self: NormalRoom): seq[Coord] =
  for y in self.y + 1 .. self.bottom - 1:
    for x in self.x + 1 .. self.right - 1:
      result.add((x, y))

method wallCoordAtRandom(self: NormalRoom, dir: Direction): Coord =
  if dir == dirN: return (rand(self.x + 1 ..< self.right), self.y)
  if dir == dirS: return (rand(self.x + 1 ..< self.right), self.bottom)
  if dir == dirW: return (self.x, rand(self.y + 1 ..< self.bottom))
  if dir == dirE: return (self.right, rand(self.y + 1 ..< self.bottom))
  raise newException(Exception, "Invalid Direction")

method exits(self: NormalRoom): seq[(Direction, Coord)] = toSeq(self.exit.pairs)

# GoneRoom
type GoneRoom = ref object of Room
  coord: Coord

method walls(self: GoneRoom): seq[Coord] = @[]
method floors(self: GoneRoom): seq[Coord] = @[self.coord]
method wallCoordAtRandom(self: GoneRoom, dir: Direction): Coord = self.coord

# Map
const MAP_SIZE: Size = (80, 24)
type MapCell = string
type Map = ref object
  cells: Matrix[MapCell, MAP_SIZE.width, MAP_SIZE.height]
  coord: Coord

proc put(self: var Map, coord: Coord, cell: MapCell) =
  self.cells[coord.y][coord.x] = cell

proc putRoom(self: var Map, room: Room) =
  for c in room.walls: self.put(c, "#")
  for c in room.floors: self.put(c, ".")
  for (d, c) in room.exits: self.put(c, "+")

proc render(self: Map, console: Console): Console =
  for y in 0 ..< self.cells.len:
    for x in 0 ..< self.cells[y].len:
      console.print((x, y) + self.coord, self.cells[y][x])

# RoomTable
type RoomTable = seq[seq[Room]]

proc width(self: RoomTable): int = self[0].len - 1
proc height(self: RoomTable): int = self.len - 1
proc roomCoordAtRandom(self: RoomTable): Coord = (rand(0 .. self.width), rand(0 .. self.height))
proc roomAt(self: RoomTable, coord: Coord): Room = self[coord.y][coord.x]

proc connectedRoomCoordAtRandom(self: RoomTable): Coord =
  while true:
    let coord = self.roomCoordAtRandom
    if self.roomAt(coord).isConnected:
      return coord

iterator rooms(self: RoomTable): (Coord, Room) =
  for y, roomTable in self:
    for x, room in roomTable:
      yield ((x, y), room)

proc connectableDirections(self: RoomTable, coord: Coord): seq[Direction] =
  let
    room = self.roomAt(coord)
    (x, y) = coord
    (w, h) = (self.width, self.height)
  for (c, s, d) in [(x, 0, dirW), (x, w, dirE), (y, 0, dirN), (y, h, dirS)]:
    if c != s and not room.isConnectedTo(d): result.add(d)

proc allConnected(self: RoomTable): bool =
  for coord, room in self.rooms:
    if room.isNotConnected: return false
  return true

# Generator
type Generator = ref object
  size: Size
  roomTable: RoomTable
  map: Map

proc generateNormalRoom(self: Generator, area: Rect): Room =
  const MIN_ROOM_SIZE: Size = (5, 5)
  let
    w = rand(MIN_ROOM_SIZE.width .. area.width).toOdd
    h = rand(MIN_ROOM_SIZE.height .. area.height).toOdd
    x = rand(area.x .. area.right - w).toEven
    y = rand(area.y .. area.bottom - h).toEven
  NormalRoom(area: (coord:(x, y), size:(w, h)))

proc generateGoneRoom(self: Generator, area: Rect): Room =
  let
    x = rand(area.x + 1 ..< area.right).toEven
    y = rand(area.y + 1 ..< area.bottom).toEven
  GoneRoom(coord:(x, y))

proc buildRooms(self: Generator, splitSize: Size) =
  let areaSize: Size = (int(self.size.width / splitSize.width), int(self.size.height / splitSize.height))
  var goneRooms: HashSet[Coord]
  for n in 0 .. splitSize.width:
    goneRooms.incl((rand(0 ..< splitSize.width), rand(0 ..< splitSize.height)))
  for y in 0 ..< splitSize.height:
    self.roomTable.add(newSeq[Room]())
    for x in 0 ..< splitSize.width:
      let
        area = (coord: (areaSize.width * x, areaSize.height * y), size: areaSize)
        room = if goneRooms.contains((x, y)):
          self.generateGoneRoom(area)
        else:
          self.generateNormalRoom(area)
      self.roomTable[y].add(room)

proc putRooms(self: Generator) =
  for coord, room in self.roomTable.rooms:
    self.map.putRoom(room)

proc makePassageTo(fromCoord, toCoord: Coord): seq[Coord] =
  var current = fromCoord
  let dir = current.directionTo(toCoord)
  result = @[current]
  while current != toCoord:
    let distance = (toCoord - current).abs
    current += (if rand(1..distance.sum) <= distance.x: (dir.x, 0) else: (0, dir.y))
    result.add(current)

proc connectRoom(self: Generator, roomCoord: Coord, dir: Direction) =
  let
    fromRoom = self.roomTable.roomAt(roomCoord)
    fromRoomExit = fromRoom.wallCoordAtRandom(dir)
    fromCoord = fromRoomExit + dir
    toRoom= self.roomTable.roomAt(roomCoord + dir)
    rdir = dir.reverse
    toRoomExit = toRoom.wallCoordAtRandom(rdir)
    toCoord = toRoomExit + rdir
  for c in fromCoord.makePassageTo(toCoord):
    self.map.put(c, ".")
  fromRoom.setExit(dir, fromRoomExit)
  toRoom.setExit(rdir, toRoomExit)

proc buildPassages(self: Generator) =
  var coord = self.roomTable.roomCoordAtRandom
  while not self.roomTable.allConnected:
    let dirs = self.roomTable.connectableDirections(coord)
    if dirs.len == 0:
      coord = self.roomTable.connectedRoomCoordAtRandom
      continue
    let dir = dirs.sample
    self.connectRoom(coord, dir)
    coord += dir
  for n in 0 .. rand(0 .. self.roomTable.width):
    let coord = self.roomTable.connectedRoomCoordAtRandom
    let dirs = self.roomTable.connectableDirections(coord)
    if dirs.len == 0: continue
    self.connectRoom(coord, dirs.sample)

proc generate(self: Generator, splitSize: Size): Map =
  self.map = Map()
  self.buildRooms(splitSize)
  self.buildPassages
  self.putRooms()
  self.map

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
