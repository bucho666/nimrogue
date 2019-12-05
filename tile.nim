import console, symbol, coord

# Tile
type Tile* = object
  symbol: Symbol
  coord*: Coord

proc glyph*(self: Tile): string = $self.symbol.glyph
proc color*(self: Tile): Color = self.symbol.color

proc newTile*(glyph: char, color: Color = clrDefault, coord: Coord = (0, 0)): Tile =
  Tile(symbol: newSymbol(glyph, color), coord: coord)
