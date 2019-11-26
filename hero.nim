import console, coord

type Hero* = ref object
  glyph: char
  coord: Coord
  color: Color

proc newHero*(coord: Coord, color: Color = clrDefault): Hero =
  Hero(glyph: '@', coord: coord, color: color)

proc walk*(self: Hero, dir: Coord) =
  self.coord = self.coord + dir

proc coord*(self: Hero): Coord =
  self.coord

proc render*(self: Hero, console: Console): Console =
  console
    .print(self.coord, $self.glyph, self.color)
    .move(self.coord)
