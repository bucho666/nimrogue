import console, symbol, coord
export console

type Sprite* = ref object of RootObj
  symbol: Symbol
  coord*: Coord

proc newSprite*(glyph: char, color: Color = clrDefault, coord: Coord = (0, 0)): Sprite =
  Sprite(symbol: newSymbol(glyph, color), coord: coord)

method render*(self: Sprite, console: Console): Console {.base discardable.} =
  self.symbol.render(console, self.coord)
  console
