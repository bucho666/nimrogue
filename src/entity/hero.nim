import tables, tile, coord, item

# Hero
type Hero* = ref object
  coord*: Coord
  tile: Tile
  floor*: int
  inventory: Table[ItemKind, Table[string, Item]]

proc newHero*(): Hero =
  result = Hero(tile: Tile.Hero, floor: 1)
  for kind in ItemKind:
    result.inventory[kind] = initTable[string, Item]()

proc tile*(self: Hero): Tile  =
  self.tile

proc getItem*(self: Hero, item: Item) =
  let (kind, name) = (item.kind, item.name)
  if name in self.inventory[kind]:
    self.inventory[kind][name].number += item.number
  else:
    self.inventory[kind][name] = item

proc gold*(self: Hero): int =
  if "gold" in self.inventory[ItemKind.Gold]:
    return self.inventory[ItemKind.Gold]["gold"].number
