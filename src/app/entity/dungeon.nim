import sequtils, random, hero, item, generator, map, monster, tile

type Dungeon* = ref object
  maps: seq[Map]
  hero: Hero

proc hero*(self: Dungeon): Hero =
  self.hero

proc mapOnHero*(self: Dungeon): Map =
  self.maps[self.hero.floor - 1]

proc putHeroAtRandom*(self: Dungeon) =
  self.hero.coord = self.mapOnHero.floorCoordAtRandom

proc buildLevel(level: int): Map =
  var map = newMap()
  let g = Generator().generate(MAP_SIZE, (3, 3))
  for c in g.floors: map.putTerrain(c, Floor)
  for c in g.walls: map.putTerrain(c, Wall)
  for c in g.passages: map.putTerrain(c, Passage)
  for c in g.exits: map.putTerrain(c, Door)
  map.setRooms(toSeq(g.rooms))
  map.putTerrain(map.floorCoordAtRandom, Downstairs)
  let gold = rand(0 .. 50 + 10 * level) + 2
  map.putItem(map.floorCoordAtRandom, newGold(gold))
  map.putMonster(map.floorCoordAtRandom, newMonster(Tile.Bat))
  map

proc newDungeon*(lastFloor: int): Dungeon =
  result = Dungeon(hero: newHero())
  for level in 0 ..< lastFloor:
    result.maps.add(buildLevel(level))
  result.putHeroAtRandom

proc lastFloor(self: Dungeon): int =
  self.maps.len

proc nextFloor*(self: Dungeon) =
  self.hero.floor.inc
  if self.lastFloor >= self.hero.floor:
    self.putHeroAtRandom

proc heroOnGoal*(self: Dungeon): bool =
  self.lastFloor < self.hero.floor
