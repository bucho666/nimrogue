type Matrix*[T; W, H: static[int]] = array[H, array[W, T]]

proc at*[T; W, H: static[int]](self: Matrix[T, W, H], coord: tuple[x, y: int]): T =
  self[coord.y][coord.x]
