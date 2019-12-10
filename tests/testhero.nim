import unittest, app/entity/[hero, item, tile]


suite "hero tests":
  test "new hero":
    let hero = newHero()
    check:
      hero.tile == Tile.Hero
      hero.floor == 1

  test "get gold":
    var hero = newHero()
    check: hero.gold == 0
    hero.getItem(newGold(32))
    check: hero.gold == 32
    hero.getItem(newGold(32))
    check: hero.gold == 64
