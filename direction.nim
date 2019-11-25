import coord

type Direction* = Coord

proc directionTo*(self: Coord, other: Coord): Direction =
  let
    v = other - self
    x = if v.x > 0: 1 elif v.x < 0: -1 else: 0
    y = if v.y > 0: 1 elif v.y < 0: -1 else: 0
  (x, y)

proc reverse*(self: Direction): Direction =
  (self.x * -1, self.y * -1)

const
  dirN* = (0, -1)
  dirE* = (1,  0)
  dirS* = (0,  1)
  dirW* = (-1, 0)
  dirNE* = (1, -1)
  dirSE* = (1, 1)
  dirSW* = (-1, 1)
  dirNW* = (-1, -1)
