import console, symbol, coord
export console

# Object
type Object* = ref object of RootObj
  symbol: Symbol
  coord*: Coord

proc newObject*(glyph: char, color: Color = clrDefault, coord: Coord = (0, 0)): Object =
  Object(symbol: newSymbol(glyph, color), coord: coord)

method render*(self: Object, console: Console): Console {.base discardable.} =
  self.symbol.render(console, self.coord)

# Item
type Item* = ref object of Object
  number: int

type Gold* = ref object of Item

# Gold
proc newGold*(gold: int, coord: Coord = (0, 0)): Gold =
  result = Gold(symbol: newSymbol('$', clrYellow), coord: coord, number: gold)

# Hero
type Hero* = ref object of Object

proc newHero*(color: Color = clrDefault): Hero =
  Hero(symbol: newSymbol('@', color))
