bson/generators Reference
==============================================================================

The following are the references for bson/generators.



Types
=====



.. _FieldRepr.type:
FieldRepr
---------------------------------------------------------

    .. code:: nim

        FieldRepr* = object
          signature*: SignatureRepr
          typ*: NimNode


    source line: `47 <../src/bson/generators.nim#L47>`__

    Object field representation: signature + type.


.. _ObjRepr.type:
ObjRepr
---------------------------------------------------------

    .. code:: nim

        ObjRepr* = object
          signature*: SignatureRepr
          fields*: seq[FieldRepr]


    source line: `53 <../src/bson/generators.nim#L53>`__

    Object representation: signature + fields.


.. _PragmaKind.type:
PragmaKind
---------------------------------------------------------

    .. code:: nim

        PragmaKind* = enum
          pkFlag, pkKval


    source line: `14 <../src/bson/generators.nim#L14>`__

    There are two kinds of pragmas: flags and key-value pairs


.. _PragmaRepr.type:
PragmaRepr
---------------------------------------------------------

    .. code:: nim

        PragmaRepr* = object
          name*: string
          case kind*: PragmaKind
          of pkFlag: discard
          of pkKval: value*: NimNode


    source line: `18 <../src/bson/generators.nim#L18>`__

    A container for pragma definition components.
    For flag pragmas, only the pragma name is stored. For key-value pragmas,
    name and value are stored.


.. _SignatureRepr.type:
SignatureRepr
---------------------------------------------------------

    .. code:: nim

        SignatureRepr* = object
          name*: string
          exported*: bool
          pragmas*: seq[PragmaRepr]


    source line: `27 <../src/bson/generators.nim#L27>`__

    Representation of the part of an object or field definition that contains:
      - name
      - exported flag
      - pragmas
    
    .. code-block::
    
        type
        # Object signature is parsed from this part:
        # |                        |
          Example {.pr1, pr2: val2.} = object
          # Field signature is parsed from this part:
          # |                       |
            field1 {.pr3, pr4: val4.}: int






Procs, Methods, Iterators
=========================


.. _genBsonToObject.p:
genBsonToObject
---------------------------------------------------------

    .. code:: nim

        proc genBsonToObject*(dbObjReprs: seq[ObjRepr], blind=false): string =

    source line: `814 <../src/bson/generators.nim#L814>`__

    this procedure generates new procedures that map values found in an
    existing "type" object to a Bson object.
    So, for example, with object defined as:
    
    .. code:: nim
    
        type
          Pet = object
            shortName: string
          User = object
            displayName: string
            weight: Option[float]
            thePet: Pet
    
    you will get a string containing procedures similar to:
    
    .. code:: nim
    
        proc pull(obj: var Pet, doc: Bson) {.used.} =
          discard
          if not doc["shortName"].isNil:
            if doc["shortName"].kind in @[BsonKindStringUTF8]:
              obj.shortName = doc["shortName"].toString
        proc pull(obj: var User, doc: Bson) {.used.} =
          discard
          if not doc["displayName"].isNil:
            if doc["displayName"].kind in @[BsonKindStringUTF8]:
              obj.displayName = doc["displayName"].toString
          if not doc["weight"].isNil:
            if doc["weight"].kind == BsonKindNull:
              obj.weight = none(float)
            if doc["weight"].kind in @[BsonKindDouble]:
              obj.weight = some doc["weight"].toFloat64
          if doc.contains("thePet"):
            obj.thePet = Pet()
            pull(obj.thePet, doc["thePet"])


.. _genObjectToBson.p:
genObjectToBson
---------------------------------------------------------

    .. code:: nim

        proc genObjectToBson*(dbObjReprs: seq[ObjRepr], blind=false): string =

    source line: `406 <../src/bson/generators.nim#L406>`__

    this procedure generates new procedures the convert the values in an
    existing "type" object to a BSON object.
    So, for example, with object defined as:
    
    .. code:: nim
    
        type
          Pet = object
            shortName: string
          User = object
            displayName: string
            weight: Option[float]
            thePet: Pet
    
    you will get a string containing procedures similar to:
    
    .. code:: nim
    
        proc toBson(obj: Pet): Bson {.used.} =
          result = newBsonDocument()
          result["shortName"] = toBson(obj.shortName)
        proc toBson(obj: User): Bson {.used.} =
          result = newBsonDocument()
          result["displayName"] = toBson(obj.displayName)
          if obj.weight.isNone:
            result["weight"] = null()
          else:
            result["weight"] = toBson(obj.weight.get())
          result["thePet"] = toBson(obj.thePet)


.. _listSubObjects.p:
listSubObjects
---------------------------------------------------------

    .. code:: nim

        proc listSubObjects*(obj: ObjRepr): seq[ObjRepr] =

    source line: `284 <../src/bson/generators.nim#L284>`__

    For any object, list any object in it fields (recursively) that
    have not yet been added to the compile-time registry.


.. _toObjRepr.p:
toObjRepr
---------------------------------------------------------

    .. code:: nim

        proc toObjRepr*(typeDef: NimNode): ObjRepr =

    source line: `181 <../src/bson/generators.nim#L181>`__

    Convert an object type definition into an ``ObjRepr``.
    
    The "typeDef" is expected to represent a raw Type definition.
    
    Special thanks to https://github.com/moigagoo and his ``norm`` library


.. _toVarObjRepr.p:
toVarObjRepr
---------------------------------------------------------

    .. code:: nim

        proc toVarObjRepr*(typeDef: NimNode, typeName: string): ObjRepr =

    source line: `199 <../src/bson/generators.nim#L199>`__

    Convert an object type definition into an ``ObjRepr``.
    
    The "typeDef" is expected to represent a Type Impl of a variable or a type name
    
    Special thanks to https://github.com/moigagoo and his ``norm`` library







Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
    B. `bson/marshal Reference <bson-marshal-ref.rst>`__
    C. `bson/generators Reference <bson-generators-ref.rst>`__
