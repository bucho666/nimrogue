import nimbox, coord
export nimbox.Color

type Console* = Nimbox

proc newConsole*(): Console =
  newNimbox()

proc cleanup*(self: Console) =
  self.shutdown()

proc erase*(self: Console): Console =
  self.clear
  self

proc move*(self: Console, coord: Coord): Console =
  self.cursor = coord
  self

proc print*(self: Console, coord: Coord, str: string, fg: Color = clrDefault): Console {.discardable.} =
  self.print(coord.x, coord.y, str, fg)
  self

template render*(self: Console, renderable: untyped): Console =
  renderable.render(self)

proc flush*(self: Console) =
  self.present

proc inputKey*(self: Console, timeout: int = -1): char =
  let event = if timeout == -1:
    self.pollEvent
  else:
    self.peekEvent(timeout)
  if event.kind == EventType.Key: event.ch else: '\0'
