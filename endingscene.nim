import scene, console

type EndingScene = ref object of Scene
  color: Color

proc newEndingScene*(): EndingScene =
  EndingScene(color: Color.White)

method render(self: EndingScene, console: Console) =
  console
    .erase
    .print((0, 0), "*** You Made it!! ***", self.color)
    .print((0, 1), "(press 'q' to exit.)")
    .flush
  self.color = if self.color == Color.Yellow: Color.White else: Color.Yellow

method input(self: EndingScene, console: Console): Scene =
  result = self
  if console.inputKey(100) == 'q':
    return nil
