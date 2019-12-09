import unittest, app/entity/coord

suite "coord tests":
  test "coord plus":
    check: (1, 2) + (3, 4) == (4, 6)

  test "coord plus equal":
    var c = (1, 2)
    c += (3, 4)
    check: c == (4, 6)

  test "coord minus":
    check: (4, 6) - (3, 4) == (1, 2)

  test "coord minus equal":
    var c = (4, 6)
    c -= (3, 4)
    check: c == (1, 2)

  test "coord abs":
    check (1, 2).abs == (1, 2)
    check (-3, 4).abs == (3, 4)
    check (5, -6).abs == (5, 6)
    check (-7, -8).abs == (7, 8)

  test "coord sum":
    check (1, 2).sum == 3
    check (-3, 4).sum == 1
    check (5, -6).sum == -1
    check (-7, -8).sum == -15

