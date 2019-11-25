import
  tables,
  random,
  sets,
  coord,
  direction,
  size,
  matrix,
  console,
  hero,
  room

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
  for c in room.floors: self.put(c, " ")
  for (d, c) in room.exits: self.put(c, "+")
  for c in room.passages: self.put(c, ".")

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
        room = if goneRooms.contains((x, y)): area.newGoneRoom else: area.newNormalRoom
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

# key of direction
const
  dirKeyTable = {
    'h': dirW, 'j': dirS, 'k': dirN, 'l': dirE,
    'y': dirNW, 'u': dirNE, 'b': dirSW, 'n': dirSE,
  }.toTable

proc isDirKey(key: char): bool =
  key in dirKeyTable

proc toDir(key: char): Coord =
  dirKeyTable[key]

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
       hero: newHero((1, 1)),
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
