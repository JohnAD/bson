import
  algorithm,
  strutils,
  macros,
  typetraits,
  tables

## This file contains source code generation procedures. It is used both externaly
## by other libraries (such as `norm`), as well as internally by the ``bson`` library
## for marshaling.


type
  PragmaKind* = enum
    ## There are two kinds of pragmas: flags and key-value pairs:

    pkFlag, pkKval

  PragmaRepr* = object
    ## A container for pragma definition components.
    ## For flag pragmas, only the pragma name is stored. For key-value pragmas,
    ## name and value are stored.
    name*: string
    case kind*: PragmaKind
    of pkFlag: discard
    of pkKval: value*: NimNode

  SignatureRepr* = object
    ## Representation of the part of an object or field definition that contains:
    ##   - name
    ##   - exported flag
    ##   - pragmas
    ##
    ## .. code-block::
    ##
    ##     type
    ##     # Object signature is parsed from this part:
    ##     # |                        |
    ##       Example {.pr1, pr2: val2.} = object
    ##       # Field signature is parsed from this part:
    ##       # |                       |
    ##         field1 {.pr3, pr4: val4.}: int

    name*: string
    exported*: bool
    pragmas*: seq[PragmaRepr]

  FieldRepr* = object
    ## Object field representation: signature + type.

    signature*: SignatureRepr
    typ*: NimNode

  ObjRepr* = object
    ## Object representation: signature + fields.

    signature*: SignatureRepr
    fields*: seq[FieldRepr]


# compile-time globals
var
  bsonObjectNamesRegistry* {.compileTime.}: seq[string] = @[]
  varCounter {.compileTime.}: int = 1
  bsonBasicTypeList {.compileTime.} = @[
    "float",
    "string",
    "Oid",
    "bool",
    "Time",
    "int"
  ]
  nimTypeToBsonKind {.compileTime.} = {
    "float": "BsonKindDouble",
    "string": "BsonKindStringUTF8",
    "Oid": "BsonKindOid",
    "bool": "BsonKindBool",
    "Time": "BsonKindTimeUTC",
    "int": "BsonKindInt64, BsonKindInt32"
  }.toTable
  nimTypeToBsonProc {.compileTime.} = {
    "float": "toFloat64",
    "string": "toString",
    "Oid": "toOid",
    "bool": "toBool",
    "Time": "toTime",
    "int": "toInt"
  }.toTable


proc reconstructType(n: NimNode): string =
  ## For the node passed in, generate a normalized string representation of the type.
  ## This function handles both plain types as well as compound types such as seq[T] and Option[T].
  if n.kind in @[nnkIdent, nnkSym]:
    result = $n
  elif n.kind == nnkBracketExpr:
    var inner = ""
    if n[1].kind == nnkBracketExpr:
      inner = reconstructType(n[1])
    else:
      inner = $n[1]
    result = "$1[$2]".format($n[0], inner)
  else:
    result = "unknown"


proc seqTypeNames(name: string): seq[string] = 
  ## Turn a bracketed string type and turn it into a sequence of elements.
  ## For example: seq[Option[int]] would become @["seq", "Option", "int"]
  var
    s = name
    temp: seq[string] 

  while true:
    if '[' in s:
      temp = split(s, '[', 1)
      result.add temp[0]
      if len(temp)==1:
        break
      s = temp[1]
      if ']' in s:
        temp = rsplit(s, ']', 1)
        s = temp[0]
    else:
      break
      
  result.add s


proc restoreSeqType(s: seq[string]): string = 
  ## The opposite of seqTypeNames, turns a sequence of parts back
  ## into a string. Used for building intermediate conditions in applyBson.
  var
    temp = reversed(s)
  for index, entry in temp.pairs():
    if index==0:
      result = entry
    else:
      result = "$1[$2]".format(entry, result)


proc toPragmaReprs(pragmaDefs: NimNode): seq[PragmaRepr] =
  ## Convert an ``nnkPragma`` node into a sequence of ``PragmaRepr`s.
  ## Special thanks to https://github.com/moigagoo and his ``norm`` library
  expectKind(pragmaDefs, nnkPragma)
  for pragmaDef in pragmaDefs:
    result.add case pragmaDef.kind
      of nnkIdent: PragmaRepr(kind: pkFlag, name: $pragmaDef)
      of nnkExprColonExpr: PragmaRepr(kind: pkKval, name: $pragmaDef[0], value: pragmaDef[1])
      else: PragmaRepr()


