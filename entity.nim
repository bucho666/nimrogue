import console, symbol, coord
export console

# Entity
type Entity* = ref object of RootObj
  symbol: Symbol
  coord*: Coord

proc newEntity*(glyph: char, color: Color = clrDefault, coord: Coord = (0, 0)): Entity =
  Entity(symbol: newSymbol(glyph, color), coord: coord)

method render*(self: Entity, console: Console): Console {.base discardable.} =
  self.symbol.render(console, self.coord)

# Item
type Item* = ref object of Entity
  number: int

type Gold* = ref object of Item

# Gold
proc newGold*(gold: int, coord: Coord = (0, 0)): Gold =
  result = Gold(symbol: newSymbol('$', clrYellow), coord: coord, number: gold)

# Hero
type Hero* = ref object of Entity

proc newHero*(color: Color = clrDefault): Hero =
  Hero(symbol: newSymbol('@', color))
