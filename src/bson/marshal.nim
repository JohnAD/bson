import bson
import generators
import macros
import algorithm


macro marshal*(obj: typed, recurse=true): untyped =
  ## This macro creates one or more pairs of procedures to easily for the object
  ## type passed.
  ##
  ## The pairs of new procedures are:
  ##
  ## *  ``pull(v: var T, doc: Bson) =``  *which converts Bson to Object*
  ## *  ``toBson(v: T): Bson =``  *which converts Object to Bson*
  ##
  ## Where T is the object (or object referenced by the object.)
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
  ##     marshal(User)
  ##     
  ##     # Now, the following procedures exist:
  ##     #   pull(v: User, doc: Bson)
  ##     #   pull(v: Pet, doc: Bson)
  ##     #   toBson(v: User): Bson
  ##     #   toBson(v: Pet): Bson
  ##
  ##     var u = User()
  ##
  ##     var b = @@{"displayName": "Bob", "weight": 95.3, "thePet": {"shortName": "Whiskers"}}
  ##
  ##     u.pull(b)
  ##
  ##     assert u.thePet.shortName == "Whiskers"
  ## 
  ## By design, the procedures created are very forgiving. If field names or
  ## types don't match, in either the object or the BSON document, they are
  ## simply ignored.
  result = newStmtList()
  #
  let typeDef = getImpl(obj)
  var objReprs: seq[ObjRepr]
  let typeName = $obj
  bsonObjectNamesRegistry.add typeName  # needed to handle recursive object references
  #
  # scan passed-in object type and any sub-objects
  #
  let primeObjRepr = typeDef.toObjRepr()
  var blindness: bool
  if $recurse == "true":
    blindness = false
    let subObjects = listSubObjects(primeObjRepr)
    for subObj in subObjects.reversed:
      objReprs.add subObj
  else:
    blindness = true
  # order matters; add the main object LAST
  objReprs.add primeObjRepr
  #
  # add "proc pull(obj: var T, doc: Bson)"
  #
  let bsonToObjectSource = genBsonToObject(objReprs, blind=blindness)
  # echo bsonToObjectSource
  let bsonToObjectCode = parseStmt(bsonToObjectSource)
  result.add(bsonToObjectCode)
  #
  # add "proc toBson(obj: T): Bson"
  #
  let objectToBsonSource = genObjectToBson(objReprs, blind=blindness)
  # echo objectToBsonSource
  let objectToBsonCode = parseStmt(objectToBsonSource)
  result.add(objectToBsonCode)
  #
  bsonObjectNamesRegistry = @[]  # clean up after ourselves

