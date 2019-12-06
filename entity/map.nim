import
  coord,
  size,
  matrix,
  room,
  random,
  terrain,
  entity,
  tile

export terrain

const MAP_SIZE*: Size = (80, 24)
type Map* = ref object
  terrain: Matrix[Terrain, MAP_SIZE.width, MAP_SIZE.height]
  coord: Coord
  rooms: seq[Room]
  items: seq[Item]

proc newMap*(): Map =
  result = Map()
  for y in 0 ..< result.terrain.len:
    for x in 0 ..< result.terrain[y].len:
      result.terrain[y][x] = Blank

proc setRooms*(self: var Map, rooms: seq[Room]) =
  self.rooms = rooms

proc putTerrain*(self: var Map, coord: Coord, terrain: Terrain) =
  self.terrain[coord.y][coord.x] = terrain

proc putItem*(self: var Map, item: Item) =
  self.items.add(item)

iterator tiles*(self: Map): (Coord, Tile) =
  for y in 0 ..< self.terrain.len:
    for x in 0 ..< self.terrain[y].len:
      yield ((x, y), self.terrain[y][x].tile)
  for item in self.items:
    yield (item.coord, item.tile)

proc floorCoordAtRandom*(self: Map): Coord =
  var floors: seq[Coord] = @[]
  while floors.len == 0:
    floors = self.rooms.sample.floors
  floors.sample

proc canWalkAt*(self: Map, coord: Coord): bool = self.terrain.at(coord).canWalk
proc canDownAt*(self: Map, coord: Coord): bool = self.terrain.at(coord).canDown
