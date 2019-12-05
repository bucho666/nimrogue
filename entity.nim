import console, symbol, coord

# Entity
type Entity* = ref object of RootObj
  symbol: Symbol
  coord*: Coord

proc newEntity*(glyph: char, color: Color = clrDefault, coord: Coord = (0, 0)): Entity =
  Entity(symbol: newSymbol(glyph, color), coord: coord)

method symbol*(self: Entity): Symbol {.base.} = self.symbol

# Item
type Item* = ref object of Entity
  number: int

type Gold* = ref object of Item

# Gold
proc newGold*(gold: int, coord: Coord = (0, 0)): Gold =
  result = Gold(symbol: newSymbol('$', clrYellow), coord: coord, number: gold)

# Hero
type Hero* = ref object of Entity
  floor*: int

proc newHero*(color: Color = clrDefault): Hero =
  Hero(symbol: newSymbol('@', color), floor: 1)