proc toSignatureRepr(def: NimNode): SignatureRepr =
  ## Convert a signature definition into a ``SignatureRepr``.
  ## Special thanks to https://github.com/moigagoo and his ``norm`` library
  expectKind(def[0], {nnkIdent, nnkIdentDefs, nnkPostfix, nnkPragmaExpr, nnkSym})
  case def[0].kind
    of nnkIdent:
      result.name = $def[0]
    of nnkIdentDefs:
      result.name = $def[0]
    of nnkPostfix:
      result.name = $def[0][1]
      result.exported = true
    of nnkPragmaExpr:
      expectKind(def[0][0], {nnkIdent, nnkSym, nnkPostfix})
      case def[0][0].kind
      of nnkIdent, nnkSym:
        result.name = $def[0][0]
      of nnkPostfix:
        result.name = $def[0][0][1]
        result.exported = true
      else: discard
      result.pragmas = def[0][1].toPragmaReprs()
    of nnkSym:
      result.name = $def[0]
    else: discard


# proc toObjRepr*(typeDef: NimNode): ObjRepr =
#   ## Convert an object type definition into an ``ObjRepr``.
#   ##
#   ## The "typeDef" is expected to represent a raw Type definition.
#   ##
#   ## Special thanks to https://github.com/moigagoo and his ``norm`` library
#   echo typeDef.treeRepr
#   result.signature = toSignatureRepr(typeDef)

#   expectKind(typeDef[2], nnkObjectTy)

#   for fieldDef in typeDef[2][2]:
#     var field = FieldRepr()
#     field.signature = toSignatureRepr(fieldDef)
#     field.typ = fieldDef[1]
#     result.fields.add field


proc toVarObjRepr*(typeDef: NimNode, typeName: string): ObjRepr =
  ## Convert an object type definition into an ``ObjRepr``.
  ##
  ## The "typeDef" is expected to represent a Type Impl of a variable or a type name
  ##
  ## Special thanks to https://github.com/moigagoo and his ``norm`` library
  result.signature = SignatureRepr()
  result.signature.name = typeName

  expectKind(typeDef, nnkObjectTy)

  for recList in typeDef:
    # echo ">> " & recList.treeRepr
    if recList.kind != nnkRecList:
      continue
    for fieldDef in recList:
      # echo ">>> " & fieldDef.treeRepr
      var field = FieldRepr()
      field.signature = toSignatureRepr(fieldDef)
      field.typ = fieldDef[1]
      result.fields.add field


proc listSubObjects*(obj: ObjRepr): seq[ObjRepr] =
  ## For any object, list any object in it fields (recursively) that
  ## have not yet been added to the compile-time registry.
  for field in obj.fields:
    # echo field.typ.treeRepr
    let fullTypeName = reconstructType(field.typ)
    let tseq = seqTypeNames(fullTypeName)
    let typeName = tseq[0]
    # echo tseq

    if typeName in bsonBasicTypeList:
      continue
    elif typeName=="seq":
      continue # TODO
    elif typeName=="Option":
      continue # TODO
    elif typeName=="N":
      continue # TODO
    else:
      if bsonObjectNamesRegistry.contains(typeName):
        continue
      else:
        let imp = getTypeImpl(field.typ)
        result.add imp.toVarObjRepr(typeName)


proc nextVar(prefix: string): string =
  ## get a new variable name
  result = prefix & $varCounter
  varCounter += 1


proc genBasicToBson(srcField, dest, typeName: string, tab: int, fromSeq = false): string =
  let t = spaces(tab)
  if typeName == "Oid":
    result &= t & "if $$$1 != \"000000000000000000000000\":\n".format(srcField)
    result &= t & "  $1 = toBson($2)\n".format(dest, srcField)
  elif typeName == "Time":
    result &= t & "if $1 != fromUnix(0):\n".format(srcField)
    result &= t & "  $1 = toBson($2)\n".format(dest, srcField)
  else:
    result &= t & "$1 = toBson($2)\n".format(dest, srcField)


proc genSeqToBson(fieldName, dest: string, typeList: seq[string], tab: int): string
proc genNToBson(fieldName, dest: string, typeList: seq[string], tab: int): string

