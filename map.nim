import
  coord,
  size,
  matrix,
  console,
  room,
  random

const MAP_SIZE*: Size = (80, 24)
type MapCell* = string
type Map* = ref object
  cells: Matrix[MapCell, MAP_SIZE.width, MAP_SIZE.height]
  coord: Coord
  rooms: seq[Room]

proc setRooms*(self: var Map, rooms: seq[Room]) =
  self.rooms = rooms

proc put*(self: var Map, coord: Coord, cell: MapCell) =
  self.cells[coord.y][coord.x] = cell

proc render*(self: Map, console: Console): Console =
  for y in 0 ..< self.cells.len:
    for x in 0 ..< self.cells[y].len:
      console.print((x, y) + self.coord, self.cells[y][x])

proc floorCoordAtRandom*(self: Map): Coord =
  var floors: seq[Coord] = @[]
  while floors.len == 0:
    floors = self.rooms.sample.floors
  floors.sample
