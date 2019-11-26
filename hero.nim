import sprite
export sprite.render

type Hero* = ref object of Sprite

proc newHero*(color: Color = clrDefault): Hero =
  cast[Hero](newSprite('@', color))
