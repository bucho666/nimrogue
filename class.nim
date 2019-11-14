import macros

proc typeName(head: NimNode): NimNode =
  if head.len == 0:head else: head[1]

proc baseName(head: NimNode): NimNode =
  if head.len == 0: newIdentNode("RootObj") else: head[2]

proc isObjectDef(head: NimNode): bool =
  head.len == 0 or head[2].kind == nnkIdent

proc buildObjectTypeDecl(head: NimNode): NimNode =
  template typeDecl(a, b): untyped =
    type a* = ref object of b
  getAst(typeDecl(head.typeName, head.baseName))

proc buildBasicTypeDecl(head: NimNode): NimNode =
  newNimNode(nnkTypeSection)
    .add(newNimNode(nnkTypeDef)
      .add(newIdentNode($head[1]))
      .add(newNimNode(nnkEmpty))
      .add(head[2]))

proc buildTypeDecl(head: NimNode): NimNode =
  if head.isObjectDef:
    head.buildObjectTypeDecl
  else:
    head.buildBasicTypeDecl

macro class*(head, body: untyped): untyped =
  let
    typeName = head.typeName
    ctorName = newIdentNode("new" & $typeName)
    isObjectDef = head.isObjectDef
  var recList = if isObjectDef: newNimNode(nnkRecList) else: nil
  result = newStmtList()
  result.add(head.buildTypeDecl)
  for node in body.children:
    case node.kind:
      of nnkMethodDef, nnkProcDef, nnkIteratorDef, nnkTemplateDef:
        if node.name.kind != nnkAccQuoted and node.name == ctorName:
          node.params[0] = typeName
        else:
          node.params.insert(1, newIdentDefs(ident("self"), typeName))
        result.add(node)
      of nnkVarSection:
        if not isObjectDef:
          error "Invalid node: " & node.lispRepr
        for n in node.children:
          recList.add(n)
      else:
        result.add(node)
  if isObjectDef:
    result[0][0][2][0][2] = recList

when isMainModule:
  class Animal:
    var name: string
    var age: int

    method vocalize: string {.base.} =
      "..."

    method age_human_yrs: int {.base.} =
      self.age

  class Dog of Animal:
    method vocalize: string =
      "woof"

    method age_human_yrs: int =
      self.age * 7

  class Cat of Animal:
    method vocalize: string =
      "meow"

  class Rabbit of Animal:
    proc newRabbit(name: string, age: int) =
      result = Rabbit(name: name, age: age)

    method vocalize: string =
      "meep"

    proc `$`: string =
      "rabbit:" & self.name & ":" & $self.age

  let rabbit = newRabbit("Fluffy", 3)
  var animals: seq[Animal] = @[
    Dog(name: "Sparky", age: 10),
    Cat(name: "Mitten", age: 10),
    rabbit
  ]
  for a in animals:
    echo a.vocalize()
    echo a.age_human_yrs()
  echo rabbit

