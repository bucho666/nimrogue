import console

type Scene* = ref object of RootObj
method render*(self: Scene, console: Console) {.base.} = discard
method input*(self: Scene, console: Console): Scene {.base.} = discard
method update*(self: Scene, console: Console): Scene {.base.} =
  self.render(console)
  self.input(console)
