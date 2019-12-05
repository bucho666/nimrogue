import
  random,
  console,
  dungeon,
  mainscene

proc main() =
  randomize()
  let
    dungeon = newDungeon(3)
    console = newConsole()
  defer: console.cleanup
  var scene = newMainScene(dungeon)
  while scene != nil:
    scene = scene.update(console)

when isMainModule:
  main()
