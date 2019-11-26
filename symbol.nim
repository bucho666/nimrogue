import console, coord

type Symbol* = object
  glyph: char
  color: Color

proc newSymbol*(glyph: char, color: Color): Symbol =
  Symbol(glyph: glyph, color: color)

proc render*(self: Symbol, console: Console, coord: Coord) =
  console.print(coord, $self.glyph, self.color)
