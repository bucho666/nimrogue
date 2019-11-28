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

# Rogue
const LastFloor = 3
type Rogue = ref object
  isRunning: bool
  console: Console
  hero: Hero
  messages: Messages
  map: Map
  level: int

proc newRogue(): Rogue =
  randomize()
  result = Rogue(console: newConsole(),
                 isRunning: true,
                 messages: newMessages((0, 24), 4),
                 hero: newHero(),
                 level: 1)

proc render(self: Rogue) =
  self.console
    .erase
    .render(self.messages)
    .render(self.map)
    .render(self.hero)
    .render(StatusLine(coord: (0, 23), level: self.level))
    .move(self.hero.coord)
    .flush

proc quit(self: Rogue) =
  self.isRunning = false

proc newLevel(self: Rogue) =
  self.map = newMap()
  let g = Generator().generate(MAP_SIZE, (3, 3))
  for c in g.floors: self.map.putTerrain(c, Floor)
  for c in g.walls: self.map.putTerrain(c, Wall)
  for c in g.passages: self.map.putTerrain(c, Passage)
  for c in g.exits: self.map.putTerrain(c, Door)
  self.map.setRooms(toSeq(g.rooms))
  self.map.putTerrain(self.map.floorCoordAtRandom, Downstairs)
  self.hero.coord = self.map.floorCoordAtRandom
  let gold = rand(0 .. 50 + 10 * self.level) + 2
  self.map.putItem(newGold(gold, self.map.floorCoordAtRandom))

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
  self.level.inc
  if self.level > LastFloor:
    self.win
    self.quit
  else:
    self.newLevel

proc moveHero(self: Rogue, dir: Direction) =
  let newCoord = self.hero.coord + dir
  if self.map.canWalkAt(newCoord):
    self.hero.coord += dir
    self.messages.add("move.")
  else:
    self.messages.add("can move.")

proc downHero(self: Rogue) =
  self.level.inc
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
  self.newLevel
  while self.isRunning:
    self.update

when isMainModule:
  newRogue().run()
