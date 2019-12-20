import tile

type
  TerrainFlag = enum
    CanWalk, CanDown

  Terrain* = ref object of RootObj
    tile: Tile
    flag: set[TerrainFlag]

method tile*(self: Terrain): Tile {.base.} =
  self.tile

proc newTerraon(tile: Tile, flag: set[TerrainFlag] = {}): Terrain =
  Terrain(tile: tile, flag: flag)

proc canWalk*(self: Terrain): bool =
  CanWalk in self.flag

proc canDown*(self: Terrain): bool =
  CanDown in self.flag

let
  Blank* = newTerraon(Tile.Blank)
  Wall* = newTerraon(Tile.Wall)
  Floor* = newTerraon(Tile.Floor, {CanWalk})
  Passage* = newTerraon(Tile.Passage, {CanWalk})
  Door* = newTerraon(Tile.Door, {CanWalk})
  Downstairs* = newTerraon(Tile.DownStairs, {CanWalk, CanDown})
