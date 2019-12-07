import
  tables,
  "entity"/[direction, hero, map, dungeon],
  scene, console, screen, command, endingscene

export scene

type MainScene* = ref object of Scene
  dungeon: Dungeon
  screen: Screen
  command: Table[char, Command]

proc newMainScene*(dungeon: Dungeon): Scene =
  let screen = newScreen(dungeon.hero)
  result = MainScene(
    dungeon: dungeon,
    screen: screen,
    command: {
      'h': newMove(dirW, dungeon, screen),
      'j': newMove(dirS, dungeon, screen),
      'k': newMove(dirN, dungeon, screen),
      'l': newMove(dirE, dungeon, screen),
      'y': newMove(dirNW, dungeon, screen),
      'u': newMove(dirNE, dungeon, screen),
      'b': newMove(dirSW, dungeon, screen),
      'n': newMove(dirSE, dungeon, screen),
      '>': newDownFloor(dungeon, screen)
    }.toTable)

{.warning[LockLevel]: off.}
method render(self: MainScene, console: Console) =
  for coord, tile in self.dungeon.mapOnHero.tiles:
    self.screen.update_map(coord, tile)
  self.screen.update_map(self.dungeon.hero.coord, self.dungeon.hero.tile)
  self.screen.render(console)

method input(self: MainScene, console: Console): Scene =
  result = self
  let key = console.inputKey(500)
  if key == 'q': return nil
  if key == 'd': self.dungeon.nextFloor # debug
  if key in self.command:
    self.command[key].execute
  if self.dungeon.heroOnGoal:
    return newEndingScene()
