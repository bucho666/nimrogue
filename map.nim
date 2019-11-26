import
  coord,
  size,
  matrix,
  console,
  room,
  random,
  symbol

type TerrainFlag = enum
  CanWalk, CanDown

type Terrain* = ref object
  symbol: Symbol
  flag: set[TerrainFlag]

proc canWalk*(self: Terrain): bool = CanWalk in self.flag
proc canDown*(self: Terrain): bool = CanDown in self.flag

proc newTerraon(glyph: char, color: Color, flag: set[TerrainFlag] = {}): Terrain =
  Terrain(symbol: newSymbol(glyph, color), flag: flag)

proc render*(self: Terrain, console: Console, coord: Coord) =
  self.symbol.render(console, coord)

let
  Block* = newTerraon(' ', clrDefault)
  Wall* = newTerraon('#', clrDefault)
  Floor* = newTerraon('.', clrGreen, {CanWalk})
  Passage* = newTerraon('.', clrDefault, {CanWalk})
  Door* = newTerraon('+', clrYellow, {CanWalk})
  Downstairs* = newTerraon('>', clrWhite, {CanWalk, CanDown})

const MAP_SIZE*: Size = (80, 24)
type Map* = ref object
  terrain: Matrix[Terrain, MAP_SIZE.width, MAP_SIZE.height]
  coord: Coord
  rooms: seq[Room]

proc newMap*(): Map =
  result = Map()
  for y in 0 ..< result.terrain.len:
    for x in 0 ..< result.terrain[y].len:
      result.terrain[y][x] = Block

proc setRooms*(self: var Map, rooms: seq[Room]) =
  self.rooms = rooms

proc put*(self: var Map, coord: Coord, cell: Terrain) =
  self.terrain[coord.y][coord.x] = cell

proc render*(self: Map, console: Console): Console =
  for y in 0 ..< self.terrain.len:
    for x in 0 ..< self.terrain[y].len:
      self.terrain[y][x].render(console, (x, y) + self.coord)

proc floorCoordAtRandom*(self: Map): Coord =
  var floors: seq[Coord] = @[]
  while floors.len == 0:
    floors = self.rooms.sample.floors
  floors.sample

proc canWalkAt*(self: Map, coord: Coord): bool = self.terrain.at(coord).canWalk
proc canDownAt*(self: Map, coord: Coord): bool = self.terrain.at(coord).canDown
