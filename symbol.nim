import console

type Symbol* = object
  glyph: char
  color: Color

proc glyph*(self: Symbol): char = self.glyph
proc color*(self: Symbol): Color = self.color

proc newSymbol*(glyph: char, color: Color): Symbol =
  Symbol(glyph: glyph, color: color)
