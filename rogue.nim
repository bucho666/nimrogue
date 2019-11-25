import
  tables,
  random,
  coord,
  direction,
  console,
  hero,
  generator,
  map

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

# Rogue
type Rogue = ref object
  console: Console
  isRunning: bool
  hero: Hero
  messages: Messages
  map: Map

proc newRogue(): Rogue =
  randomize()
  result = Rogue(console: newConsole(),
                 isRunning: true,
                 hero: newHero((1, 1)),
                 messages: newMessages((0, 23), 4),
                 map: Map())

proc render(self: Rogue) =
  self.console
    .erase
    .render(self.messages)
    .render(self.map)
    .render(self.hero)
    .flush

proc quit(self: Rogue) =
  self.isRunning = false

proc input(self: Rogue) =
  let key = self.console.inputKey(500)
  if key.isDirKey:
    self.hero.walk(key.toDir)
    self.messages.add($key)
  elif key == 'q':
    self.quit

proc update(self: Rogue) =
  self.render
  self.input

proc buildMap(self: Rogue) =
  let g = Generator().generate(MAP_SIZE, (3, 3))
  for c in g.floors: self.map.put(c, " ")
  for c in g.walls: self.map.put(c, "#")
  for c in g.passages: self.map.put(c, ".")
  for c in g.exits: self.map.put(c, "+")

proc run(self: Rogue) =
  defer: self.console.cleanup
  self.buildMap
  while self.isRunning:
    self.update

when isMainModule:
  newRogue().run()
