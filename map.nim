import
  coord,
  size,
  matrix,
  console,
  room,
  random

type TerrainFlag = enum
  CanWalk, CanDown

type Terrain* = ref object
  glyph: char
  color: Color
  flag: set[TerrainFlag]

proc canWalk*(self: Terrain): bool = CanWalk in self.flag
proc canDown*(self: Terrain): bool = CanDown in self.flag

proc newTerraon(glyph: char, color: Color, flag: set[TerrainFlag] = {}): Terrain =
  Terrain(glyph: glyph, color: color, flag: flag)

proc render*(self: Terrain, console: Console, coord: Coord) =
  console.print(coord, $self.glyph, self.color)

let
  Block* = newTerraon(' ', clrDefault)
  Wall* = newTerraon('#', clrDefault)
  Floor* = newTerraon(' ', clrDefault, {CanWalk})
  Passage* = newTerraon('.', clrDefault, {CanWalk})
  Door* = newTerraon('+', clrDefault, {CanWalk})
  Downstairs* = newTerraon('>', clrDefault, {CanWalk, CanDown})

const MAP_SIZE*: Size = (80, 24)
type MapCell = Terrain
type Map* = ref object
  cells: Matrix[MapCell, MAP_SIZE.width, MAP_SIZE.height]
  coord: Coord
  rooms: seq[Room]

proc newMap*(): Map =
  result = Map()
  for y in 0 ..< result.cells.len:
    for x in 0 ..< result.cells[y].len:
      result.cells[y][x] = Block

proc setRooms*(self: var Map, rooms: seq[Room]) =
  self.rooms = rooms

proc put*(self: var Map, coord: Coord, cell: MapCell) =
  self.cells[coord.y][coord.x] = cell

proc render*(self: Map, console: Console): Console =
  for y in 0 ..< self.cells.len:
    for x in 0 ..< self.cells[y].len:
      self.cells[y][x].render(console, (x, y) + self.coord)

proc floorCoordAtRandom*(self: Map): Coord =
  var floors: seq[Coord] = @[]
  while floors.len == 0:
    floors = self.rooms.sample.floors
  floors.sample

proc at(self: Map, coord: Coord): MapCell =
  self.cells[coord.y][coord.x]

proc canWalkAt*(self: Map, coord: Coord): bool = self.at(coord).canWalk
proc canDownAt*(self: Map, coord: Coord): bool = self.at(coord).canDown
