# Package

version       = "0.1.0"
author        = "bucho"
description   = "rogue in nim"
license       = "MIT"
srcDir        = "src"
bin           = @["rogue"]



# Dependencies

requires "nim >= 1.0.4", "nimbox"


# Tasks
task exec, "run the program":
  exec "nimble build"
  exec "./rogue"
