import unittest
include app/entity/dungeon

suite "dungeon tests":
  test "new dungeon":
    let d = newDungeon(3)
    check:
      d.lastFloor == 3
      d.hero.floor == 1
      d.mapOnHero == d.maps[0]

  test "next floor":
    var d = newDungeon(3)
    d.nextFloor
    check:
      d.hero.floor == 2
      d.mapOnHero == d.maps[1]

  test "heroOnGoal":
    var d = newDungeon(3)
    check: d.heroOnGoal == false
    d.nextFloor
    d.nextFloor
    check: d.heroOnGoal == false
    d.nextFloor
    check: d.heroOnGoal

