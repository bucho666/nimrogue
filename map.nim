import
  coord,
  size,
  matrix,
  console,
  room,
  random,
  terrain,
  entity

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
      result.terrain[y][x] = Block

proc setRooms*(self: var Map, rooms: seq[Room]) =
  self.rooms = rooms

proc putTerrain*(self: var Map, coord: Coord, terrain: Terrain) =
  self.terrain[coord.y][coord.x] = terrain

proc putItem*(self: var Map, item: Item) =
  self.items.add(item)

proc renderTerrain(self: Map, console: Console) =
  for y in 0 ..< self.terrain.len:
    for x in 0 ..< self.terrain[y].len:
      self.terrain[y][x].render(console, (x, y) + self.coord)

proc renderItem(self: Map, console: Console) =
  for item in self.items:
    item.render(console)

proc render*(self: Map, console: Console): Console =
  self.renderTerrain(console)
  self.renderItem(console)

proc floorCoordAtRandom*(self: Map): Coord =
  var floors: seq[Coord] = @[]
  while floors.len == 0:
    floors = self.rooms.sample.floors
  floors.sample

proc canWalkAt*(self: Map, coord: Coord): bool = self.terrain.at(coord).canWalk
proc canDownAt*(self: Map, coord: Coord): bool = self.terrain.at(coord).canDown
