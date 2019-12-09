import random, nimboxconsole, app/entity/dungeon, app/mainscene

proc main() =
  randomize()
  let
    dungeon = newDungeon(3)
    console = newNimBoxConsole()
  defer: console.cleanup
  var scene = newMainScene(dungeon)
  while scene != nil:
    scene = scene.update(console)

when isMainModule:
  main()
