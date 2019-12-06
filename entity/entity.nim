import tile, coord

# Item
type Item* = ref object of RootObj
  coord*: Coord
  tile: Tile
  number: int

method tile*(self: Item): Tile {.base.} =
  self.tile

type Gold* = ref object of Item

# Gold
proc newGold*(gold: int, coord: Coord = (0, 0)): Gold =
  result = Gold(tile: Tile.Gold, coord: coord, number: gold)

# Hero
type Hero* = ref object
  coord*: Coord
  tile: Tile
  floor*: int

proc newHero*(): Hero =
  Hero(tile: Tile.Hero, floor: 1)

method tile*(self: Hero): Tile {.base.} =
  self.tile
