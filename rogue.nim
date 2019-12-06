import
  random,
  nimboxconsole,
  entities/dungeon,
  mainscene

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
