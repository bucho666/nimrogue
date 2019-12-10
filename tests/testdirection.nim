import unittest, app/entity/direction

suite "direction tests":
  test "direction to":
    check: (0, 0).directionTo(dirN) == dirN
    check: (1, 1).directionTo((0, 1)) == dirW
    check: (100, 100).directionTo((0, 0)) == dirNW
    check: (-100, -100).directionTo((0, 0)) == dirSE
    check: (-100, 100).directionTo((0, 0)) == dirNE
    check: (100, -100).directionTo((0, 0)) == dirSW

  test "reverse":
    check: dirN.reverse == dirS
    check: dirS.reverse == dirN
    check: dirE.reverse == dirW
    check: dirW.reverse == dirE
    check: dirNE.reverse == dirSW
    check: dirSW.reverse == dirNE
    check: dirSE.reverse == dirNW
    check: dirNW.reverse == dirSE