proc genOptionToBson(fieldName, dest: string, typeList: seq[string], tab: int): string =
  let t = spaces(tab)
  if len(typeList) < 2:
    raise newException(
      KeyError, 
      "$1 as malformed type $2 at depth $3".format(fieldName, $typeList, tab)
    )
  let nextType = typeList[1]
  result &= t & "if $1.isNone:\n".format(fieldName)
  result &= t & "  $1 = null()\n".format(dest)
  result &= t & "else:\n"
  if nextType == "Option":
    result &= genOptionToBson("$1.get()".format(fieldName), dest, typeList[1 .. typeList.high], tab+2)
  elif nextType == "seq":
    result &= genSeqToBson("$1.get()".format(fieldName), dest, typeList[1 .. typeList.high], tab+2)
  elif nextType in bsonBasicTypeList:
    result &= genBasicToBson("$1.get()".format(fieldName), dest, nextType, tab+2)
  elif nextType in bsonObjectNamesRegistry:
    result &= t & "  $1 = $2.get().toBson()\n".format(dest, fieldName)
  elif nextType == "N":
    result &= genNToBson("$1.get()".format(fieldName), dest, typeList[1 .. typeList.high], tab+2)
  else:
    raise newException(
      KeyError, 
      "Field \"$1\"'s type of $2 is not known to bson library[1].".format(fieldName, nextType)
    )


proc genNToBson(fieldName, dest: string, typeList: seq[string], tab: int): string =
  let t = spaces(tab)
  if len(typeList) < 2:
    raise newException(
      KeyError, 
      "$1 as malformed type $2 at depth $3".format(fieldName, $typeList, tab)
    )
  let nextType = typeList[1]
  result &= t & "if $1.isNull:\n".format(fieldName)
  result &= t & "  $1 = null()\n".format(dest)
  result &= t & "elif $1.isNothing:\n".format(fieldName)
  result &= t & "  discard\n".format(dest)
  result &= t & "elif $1.hasError:\n".format(fieldName)
  result &= t & "  $1 = null()\n".format(dest)
  result &= t & "else:\n"
  if nextType == "Option":
    result &= genOptionToBson("$1.getValue()".format(fieldName), dest, typeList[1 .. typeList.high], tab+2)
  elif nextType == "seq":
    result &= genSeqToBson("$1.getValue()".format(fieldName), dest, typeList[1 .. typeList.high], tab+2)
  elif nextType in bsonBasicTypeList:
    result &= genBasicToBson("$1.getValue()".format(fieldName), dest, nextType, tab+2)
  elif nextType in bsonObjectNamesRegistry:
    result &= t & "  $1 = $2.get().toBson()\n".format(dest, fieldName)
  elif nextType == "N":
    result &= genNToBson("$1.getValue()".format(fieldName), dest, typeList[1 .. typeList.high], tab+2)
  else:
    raise newException(
      KeyError, 
      "Field \"$1\"'s type of $2 is not known to the bson library[2].".format(fieldName, nextType)
    )

proc genSeqToBson(fieldName, dest: string, typeList: seq[string], tab: int): string =
  let t = spaces(tab)

  if len(typeList) < 2:
    raise newException(
      KeyError, 
      "$1 as malformed type $2 at depth $3".format(fieldName, $typeList, tab)
    )
  let nextType = typeList[1]
  let entry = nextVar("entry")
  let inner = nextVar("inner")
  # let innerTypeName = restoreSeqType(typeList[1 .. typeList.high])

  result &= t & "$1 = newBsonArray()\n".format(dest)
  result &= t & "for $1 in $2:\n".format(entry, fieldName)
  if nextType == "Option":
    result &= t & "  var $1 = null()\n".format(inner)
    result &= genOptionToBson(entry, inner, typeList[1 .. typeList.high], tab+2)
  elif nextType == "seq":
    result &= t & "  var $1 = null()\n".format(inner)
    result &= genSeqToBson(entry, inner, typeList[1 .. typeList.high], tab+2)
  elif nextType in bsonBasicTypeList:
    result &= t & "  var $1 = null()\n".format(inner)
    result &= genBasicToBson(entry, inner, nextType, tab+2, fromSeq=true)
  elif nextType in bsonObjectNamesRegistry:
    result &= t & "  var $1 = toBson($2, force)\n".format(inner, entry)
  elif nextType == "N":
    result &= genNToBson(entry, inner, typeList[1 .. typeList.high], tab+2)
  else:
    raise newException(
      KeyError, 
      "Field \"$2\"'s type of $2 is not known to the bson library[3].".format(fieldName, nextType)
    )
  result &= t & "  $1.add $2\n".format(dest, inner)


