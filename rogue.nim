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
  strformat

# Key
const
  dirKeyTable = {
    'h': dirW, 'j': dirS, 'k': dirN, 'l': dirE,
    'y': dirNW, 'u': dirNE, 'b': dirSW, 'n': dirSE,
  }.toTable

proc isDirKey(key: char): bool =
  key in dirKeyTable

proc toDir(key: char): Coord =
  dirKeyTable[key]

# Messages
type Messages = ref object
  coord: Coord
  messages: seq[string]

proc newMessages(coord: Coord, max: uint=4): Messages =
  result = Messages(coord: coord)
  for i in 0 ..< max:
    result.messages.add("")

proc add(self: Messages, message: string) =
  self.messages.insert(message, 0)
  discard self.messages.pop

proc render(self: Messages, console: Console): Console =
  let (x, y) = self.coord
  for index, message in self.messages:
    console.print((x, y + index), message)
  console

# StatusLine
type StatusLine = ref object
  coord: Coord
  level: int

proc render(self: StatusLine, console: Console): Console =
  console.print(self.coord, fmt"level: {self.level}")

# Dungeon
type Dungeon = ref object
  level*: int
  maps: seq[Map]

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

proc newDungeon(lastFloor: int): Dungeon =
  result = Dungeon()
  for level in 0 ..< lastFloor:
    result.maps.add(buildLevel(level))

proc currentMap(self: Dungeon): Map =
  self.maps[self.level - 1]

proc isLastMap(self: Dungeon): bool =
  self.maps.len == self.level

# Rogue
const LastFloor = 3
type Rogue = ref object
  isRunning: bool
  console: Console
  hero: Hero
  dungeon: Dungeon
  messages: Messages

proc map(self: Rogue): Map = self.dungeon.currentMap

proc newRogue(): Rogue =
  randomize()
  result = Rogue(console: newConsole(),
                 isRunning: true,
                 dungeon: newDungeon(LastFloor),
                 hero: newHero(),
                 messages: newMessages((0, 24), 4))

proc render(self: Rogue) =
  self.console
    .erase
    .render(self.messages)
    .render(self.map)
    .render(self.hero)
    .render(StatusLine(coord: (0, 23), level: self.dungeon.level))
    .move(self.hero.coord)
    .flush

proc quit(self: Rogue) =
  self.isRunning = false

proc win(self: Rogue) =
  var
    key = '\0'
    color = clrWhite
  while key != 'q':
    self.console
      .erase
      .print((0, 0), "*** You Made it!! ***", color)
      .print((0, 1), "(press 'q' to exit.)")
      .flush
    color = if color == clrYellow: clrWhite else: clrYellow
    key = self.console.inputKey(100)

proc downFloor(self: Rogue) =
  if self.dungeon.isLastMap:
    self.win
    self.quit
  else:
    self.dungeon.level.inc
    self.hero.coord = self.map.floorCoordAtRandom

proc moveHero(self: Rogue, dir: Direction) =
  let newCoord = self.hero.coord + dir
  if self.map.canWalkAt(newCoord):
    self.hero.coord += dir
    self.messages.add("move.")
  else:
    self.messages.add("can move.")

proc downHero(self: Rogue) =
  if self.map.canDownAt(self.hero.coord):
    self.downFloor
  else:
    self.messages.add("can't down.")

proc input(self: Rogue) =
  let key = self.console.inputKey(500)
  if key.isDirKey: self.moveHero(key.toDir)
  if key == '>': self.downHero
  if key == 'd': self.downFloor
  elif key == 'q': self.quit

proc update(self: Rogue) =
  self.render
  self.input

proc run(self: Rogue) =
  defer: self.console.cleanup
  self.downFloor
  while self.isRunning:
    self.update

when isMainModule:
  newRogue().run()
