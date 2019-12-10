import unittest, app/entity/[item, tile]

suite "item tests":
  test "new gold test":
    let g = newGold(32)
    check:
      g.kind == ItemKind.Gold
      g.name == "gold"
      g.tile == Tile.Gold
      g.number == 32
