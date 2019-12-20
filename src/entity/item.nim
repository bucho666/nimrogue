import tile

type ItemKind* {.pure.} = enum
  Gold

type Item* = ref object
  kind: ItemKind
  name: string
  tile: Tile
  number*: int

proc kind*(self: Item): ItemKind =
  self.kind

proc name*(self: Item): string =
  self.name

proc tile*(self: Item): Tile =
  self.tile

proc newGold*(gold: int): Item =
  result = Item(kind: ItemKind.Gold, name: "gold", tile: Tile.Gold, number: gold)
