import
  class,
  nimbox,
  tables

class Coord of tuple[x, y: int]:
  proc `+`(other: Coord): Coord =
    (self.x + other.x, self.y + other.y)

const
  dirN* = (0, -1)
  dirE* = (1,  0)
  dirS* = (0,  1)
  dirW* = (-1, 0)
  dirNE* = (1, -1)
  dirSE* = (1, 1)
  dirSW* = (-1, 1)
  dirNW* = (-1, -1)
  dirKeyTable = {
    'h': dirW,
    'j': dirS,
    'k': dirN,
    'l': dirE,
    'y': dirNW,
    'u': dirNE,
    'b': dirSW,
    'n': dirSE,
  }.toTable

type Size = tuple[w, h: int]

class Rect:
  var
    coord: Coord
    size: Size

  method x(): int {.base.} = self.coord.x
  method y(): int {.base.} = self.coord.y
  method w(): int {.base.} = self.size.w
  method h(): int {.base.} = self.size.h
  method right(): int {.base.} = self.x + self.w
  method bottom(): int {.base.} = self.y + self.h

proc isDirKey(key: char): bool =
  key in dirKeyTable

proc toDir(key: char): Coord =
  dirKeyTable[key]

class Console:
  var nb: Nimbox

  proc newConsole(): Console =
    Console(nb: newNimbox())

  proc cleanup() =
    self.nb.shutdown()

  proc clear(): Console =
    self.nb.clear
    self

  proc move(coord: Coord): Console =
    self.nb.cursor = coord
    self

  proc print(coord: Coord, str: string, fg: Color = clrDefault): Console {.discardable.} =
    self.nb.print(coord.x, coord.y, str, fg)
    self

  template render[T](renderable: T): Console =
    renderable.render(self)

  proc flush() =
    self.nb.present

  proc inputKey(timeout: int = -1): char =
    let event = if timeout == -1:
      self.nb.pollEvent
    else:
      self.nb.peekEvent(timeout)
    if event.kind == EventType.Key: event.ch else: '\0'

class Hero:
  var
    glyph: char
    color: Color
    coord: Coord

  proc walk(dir: Coord) =
    self.coord = self.coord + dir

  proc render(console: Console): Console =
    console
      .print(self.coord, $self.glyph, self.color)
      .move(self.coord)

class Messages:
  var
    coord: Coord
    messages: seq[string]

  proc newMessages(coord: Coord, max: uint=4): Messages =
    result = Messages(coord: coord)
    for i in 0..max - 1:
      result.messages.add("")

  proc add(message: string) =
    self.messages.insert(message, 0)
    discard self.messages.pop

  proc render(console: Console): Console =
    let (x, y) = self.coord
    for index, message in self.messages:
      console.print((x, y + index), message)
    console

class Area of Rect:
  iterator frame(): Coord =
    for x in self.x .. self.right:
      yield (x, self.y)
      yield (x, self.bottom)
    for y in self.y + 1 .. self.bottom - 1:
      yield (self.x, y)
      yield (self.right, y)

  proc render(console: Console): Console {.discardable.} =
    for c in self.frame:
      console.print(c, "*")

class Generator:
  var
    size: Size
    areas: seq[Area]

  proc render(console: Console): Console =
    for area in self.areas:
      console.render(area)
    console

  proc generate(splitSize: Size) =
    let areaSize: Size = (int(self.size.w / splitSize.w), int(self.size.h / splitSize.h))
    for y in 0..splitSize.h - 1:
      for x in 0..splitSize.w - 1:
        self.areas.add(Area(coord:(areaSize.w * x, areaSize.h * y), size:areaSize))

class Rogue:
  var
    console: Console
    isRunning: bool
    hero: Hero
    messages: Messages
    generator: Generator

  proc newRogue(): Rogue =
    Rogue(console: newConsole(),
         isRunning: true,
         hero: Hero(glyph: '@', color: clrDefault, coord: (1, 1)),
         messages: newMessages((0, 20), 4),
         generator: Generator(size:(81, 25))
         )

  proc render() =
    self.console
      .clear
      .render(self.messages)
      .render(self.generator)
      .render(self.hero)
      .flush

  proc quit() =
    self.isRunning = false

  proc input() =
    let key = self.console.inputKey(500)
    if key.isDirKey:
      self.hero.walk(key.toDir)
      self.messages.add($key)
    elif key == 'q':
      self.quit

  proc update() =
    self.render
    self.input

  proc run() =
    defer: self.console.cleanup
    self.generator.generate((3, 3))
    while self.isRunning:
      self.update

when isMainModule:
  newRogue().run()
