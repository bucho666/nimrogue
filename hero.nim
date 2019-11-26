import console, coord, symbol

type Hero* = ref object
  symbol: Symbol
  coord*: Coord

proc newHero*(color: Color = clrDefault): Hero =
  Hero(symbol: newSymbol('@', color))

proc walk*(self: Hero, dir: Coord) =
  self.coord = self.coord + dir

proc render*(self: Hero, console: Console): Console =
  self.symbol.render(console, self.coord)
  console.move(self.coord)
