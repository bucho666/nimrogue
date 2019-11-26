import
  random,
  sets,
  coord,
  direction,
  size,
  room

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

iterator rooms(self: RoomTable): Room =
  for roomTable in self:
    for room in roomTable:
      yield room

proc connectableDirections(self: RoomTable, coord: Coord): seq[Direction] =
  let
    room = self.roomAt(coord)
    (x, y) = coord
    (w, h) = (self.width, self.height)
  for (c, s, d) in [(x, 0, dirW), (x, w, dirE), (y, 0, dirN), (y, h, dirS)]:
    if c != s and not room.isConnectedTo(d): result.add(d)

proc allConnected(self: RoomTable): bool =
  for room in self.rooms:
    if room.isNotConnected: return false
  return true

# Generator
type Generator* = ref object
  roomTable: RoomTable
  passage: seq[Coord]

proc buildRooms(self: Generator, mapSize: Size, splitSize: Size) =
  let areaSize: Size = (int(mapSize.width / splitSize.width), int(mapSize.height / splitSize.height))
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

iterator floors*(self: Generator): Coord =
  for room in self.roomTable.rooms:
    for c in room.floors:
      yield c

iterator walls*(self: Generator): Coord =
  for room in self.roomTable.rooms:
    for c in room.walls:
      yield c

iterator exits*(self: Generator): Coord =
  for room in self.roomTable.rooms:
    for c in room.exits:
      yield c

iterator passages*(self: Generator): Coord =
  for c in self.passage: yield c
  for room in self.roomTable.rooms:
    for c in room.passages:
      yield c

iterator rooms*(self: Generator): Room =
  for room in self.roomTable.rooms:
    yield room

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
    self.passage.add(c)
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

proc generate*(self: Generator, mapSize: Size, splitSize: Size): Generator =
  self.buildRooms(mapSize, splitSize)
  self.buildPassages
  self