proc genObjectToBson*(dbObjReprs: seq[ObjRepr]): string =
  ## this procedure generates new procedures the convert the values in an
  ## existing "type" object to a BSON object.
  ## So, for example, with object defined as:
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
  ## you will get a string containing procedures similar to:
  ##
  ## .. code:: nim
  ##
  ##     proc toBson(obj: Pet, force = false): Bson {.used.} =
  ##       result = newBsonDocument()
  ##       result["shortName"] = toBson(obj.shortName)
  ##     proc toBson(obj: User, force = false): Bson {.used.} =
  ##       result = newBsonDocument()
  ##       result["displayName"] = toBson(obj.displayName)
  ##       if obj.weight.isNone:
  ##         result["weight"] = null()
  ##       else:
  ##         result["weight"] = toBson(obj.weight.get())
  ##       result["thePet"] = toBson(obj.thePet, force)
  var
    proc_map = initOrderedTable[string, string]() # object: procedure string
    objectName = ""
    fullTypeName = ""
    typeName = ""
    fieldName = ""
    bsonFieldName = ""
    key = ""
    tab = 2
    typeList: seq[string] = @[]

  #
  # generate one toBson per object
  #
  for obj in dbObjReprs:
    objectName = obj.signature.name
    key = objectName
    proc_map[key] =  "proc toBson(obj: $1, force = false): Bson {.used.} =\n".format(objectName)
    proc_map[key] &= "  result = newBsonDocument()\n"
    proc_map[key] &= "\n"
    #
    for field in obj.fields:
      fullTypeName = reconstructType(field.typ)
      typeList = seqTypeNames(fullTypeName)
      typeName = typeList[0]
      fieldName = field.signature.name
      bsonFieldName = fieldName
      for p in field.signature.pragmas:
        if p.name=="dbCol":
          bsonFieldName = $p.value
      if bsonBasicTypeList.contains(typeName):
        proc_map[key] &= genBasicToBson("obj.$1".format(fieldName), "result[\"$1\"]".format(bsonFieldName), typeName, tab)
      elif typeName=="seq":
        proc_map[key] &= genSeqToBson("obj.$1".format(fieldName), "result[\"$1\"]".format(bsonFieldName), typeList, tab)
      elif typeName=="Option":
        proc_map[key] &= genOptionToBson("obj.$1".format(fieldName), "result[\"$1\"]".format(bsonFieldName), typeList, tab)
      elif typeName=="N":
        proc_map[key] &= genNToBson("obj.$1".format(fieldName), "result[\"$1\"]".format(bsonFieldName), typeList, tab)
      else:
        if bsonObjectNamesRegistry.contains(typeName):
          proc_map[key] &= "  result[\"$1\"] = toBson(obj.$1, force)\n".format(fieldName)
        else:
          raise newException(
            KeyError, 
            "In object $1, the field $2's type is not known to the bson library[4]. If it is a subtending object, is $3 defined by dB, dbAddCollection, or dbAddObject yet?".format(objectName, fieldName, typeName)
          )
  #
  # finish up all procedure strings
  #
  for key, s in proc_map.pairs():
    result &= s
    result &= "\n" # add a blank line between each proc


proc genBsonToBasic(
  src, fieldName, typeName: string, 
  tab: int,
  skipCheck = false, 
  fromSeq = false,
  fromOption = false,
  fromN = false
): string =
  let t = spaces(tab)
  var assignment = " ="
  if fromOption:
    assignment &= " some"
  if fromN:
    assignment = ".set"
  if skip_check:
    result &= t & "if $1.kind in @[$2]:\n".format(src, nimTypeToBsonKind[typeName])
    result &= t & "  $1$2 $3.$4\n".format(fieldName, assignment, src, nimTypeToBsonProc[typeName])
  else:
    result &= t & "if not $1.isNil:\n".format(src)
    result &= t & "  if $1.kind in @[$2]:\n".format(src, nimTypeToBsonKind[typeName])
    result &= t & "    $1$2 $3.$4\n".format(fieldName, assignment, src, nimTypeToBsonProc[typeName])

proc genBsonToSeq(src, fieldName: string, typeList: seq[string], tab:int, skipCheck=false, fromSeq=false, fromOption=false): string
proc genBsonToN(src, fieldName: string, typeList: seq[string], tab:int, skipCheck=false, fromSeq=false, fromOption=false): string

