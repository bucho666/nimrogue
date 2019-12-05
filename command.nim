import
  coord,
  direction,
  entity,
  map,
  dungeon,
  screen

type Command* = ref object of RootObj
method execute*(self: Command) {.base.} = discard

# Move
type Move = ref object of Command
  direction: Direction
  dungeon: Dungeon
  screen: Screen

proc newMove*(direction: Direction, dungeon: Dungeon, screen: Screen): Command =
  Move(direction: direction, dungeon: dungeon, screen: screen)

method execute(self: Move) =
  let newCoord = self.dungeon.hero.coord + self.direction
  if self.dungeon.mapOnHero.canWalkAt(newCoord):
    self.dungeon.hero.coord += self.direction
    self.screen.add_message("move.")
  else:
    self.screen.add_message("can't move.")

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
