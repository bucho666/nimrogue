import console, symbol

type TerrainFlag = enum
  CanWalk, CanDown

type Terrain* = ref object
  symbol*: Symbol
  flag: set[TerrainFlag]

proc canWalk*(self: Terrain): bool = CanWalk in self.flag
proc canDown*(self: Terrain): bool = CanDown in self.flag

proc newTerraon(glyph: char, color: Color, flag: set[TerrainFlag] = {}): Terrain =
  Terrain(symbol: newSymbol(glyph, color), flag: flag)

let
  Block* = newTerraon(' ', clrDefault)
  Wall* = newTerraon('#', clrDefault)
  Floor* = newTerraon('.', clrGreen, {CanWalk})
  Passage* = newTerraon('.', clrDefault, {CanWalk})
  Door* = newTerraon('+', clrYellow, {CanWalk})
  Downstairs* = newTerraon('>', clrWhite, {CanWalk, CanDown})


