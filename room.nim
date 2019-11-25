import
  tables,
  random,
  sequtils,
  coord,
  direction,
  rect,
  size

type Room* = ref object of RootObj
  exit: Table[Direction, Coord]

method isConnected*(self: Room): bool {.base.} = self.exit.len != 0
method isNotConnected*(self: Room): bool {.base.} = not self.isConnected
method isConnectedTo*(self: Room, dir: Direction): bool {.base.} = dir in self.exit
method floors*(self: Room): seq[Coord] {.base.} = @[]
method walls*(self: Room): seq[Coord] {.base.} = @[]
method wallCoordAtRandom*(self: Room, dir: Direction): Coord {.base.} = discard
method setExit*(self: Room, dir: Direction, coord: Coord) {.base.} = self.exit[dir] = coord
method exits*(self: Room): seq[(Direction, Coord)] {.base.} = @[]
method passages*(self: Room): seq[Coord] {.base.} = @[]

# NormalRoom
type NormalRoom* = ref object of Room
  area: Rect

proc toEven(n: int): int =
  if (n mod 2) == 0: n else: n - 1

proc toOdd(n: int): int =
  if (n mod 2) == 1: n else: n - 1

proc newNormalRoom*(area: Rect): Room =
  const MIN_ROOM_SIZE: Size = (5, 5)
  let
    w = rand(MIN_ROOM_SIZE.width .. area.width).toOdd
    h = rand(MIN_ROOM_SIZE.height .. area.height).toOdd
    x = rand(area.x .. area.right - w).toEven
    y = rand(area.y .. area.bottom - h).toEven
  NormalRoom(area: (coord:(x, y), size:(w, h)))

proc x*(self: NormalRoom): int = self.area.x
proc y*(self: NormalRoom): int = self.area.y
proc right*(self: NormalRoom): int = self.area.right
proc bottom*(self: NormalRoom): int  = self.area.bottom
method walls*(self: NormalRoom): seq[Coord] =
  for x in self.x .. self.right:
    result.add((x, self.y))
    result.add((x, self.bottom))
  for y in self.y + 1 .. self.bottom - 1:
    result.add((self.x, y))
    result.add((self.right, y))

method floors*(self: NormalRoom): seq[Coord] =
  for y in self.y + 1 .. self.bottom - 1:
    for x in self.x + 1 .. self.right - 1:
      result.add((x, y))

method wallCoordAtRandom*(self: NormalRoom, dir: Direction): Coord =
  if dir == dirN: return (rand(self.x + 1 ..< self.right), self.y)
  if dir == dirS: return (rand(self.x + 1 ..< self.right), self.bottom)
  if dir == dirW: return (self.x, rand(self.y + 1 ..< self.bottom))
  if dir == dirE: return (self.right, rand(self.y + 1 ..< self.bottom))
  raise newException(Exception, "Invalid Direction")

method exits*(self: NormalRoom): seq[(Direction, Coord)] = toSeq(self.exit.pairs)

# GoneRoom
type GoneRoom* = ref object of Room
  coord: Coord

proc newGoneRoom*(area: Rect): Room =
  let
    x = rand(area.x + 1 ..< area.right).toEven
    y = rand(area.y + 1 ..< area.bottom).toEven
  GoneRoom(coord:(x, y))

method walls*(self: GoneRoom): seq[Coord] = @[]
method wallCoordAtRandom*(self: GoneRoom, dir: Direction): Coord = self.coord
method passages*(self: GoneRoom): seq[Coord] = @[self.coord]
