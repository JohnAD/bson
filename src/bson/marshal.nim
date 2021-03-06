import generators
import macros
import algorithm


macro marshal*(obj: typed, recurse=true): untyped =
  ## This macro creates one or more pairs of procedures to easily convert
  ## the object type passed to/from BSON.
  ##
  ## The pair of new procedures are:
  ##
  ## *  ``pull(v: var T, doc: Bson)``
  ## *  ``toBson(v: T): Bson``
  ##
  ## Where T is the object type.
  ##
  ## An example:
  ##
  ## .. code:: nim
  ##
  ##     import bson
  ##     import bson/marshal
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
  ##     var b = @@{"displayName": "Bob", "weight": 95.3, "thePet": {"shortName": "Whiskers"}}
  ##
  ##     # Bson-to-object
  ##     u.pull(b)
  ##     assert u.thePet.shortName == "Whiskers"
  ##
  ##     # object-to-Bson
  ##     let newBson = u.toBson
  ##     assert newBson["weight"] == 95.3
  ## 
  ## By design, the procedures are created to be very forgiving. If field names or
  ## types don't match, in either the object or the BSON document, they are
  ## simply ignored.
  ##
  ## **DEALING WITH RECURSION**
  ##
  ## By default, the ``recurse`` parameter is set to ``true``. This means that the macro
  ## will not only create the pair of procedures for the ``obj`` object type, it will
  ## also create them for any other objects that the ``obj``'s fields reference.
  ##
  ## Internally, if the ``obj`` references another object multiple times, this is
  ## accounted for.
  ##
  ## However, if the macro is called again on another object and that object *also*
  ## references an object already referenced by the first one, then you will likely
  ## get a ``Error: redefinition of 'pull'; previous declaration here``... error from the compiler.
  ## To avoid that, you might need to set "recurse=false" for some or all of the macro calls.
  ##
  ## For example:
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
  ##       Dwelling = object
  ##         pets: seq[Pet]
  ##
  ##     marshal(User)
  ##     marshal(Dwelling)
  ##
  ## will generate a compiler error, but:
  ##
  ## .. code:: nim
  ##
  ##     marshal(User)
  ##     marshal(Dwelling, recurse=false)
  ##
  ## will compile fine. Also:
  ##
  ## .. code:: nim
  ##
  ##     marshal(Pet, recurse=false)
  ##     marshal(User, recurse=false)
  ##     marshal(Dwelling, recurse=false)
  ##
  ## also works. But note that ``marshal(Pet, recurse=false)`` was called first.
  ## The ``marshall(User, recurse=false)`` expects the procedures for ``Pet`` to already
  ## be defined. Order matters a great deal.
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

