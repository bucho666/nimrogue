import
  tables,
  sequtils,
  random,
  coord,
  direction,
  console,
  entity,
  generator,
  map,
  strformat,
  symbol

# Messages
type Messages = ref object
  messages: seq[string]

proc newMessages(max: uint=4): Messages =
  result = Messages()
  for i in 0 ..< max:
    result.messages.add("")

proc add(self: Messages, message: string) =
  self.messages.insert(message, 0)
  discard self.messages.pop

iterator pairs(self: Messages): (int, string)=
  for n, message in self.messages:
    yield (n, message)

# Dungeon
type Dungeon = ref object
  maps: seq[Map]
  hero: Hero

proc buildLevel(level: int): Map =
  var map = newMap()
  let g = Generator().generate(MAP_SIZE, (3, 3))
  for c in g.floors: map.putTerrain(c, Floor)
  for c in g.walls: map.putTerrain(c, Wall)
  for c in g.passages: map.putTerrain(c, Passage)
  for c in g.exits: map.putTerrain(c, Door)
  map.setRooms(toSeq(g.rooms))
  map.putTerrain(map.floorCoordAtRandom, Downstairs)
  let gold = rand(0 .. 50 + 10 * level) + 2
  map.putItem(newGold(gold, map.floorCoordAtRandom))
  map

proc mapOnHero(self: Dungeon): Map =
  self.maps[self.hero.floor - 1]

proc putHeroAtRandom(self: Dungeon) =
  self.hero.coord = self.mapOnHero.floorCoordAtRandom

proc newDungeon(lastFloor: int): Dungeon =
  result = Dungeon(hero: newHero())
  for level in 0 ..< lastFloor:
    result.maps.add(buildLevel(level))
  result.putHeroAtRandom

proc lastFloor(self: Dungeon): int =
  self.maps.len

proc nextFloor(self: Dungeon) =
  self.hero.floor.inc
  if self.lastFloor >= self.hero.floor:
    self.putHeroAtRandom

proc heroOnGoal(self: Dungeon): bool =
  self.lastFloor < self.hero.floor

# Screen
type Screen = ref object
  hero: Hero
  messages: Messages
  map_tile: Table[Coord, Symbol]

proc newScreen(hero: Hero): Screen =
  Screen(
    hero: hero,
    messages: newMessages(4),
  )

proc add_message(self: Screen, message: string) = self.messages.add(message)
proc update_map*(self: Screen, coord: Coord, symbol: Symbol) =
  self.map_tile[coord] = symbol

proc render(self: Screen, console: Console) =
  discard console.erase
  for coord, symbol in self.map_tile:
    console.print(coord, $symbol.glyph, symbol.color)
  for i, message in self.messages:
    console.print((0, 24 + i), message)
  console.print((0, 23), fmt"level: {self.hero.floor}")
  console.flush
  self.map_tile.clear

type Command = ref object of RootObj
method execute(self: Command) {.base.} = discard

# Move
type Move = ref object of Command
  direction: Direction
  dungeon: Dungeon
  screen: Screen

proc newMove(direction: Direction, dungeon: Dungeon, screen: Screen): Command =
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

proc newDownFloor(dungeon: Dungeon, screen: Screen): Command =
  DownFloor(dungeon: dungeon, screen: screen)

method execute(self: DownFloor) =
  let
    map = self.dungeon.mapOnHero
    hero = self.dungeon.hero
  if map.canDownAt(hero.coord) == false:
    self.screen.add_message("can't down")
    return
  self.dungeon.nextFloor

# Scene
type Scene = ref object of RootObj
method render(self: Scene, console: Console) {.base.} = discard
method input(self: Scene, console: Console): Scene {.base.} = discard
method update(self: Scene, console: Console): Scene {.base.} =
  self.render(console)
  self.input(console)

# WinScene
type WinScene = ref object of Scene
  color: Color

proc newWinScene(): WinScene =
  WinScene(color: clrWhite)

method render(self: WinScene, console: Console) =
  console
    .erase
    .print((0, 0), "*** You Made it!! ***", self.color)
    .print((0, 1), "(press 'q' to exit.)")
    .flush
  self.color = if self.color == clrYellow: clrWhite else: clrYellow

method input(self: WinScene, console: Console): Scene =
  result = self
  if console.inputKey(100) == 'q':
    return nil

# MainScene
type MainScene = ref object of Scene
  dungeon: Dungeon
  screen: Screen
  command: Table[char, Command]

proc newMainScene(dungeon: Dungeon): MainScene =
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

method render(self: MainScene, console: Console) =
  for coord, symbol in self.dungeon.mapOnHero.tiles:
    self.screen.update_map(coord, symbol)
  self.screen.update_map(self.dungeon.hero.coord, self.dungeon.hero.symbol)
  self.screen.render(console)

method input(self: MainScene, console: Console): Scene =
  result = self
  let key = console.inputKey(500)
  if key == 'q': return nil
  if key == 'd': self.dungeon.nextFloor # debug
  if key in self.command:
    self.command[key].execute
  if self.dungeon.heroOnGoal:
    return newWinScene()

# Main
proc main() =
  randomize()
  let
    console = newConsole()
    dungeon = newDungeon(3)
  var scene: Scene = newMainScene(dungeon)
  defer: console.cleanup
  while scene != nil:
    scene = scene.update(console)

when isMainModule:
  main()
