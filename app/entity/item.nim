import tile, coord

type ItemKind* {.pure.} = enum
  Gold

type Item* = ref object
  kind: ItemKind
  name: string
  coord*: Coord
  tile: Tile
  number*: int

proc kind*(self: Item): ItemKind =
  self.kind

proc name*(self: Item): string =
  self.name

proc tile*(self: Item): Tile =
  self.tile

proc newGold*(gold: int, coord: Coord = (0, 0)): Item =
  result = Item(kind: ItemKind.Gold, name: "gold", tile: Tile.Gold, coord: coord, number: gold)