proc genBsonToOption(src, fieldName: string, typeList: seq[string], tab:int, skipCheck=false, fromSeq=false, fromOption=false): string =
  let t = spaces(tab)

  if len(typeList) < 2:
    raise newException(
      KeyError, 
      "$1 has a malformed type $2 at depth $3".format(fieldName, $typeList, tab)
    )
  let nextType = typeList[1]
  let subTypeName = restoreSeqType(typeList[1 .. typeList.high])
  var assignment = " ="

  # result &= t & "# INSIDE genBsonToOption Option next=$1\n".format(nextType)

  if skipCheck:
    result &= t & "if $1.kind == BsonKindNull:\n".format(src)
    result &= t & "  $1$2 none($3)\n".format(fieldName, assignment, subTypeName)
    if nextType in bsonBasicTypeList:
      result &= genBsonToBasic(
        src,
        fieldName,
        nextType,
        tab,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=true,
        fromN=false
      )
    elif nextType in bsonObjectNamesRegistry:
      let temp = nextVar("temp")
      result &= t & "else:\n"
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= t & "  applyBson($1, $2)\n".format(temp, src)
      result &= t & "  $1$2 some $3\n".format(fieldName, assignment, temp)
    elif nextType=="seq":
      result &= t & "else:\n"
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToSeq(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=true
      )
      result &= t & "  $1 = some $2\n".format(fieldName, temp)
    elif nexttype=="Option":
      raise newException(RangeError, "MongoDb library cannot directly nested Option[Option[T]] sequences as they are not translatable to BSON. (Option[$1])".format(subTypeName))
    elif nexttype=="N":
      result &= t & "else:\n"
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToN(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=true
      )
      result &= t & "  $1 = some $2\n".format(fieldName, temp)
  else:
    result &= t & "if not $1.isNil:\n".format(src)
    result &= t & "  if $1.kind == BsonKindNull:\n".format(src)
    result &= t & "    $1$2 none($3)\n".format(fieldName, assignment, subTypeName)
    if nextType in bsonBasicTypeList:
      result &= genBsonToBasic(
        src,
        fieldName,
        nextType,
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=true,
        fromN=false
      )
    elif nextType in bsonObjectNamesRegistry:
      let temp = nextVar("temp")
      result &= t & "  else:\n"
      result &= t & "    var $1: $2\n".format(temp, subTypeName)
      result &= t & "    applyBson($1, $2)\n".format(temp, src)
      result &= t & "    $1$2 some $3\n".format(fieldName, assignment, temp)
    elif nextType=="seq":
      let temp = nextVar("temp")
      result &= t & "  else:\n"
      result &= t & "    var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToSeq(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+4,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=true
      )
      result &= t & "    $1 = some $2\n".format(fieldName, temp)
    elif nexttype=="Option":
      raise newException(RangeError, "MongoDb library cannot directly nested Option[Option[T]] sequences as they are not translatable to BSON. (Option[$1])".format(subTypeName))
    elif nexttype=="N":
      let temp = nextVar("temp")
      result &= t & "  else:\n"
      result &= t & "    var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToN(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+4,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=true
      )
      result &= t & "    $1 = some $2\n".format(fieldName, temp)

