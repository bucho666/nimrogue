import strformat, entity/[coord, direction, hero, item, map, dungeon], screen

type Command* = ref object of RootObj

method execute*(self: Command) {.base.} = discard

# Move
type Move = ref object of Command
  direction: Direction
  dungeon: Dungeon
  screen: Screen

proc newMove*(direction: Direction, dungeon: Dungeon, screen: Screen): Command =
  Move(direction: direction, dungeon: dungeon, screen: screen)

{.warning[LockLevel]: off.}

method execute(self: Move) =
  let
    newCoord = self.dungeon.hero.coord + self.direction
    map = self.dungeon.mapOnHero
    hero = self.dungeon.hero
  if map.canWalkAt(newCoord) == false:
    self.screen.add_message("can't move.")
    return
  hero.coord = newCoord
  let item = map.takeItemAt(newCoord)
  if item.isNil:
    return
  hero.getItem(item)
  self.screen.add_message(fmt"get {item.name} ({item.number})")

# Down Floor
type DownFloor = ref object of Command
  dungeon: Dungeon
  screen: Screen

proc newDownFloor*(dungeon: Dungeon, screen: Screen): Command =
  DownFloor(dungeon: dungeon, screen: screen)

method execute(self: DownFloor) =
  let
    map = self.dungeon.mapOnHero
    hero = self.dungeon.hero
  if map.canDownAt(hero.coord) == false:
    self.screen.add_message("can't down")
    return
  self.dungeon.nextFloor
