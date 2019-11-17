import bson
import generators
import macros
import algorithm


proc meta_build(stmts: var NimNode, typeName: string, typeDef: NimNode) =
  # this is a private procedure for generating the new procedures for marshaling
  # in a dynamic manner.
  if bsonObjectNamesRegistry.contains(typeName):
    # echo "already have $1.".format(typeName)
    discard
  else:
    #
    # scan passed-in object type and any sub-objects
    #
    var objReprs: seq[ObjRepr]
    let primeObjRepr = typeDef.toVarObjRepr(typeName)
    let subObjects = listSubObjects(primeObjRepr)
    for subObj in subObjects.reversed:
      objReprs.add subObj
      bsonObjectNamesRegistry.add subObj.signature.name
      # echo "added subobject $1".format(subObj.signature.name)
    # order matters; add the main object LAST
    objReprs.add primeObjRepr
    bsonObjectNamesRegistry.add typeName
    #
    # add "proc applyBson(obj: var T, doc: Bson)"
    #
    let bsonToObjectSource = genBsonToObject(objReprs)
    # echo bsonToObjectSource
    let bsonToObjectCode = parseStmt(bsonToObjectSource)
    stmts.add(bsonToObjectCode)
    #
    # add "proc toBson(obj: Pet, force = false): Bson"
    #
    let objectToBsonSource = genObjectToBson(objReprs)
    # echo objectToBsonSource
    let objectToBsonCode = parseStmt(objectToBsonSource)
    stmts.add(objectToBsonCode)


macro pull*(varobj: typed, bd: Bson): untyped =
  ## This macro "pulls" the values from the BSON document and copies them
  ## to the corresponding fields of the object, including any subtending objects.
  ##
  ## By design, this macro is very forgiving. If field names or types don't match,
  ## in either the object or the BSON document, they are simply ignored.
  ##
  ## Example of use:
  ##
  ## .. code:: nim
  ##
  ##     type
  ##       Pet = object
  ##         shortName: string
  ##       User = object
  ##         displayName: string
  ##         weight: Option[float]
  ##         thePet: Pet
  ##
  ##     var u = User()
  ##
  ##     var b = @@{"displayName": "Bob", "weight": 95.3, "thePet": {"shortName": "Whiskers"}}
  ##
  ##     pull(u, b)
  ##
  ##     assert u.thePet.shortName == "Whiskers"
  ##  
  ## **SIDE** **EFFECT**: as a secondary side effect of running this macro, a
  ## pair of new functions called
  ##   ``applyBson(v: T, doc: Bson) =``
  ## and
  ##   ``toBson(v: T): Bson =``
  ## with the specific object type of the variable are created the first time
  ## this macro (or the ``toBson`` macro) is invoked.
  ##
  ## Calling this or the other macro multiple times does not cause a problem.
  ##
  ## You can, for the remainder of the local source code file, also call
  ## those functions directly.
  result = newStmtList()

  let typeInst = getTypeInst(varobj)
  let typeName = $typeInst
  # echo typeName
  let typeDef = getTypeImpl(varobj)

  meta_build(result, typeName, typeDef)

  result.add quote do:
    applyBson(`varobj`, `bd`)


macro toBson*(varobj: object): Bson =
  ## This macro creates a new BSON document that has the corresonding fields
  ## and values.
  ##
  ## By design, this process is very forgiving. If a nim field type is encountered that
  ## does not have a known conversion to BSON, it is simply skipped.
  ##
  ## Example of use:
  ##
  ## .. code:: nim
  ##
  ##     type
  ##       Pet = object
  ##         shortName: string
  ##       User = object
  ##         displayName: string
  ##         weight: Option[float]
  ##         thePet: Pet
  ##
  ##     var a = Pet()
  ##     a.shortName = "Bowser"
  ##   
  ##     var u = User()
  ##     u.displayName = "Joe"
  ##     u.weight = some(45.3)
  ##     u.thePet = a
  ##
  ##     var newBDoc = u.toBson()
  ##
  ##     assert newBDoc["thePet"]["shortName"] == "Bowser"
  ##  
  ## **SIDE** **EFFECT**: as a secondary side effect of running this macro, a
  ## pair of new functions called
  ##   ``applyBson(v: T, doc: Bson) =``
  ## and
  ##   ``toBson(v: T): Bson =``
  ## with the specific object type of the variable are created the first time
  ## this macro (or the ``pull`` macro) is invoked.
  ##
  ## Calling this or the other macro multiple times does not cause a problem.
  ##
  ## You can, for the remainder of the local source code file, also call
  ## those functions directly.

  result = newStmtList()

  let typeInst = getTypeInst(varobj)
  let typeName = $typeInst
  echo typeName
  let typeDef = getTypeImpl(varobj)
  echo typeDef.treeRepr

  meta_build(result, typeName, typeDef)

  result.add newCall("toBson", varobj)


when isMainModule:
  import options
  echo "starting..."

  type
    Pet = object
      shortName: string
    User = object
      displayName: string
      weight: Option[float]
      thePet: Pet


  # TODO: add Option, seq, N support to listSubObjects
  # TODO: check: does @@ in bson.nim conflict; should it demand a {} pattern?

  var a = Pet()
  a.shortName = "beforeName"

  var u = User()
  u.displayName = "manno"
  u.weight = some(45.3)
#  u.thePet = a

  var b = newBsonDocument()
  b["displayName"] = "mannoAfter"
  b["weight"] = 95.0
  b["thePet"] = newBsonDocument()
  b["thePet"]["shortName"] = "afterName"

  pull(u, b)
  b["thePet"]["shortName"] = "try2Name"
  pull(u, b)

  echo u.thePet.shortName

  var bdoc = u.toBson
  echo bdoc

  var bdoca = @@{"astring": "blah", "anint": 3, "afloat": 3.14}
  echo bdoca