proc genBsonToN(src, fieldName: string, typeList: seq[string], tab:int, skipCheck=false, fromSeq=false, fromOption=false): string =
  let t = spaces(tab)

  if len(typeList) < 2:
    raise newException(
      KeyError, 
      "$1 has a malformed type $2 at depth $3".format(fieldName, $typeList, tab)
    )
  let nextType = typeList[1]
  let subTypeName = restoreSeqType(typeList[1 .. typeList.high])
  var assignment = " ="

  # result &= t & "# INSIDE genBsonToOption Option next=$1\n".format(nextType)

  if skipCheck:
    result &= t & "if $1.kind == BsonKindNull:\n".format(src)
    result &= t & "  $1$2 null($3)\n".format(fieldName, assignment, subTypeName)
    if nextType in bsonBasicTypeList:
      result &= genBsonToBasic(
        src,
        fieldName,
        nextType,
        tab,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false,
        fromN=true
      )
    elif nextType in bsonObjectNamesRegistry:
      let temp = nextVar("temp")
      result &= t & "else:\n"
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= t & "  applyBson($1, $2)\n".format(temp, src)
      result &= t & "  $1$2 $3\n".format(fieldName, assignment, temp)
    elif nextType=="seq":
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToSeq(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false
      )
      result &= t & "  $1 = $2\n".format(fieldName, temp)
    elif nexttype=="Option":
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToOption(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false
      )
      result &= t & "  $1 = $2\n".format(fieldName, temp)
    elif nexttype=="N":
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToN(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false
      )
      result &= t & "  $1 = $2\n".format(fieldName, temp)
  else:
    result &= t & "if $1.isNil:\n".format(src)
    result &= t & "  $1$2 nothing($3)\n".format(fieldName, assignment, subTypeName)
    result &= t & "else:\n"
    result &= t & "  if $1.kind == BsonKindNull:\n".format(src)
    result &= t & "    $1$2 null($3)\n".format(fieldName, assignment, subTypeName)
    if nextType in bsonBasicTypeList:
      result &= genBsonToBasic(
        src,
        fieldName,
        nextType,
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false,
        fromN=true
      )
    elif nextType in bsonObjectNamesRegistry:
      let temp = nextVar("temp")
      result &= t & "  else:\n"
      result &= t & "    var $1: $2\n".format(temp, subTypeName)
      result &= t & "    applyBson($1, $2)\n".format(temp, src)
      result &= t & "    $1$2 $3\n".format(fieldName, assignment, temp)
    elif nextType=="seq":
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToSeq(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false
      )
      result &= t & "  $1 = $2\n".format(fieldName, temp)
    elif nexttype=="Option":
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToOption(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false
      )
      result &= t & "  $1 = $2\n".format(fieldName, temp)
    elif nexttype=="N":
      let temp = nextVar("temp")
      result &= t & "  var $1: $2\n".format(temp, subTypeName)
      result &= genBsonToN(
        src, 
        temp, 
        typeList[1 .. typeList.high],
        tab+2,
        skipCheck=true,
        fromSeq=fromSeq,
        fromOption=false
      )
      result &= t & "  $1 = $2\n".format(fieldName, temp)


proc genBsonToSeq(src, fieldName: string, typeList: seq[string], tab:int, skipCheck=false, fromSeq=false, fromOption=false): string =
  let t = spaces(tab)

  if len(typeList) < 2:
    raise newException(
      KeyError, 
      "$1 has a malformed type $2 at depth $3".format(fieldName, $typeList, tab)
    )
  let nextType = typeList[1]
  let subTypeName = restoreSeqType(typeList[1 .. typeList.high])
  let item = nextVar("item")
  # result &= t & "# INSIDE genBsonToSeq seq next=$1\n".format(nextType)
  let inner = nextVar("inner")
  if skipCheck:
    result &= t & "for $1 in $2.items:\n".format(item, src)
    result &= t & "  var $1: $2\n".format(inner, subTypeName)
    if nextType in bsonBasicTypeList:
      result &= genBsonToBasic(item, inner, nextType, tab+2, skipCheck=true, fromSeq=true)
    elif nextType in bsonObjectNamesRegistry:
      result &= t & "  applyBson($1, $2)\n".format(inner, item)
    elif nextType == "seq":
      result &= genBsontoSeq(item, inner, typeList[1 .. typeList.high], tab+2, skipCheck=true, fromSeq=false)
    elif nextType == "Option":
      result &= genBsontoOption(item, inner, typeList[1 .. typeList.high], tab+2, skipCheck=true, fromSeq=false)
    elif nextType == "N":
      result &= genBsontoN(item, inner, typeList[1 .. typeList.high], tab+2, skipCheck=true, fromSeq=false)
    result &= t & "  $1.add $2\n".format(fieldName, inner) # if we are in the loop, we ALWAYS add an item for each iteration
  else:
    result &= t & "if not $1.isNil:\n".format(src)
    result &= t & "  $1 = @[]\n".format(fieldName)
    result &= t & "  for $1 in $2.items:\n".format(item, src)
    result &= t & "    var $1: $2\n".format(inner, subTypeName)
    if nextType in bsonBasicTypeList:
      result &= genBsonToBasic(item, inner, nextType, tab+4, skipCheck=true, fromSeq=true)
    elif nextType in bsonObjectNamesRegistry:
      result &= t & "    applyBson($1, $2)\n".format(inner, item)
    elif nextType == "seq":
      result &= genBsontoSeq(item, inner, typeList[1 .. typeList.high], tab+4, skipCheck=true, fromSeq=true)
    elif nextType == "Option":
      result &= genBsontoOption(item, inner, typeList[1 .. typeList.high], tab+4, skipCheck=true, fromSeq=true)
    elif nextType == "N":
      result &= genBsontoN(item, inner, typeList[1 .. typeList.high], tab+4, skipCheck=true, fromSeq=true)
    result &= t & "    $1.add $2\n".format(fieldName, inner) # if we are in the loop, we ALWAYS add an item for each iteration


