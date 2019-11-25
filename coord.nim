type Coord* = tuple[x, y: int]

proc `+`*(self: Coord, other: Coord): Coord =
  (self.x + other.x, self.y + other.y)

proc `+=`*(self: var Coord, other: Coord) =
  self = self + other

proc `-`*(self: Coord, other: Coord): Coord =
  (self.x - other.x, self.y - other.y)

proc abs*(self: Coord): Coord =
  (self.x.abs, self.y.abs)

proc sum*(self: Coord): int =
  self.x + self.y
