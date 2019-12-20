import tile, coord

# Monster
type Monster* = ref object
  coord*: Coord
  tile: Tile

proc newMonster*(tile: Tile): Monster =
  result = Monster(tile: tile)

proc tile*(self: Monster): Tile  =
  self.tile