proc genBsonToObject*(dbObjReprs: seq[ObjRepr]): string =
  ## this procedure generates new procedures that map values found in an
  ## existing "type" object to a Bson object.
  ## So, for example, with object defined as:
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
  ## you will get a string containing procedures similar to:
  ##
  ## .. code:: nim
  ##
  ##     proc applyBson(obj: var Pet, doc: Bson) {.used.} =
  ##       discard
  ##       if not doc["shortName"].isNil:
  ##         if doc["shortName"].kind in @[BsonKindStringUTF8]:
  ##           obj.shortName = doc["shortName"].toString
  ##     proc applyBson(obj: var User, doc: Bson) {.used.} =
  ##       discard
  ##       if not doc["displayName"].isNil:
  ##         if doc["displayName"].kind in @[BsonKindStringUTF8]:
  ##           obj.displayName = doc["displayName"].toString
  ##       if not doc["weight"].isNil:
  ##         if doc["weight"].kind == BsonKindNull:
  ##           obj.weight = none(float)
  ##         if doc["weight"].kind in @[BsonKindDouble]:
  ##           obj.weight = some doc["weight"].toFloat64
  ##       if doc.contains("thePet"):
  ##         obj.thePet = Pet()
  ##         applyBson(obj.thePet, doc["thePet"])
  var
    proc_map = initOrderedTable[string, string]() # object: procedure string
    objectName = ""
    typeName = ""
    fieldName = ""
    bsonFieldName = ""
    key = ""

  #
  # now generate one applyBson per object
  #
  for obj in dbObjReprs:
    objectName = obj.signature.name
    key = objectName
    proc_map[key] =  "proc applyBson(obj: var $1, doc: Bson) {.used.} =\n".format(objectName)
    proc_map[key] &= "  if doc.kind != BsonKindDocument:\n"
    proc_map[key] &= "    return\n"
    #
    #
    for field in obj.fields:
      let fullTypeName = reconstructType(field.typ)
      var tseq = seqTypeNames(fullTypeName)
      typeName = tseq[0]
      fieldName = field.signature.name
      bsonFieldName = fieldName
      # proc_map[key] &= "  #START: $1\n".format($tseq)
      for p in field.signature.pragmas:
        if p.name=="dbCol":
          bsonFieldName = $p.value
      if typeName in bsonBasicTypeList:
        proc_map[key] &= genBsonToBasic(
          "doc[\"$1\"]".format(bsonFieldName), "obj.$1".format(fieldName), typeName, 2,
          skipCheck=false, fromSeq=false, fromOption=false
        )
      elif typeName=="seq":
        proc_map[key] &= genBsonToSeq(
          "doc[\"$1\"]".format(bsonFieldName), "obj.$1".format(fieldName), tseq, 2,
          skipCheck=false, fromSeq=false, fromOption=false
        )
      elif typeName=="Option":
        proc_map[key] &= genBsonToOption(
          "doc[\"$1\"]".format(bsonFieldName), "obj.$1".format(fieldName), tseq, 2,
          skipCheck=false, fromSeq=false, fromOption=false
        )
      elif typeName=="N":
        proc_map[key] &= genBsonToN(
          "doc[\"$1\"]".format(bsonFieldName), "obj.$1".format(fieldName), tseq, 2,
          skipCheck=false, fromSeq=false, fromOption=false
        )
      else:
        if bsonObjectNamesRegistry.contains(typeName):
          proc_map[key] &= "  if doc.contains(\"$1\"):\n".format(fieldName)
          proc_map[key] &= "    obj.$1 = $2()\n".format(fieldName, typeName)
          proc_map[key] &= "    applyBson(obj.$1, doc[\"$1\"])\n".format(fieldName)
  #
  # finish up all procedure strings
  #
  for key, s in proc_map.pairs():
    result &= s
    result &= "\n" # add a blank line between each proc



