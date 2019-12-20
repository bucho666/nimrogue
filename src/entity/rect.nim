import coord, size

type Rect* = tuple[coord: Coord, size: Size]

proc x*(self: Rect): int = self.coord.x
proc y*(self: Rect): int = self.coord.y
proc width*(self: Rect): int = self.size.width
proc height*(self: Rect): int = self.size.height
proc right*(self: Rect): int = self.x + self.width - 1
proc bottom*(self: Rect): int  = self.y + self.height - 1
