## BSON
## 
## This is a Nim library for supporting BSON. BSON is short for Binary JSON -- a
## compact binary protocol similar to the JSON it is based on.
##
## Most notably, MongoDB, a document-oriented database uses BSON for it's
## underlying storage, though there are other applications that use it as well.
##
## More details about the protocol can be found at:
##
##     http://bsonspec.org/
##
## More detail can also be found in the reference document linked at the bottom.
## 
## CREATING A BSON DOCUMENT USING BRACKETS
## ---------------------------------------
##
## You can use a pair of '@@' symbols prefixing a pair of curly braces with json-like
## data in between to create a quick an easy BSON document.
##
## For example:
##
## .. code:: nim
##
##     var doc = @@{"name": "Joe", "age": 42, "siblings": ["Amy", "Jerry"]}
##
## CREATING A BSON DOCUMENT MANUALLY
## ---------------------------------
##
## Start building a BSON document by declaring a new document with 
## `newBsonDocument` and start building out items in that document as if
## were using a table.
##
## .. code:: nim
##
##     var doc = newBsonDocument()
##     doc["name"] = "Joe"
##     doc["age"] = 42
##
## You can also add sub elements such as lists (with `newBsonArray`) and other
## documents (with `newBsonDocument`):
## 
## .. code:: nim
##
##     doc["siblings"] = newBsonArray()
##     doc["siblings"].add "Amy"
##     doc["siblings"].add "Jerry"
##     doc["schedule"] = newBsonDocument()
##     doc["schedule"]["8am"] = "go to work"
##     doc["schedule"]["11am"] = "see dentist"
##
## GENERATING THE BSON CODE
## ------------------------
##
## To generate the actual binary code, such as to stream to a file or a service,
## use the 'bytes' function:
##
## .. code:: nim
##
##     var bString: string = doc.bytes()
##
## Please keep in mind that this is a **binary** **packed** string and is not printable.
##
## To convert a binary blob of data back into a Bson library document, pass
## the string into 'newBsonDocument' as a string parameter.
##
## .. code:: nim
##
##     var newDoc = newBsonDocument(bString)
##
##
## HANDLING TYPES
## --------------
##
## The BSON specification calls for 18 types of data (and a few subtypes).
##
## Not all of them are fully supported by the libary yet.
##
## =============================== ================= =========================== 
## BSON                            Nim Equiv         Notes                     
## =============================== ================= =========================== 
## 64-bit binary floating point    float             Nim defaults to 64 bit    
## UTF-8 string                    string            Nim strings are UTF-8 ready by default
## Embedded document               newBsonDocument   from this library. for key/value pairs, the key must always be a string   
## Array                           newBsonArray      technically a list, not an array, because you can mix types 
## Binary data                     string (binary)   not always printable, but works, see ``binstr``
## ObjectId                        Oid               from standard `oids library <https://nim-lang.org/docs/oids.html>`_
## Boolean "false"                 bool = false                               
## Boolean "true"                  bool = true                                
## UTC datetime                    Time              from standard `times library <https://nim-lang.org/docs/times.html>`_
## Null value                      null              from this library         
## Regular expression              regex()           from this library         
## DBPointer (deprecated)          dbref()           from this library         
## JavaScript code                 js()              from this library         
## JavaScript code w/ scope                                                   
## 32-bit integer                  int32                                      
## Timestamp                       BsonTimestamp     from this library         
## 64-bit integer                  int64                                      
## 128-bit decimal floating point                    would like to support !   
## Min key                                                                    
## Max key                                                                    
## =============================== ================= =========================== 
##
## Marshal
## =======
##
## There is a submodule called ``marshal``, that allows for the easy conversion
## of ``object`` types to/from BSON. It has a single macro: ``marshal`` which generates
## ``toBson`` and ``pull`` procedure for the object.
##
## An example:
##
## .. code:: nim
##
##     import bson
##     import bson/marshal
##     
##     type
##       User = object
##         name: string
##         height: Option[float]
##
##     marshal(User)
##     
##     var u = User()
##
##     var someBson = @@{"name": "Bob", "height": 95.3}
##
##     u.pull(someBson)
##
##     assert u.name == "Bob"
##
## See the *bson/marshal Reference* link in the Table of Contents below for more detail.
##
## Credit
## ======
##
## Large portions of this code were pulled from the nimongo project, a scalable
## pure-nim mongodb driver. See https://github.com/SSPkrolik/nimongo
##
## However, this library is NOT compatilible with nimongo, as nimongo relies on an
## internal implementation of BSON.



import base64
import macros
import md5
import oids
import streams
import strutils
import times
import tables

type BsonKind* = char

const
  BsonKindUnknown*         = 0x00.BsonKind  ##
  BsonKindDouble*          = 0x01.BsonKind  ## 64-bit floating-point
  BsonKindStringUTF8*      = 0x02.BsonKind  ## UTF-8 encoded C string
  BsonKindDocument*        = 0x03.BsonKind  ## Embedded document
  BsonKindArray*           = 0x04.BsonKind  ## Embedded array of Bson values
  BsonKindBinary*          = 0x05.BsonKind  ## Generic binary data
  BsonKindUndefined*       = 0x06.BsonKind  ## Some undefined value (deprecated)
  BsonKindOid*             = 0x07.BsonKind  ## Mongo Object ID
  BsonKindBool*            = 0x08.BsonKind  ## boolean value
  BsonKindTimeUTC*         = 0x09.BsonKind  ## int64 milliseconds (Unix epoch time)
  BsonKindNull*            = 0x0A.BsonKind  ## nil value stored in Mongo
  BsonKindRegexp*          = 0x0B.BsonKind  ## Regular expression and options
  BsonKindDBPointer*       = 0x0C.BsonKind  ## Pointer to 'db.col._id'
  BsonKindJSCode*          = 0x0D.BsonKind  ## -
  BsonKindDeprecated*      = 0x0E.BsonKind  ## -
  BsonKindJSCodeWithScope* = 0x0F.BsonKind  ## -
  BsonKindInt32*           = 0x10.BsonKind  ## 32-bit integer number
  BsonKindTimestamp*       = 0x11.BsonKind  ## -
  BsonKindInt64*           = 0x12.BsonKind  ## 64-bit integer number
  BsonKindMaximumKey*      = 0x7F.BsonKind  ## Maximum MongoDB comparable value
  BsonKindMinimumKey*      = 0xFF.BsonKind  ## Minimum MongoDB comparable value

type BsonSubtype* = char

const
  BsonSubtypeGeneric*      = 0x00.BsonSubtype  ##
  BsonSubtypeFunction*     = 0x01.BsonSubtype  ##
  BsonSubtypeBinaryOld*    = 0x02.BsonSubtype  ##
  BsonSubtypeUuidOld*      = 0x03.BsonSubtype  ##
  BsonSubtypeUuid*         = 0x04.BsonSubtype  ##
  BsonSubtypeMd5*          = 0x05.BsonSubtype  ##
  BsonSubtypeUserDefined*  = 0x80.BsonSubtype  ##

converter toChar*(bk: BsonKind): char =
  ## Convert BsonKind to char
  return bk.char

converter toChar*(sub: BsonSubtype): char =
  ## Convert BsonSubtype to char
  return sub.char

converter toBsonKind*(c: char): BsonKind =
  ## Convert char to BsonKind
  return c.BsonKind

# ------------- type: Bson -----------------------#

type
  BsonTimestamp* = object ## Internal MongoDB type used by mongos instances
    increment*: int32
    timestamp*: int32

  Bson* = ref object of RootObj  ## Bson Node
    case kind*: BsonKind
    of BsonKindDouble:           valueFloat64:     float64
    of BsonKindStringUTF8:       valueString:      string
    of BsonKindDocument:         valueDocument:    OrderedTable[string, Bson]
    of BsonKindArray:            valueArray:       seq[Bson]
    of BsonKindBinary:
      case subtype:                                BsonSubtype
      of BsonSubtypeGeneric:     valueGeneric:     string
      of BsonSubtypeFunction:    valueFunction:    string
      of BsonSubtypeBinaryOld:   valueBinOld:      string
      of BsonSubtypeUuidOld:     valueUuidOld:     string
      of BsonSubtypeUuid:        valueUuid:        string
      of BsonSubtypeMd5:         valueDigest:      MD5Digest
      of BsonSubtypeUserDefined: valueUserDefined: string
      else: discard
    of BsonKindUndefined:        discard
    of BsonKindOid:              valueOid:         Oid
    of BsonKindBool:             valueBool:        bool
    of BsonKindTimeUTC:          valueTime:        Time
    of BsonKindNull:             discard
    of BsonKindRegexp:
                                 regex:            string
                                 options:          string
    of BsonKindDBPointer:
                                 refCol:           string
                                 refOid:           Oid
    of BsonKindJSCode:           valueCode:        string
    of BsonKindDeprecated:       valueDepr:        string
    of BsonKindJSCodeWithScope:  valueCodeWS:      string
    of BsonKindInt32:            valueInt32:       int32
    of BsonKindTimestamp:        valueTimestamp:   BsonTimestamp
    of BsonKindInt64:            valueInt64:       int64
    of BsonKindMaximumKey:       discard
    of BsonKindMinimumKey:       discard
    else:                        discard

  GeoPoint = array[0..1, float64]   ## Represents Mongo Geo Point


proc raiseWrongNodeException(bs: Bson) =
  raise newException(Exception, "Wrong node kind: " & $ord(bs.kind))


proc `$`*(bs: Bson): string =
  ## Serialize Bson document into readable string
  proc stringify(bs: Bson, indent: string): string =
      if bs.isNil: return "null"
      case bs.kind
      of BsonKindDouble:
          return $bs.valueFloat64
      of BsonKindStringUTF8:
          return "\"" & bs.valueString & "\""
      of BsonKindDocument:
          var res = "{\n"
          let ln = bs.valueDocument.len
          var i = 0
          let newIndent = indent & "    "
          for k, v in bs.valueDocument:
              res &= newIndent
              res &= "\"" & k & "\" : "
              res &= stringify(v, newIndent)
              if i != ln - 1:
                  res &= ","
              inc i
              res &= "\n"
          res &= indent & "}"
          return res
      of BsonKindArray:
          var res = "[\n"
          let newIndent = indent & "    "
          for i, v in bs.valueArray:
              res &= newIndent
              res &= stringify(v, newIndent)
              if i != bs.valueArray.len - 1:
                  res &= ","
              res &= "\n"
          res &= indent & "]"
          return res
      of BsonKindBinary:
          case bs.subtype
          of BsonSubtypeMd5:
              return "{\"$$md5\": \"$#\"}" % [$bs.valueDigest]
          of BsonSubtypeGeneric:
              return "{\"$$bindata\": \"$#\"}" % [base64.encode(bs.valueGeneric)]
          of BsonSubtypeUserDefined:
              return "{\"$$bindata\": \"$#\"}" % [base64.encode(bs.valueUserDefined)]
          else:
              raiseWrongNodeException(bs)
      of BsonKindUndefined:
          return "undefined"
      of BsonKindOid:
          return "{\"$$oid\": \"$#\"}" % [$bs.valueOid]
      of BsonKindBool:
          return if bs.valueBool == true: "true" else: "false"
      of BsonKindTimeUTC:
          return $bs.valueTime
      of BsonKindNull:
          return "null"
      of BsonKindRegexp:
          return "{\"$$regex\": \"$#\", \"$$options\": \"$#\"}" % [bs.regex, bs.options]
      of BsonKindDBPointer:
          let
            refcol = bs.refCol.split(".")[1]
            refdb  = bs.refCol.split(".")[0]
          return "{\"$$ref\": \"$#\", \"$$id\": \"$#\", \"$$db\": \"$#\"}" % [refcol, $bs.refOid, refdb]
      of BsonKindJSCode:
          return bs.valueCode ## TODO: make valid JSON here
      of BsonKindInt32:
          return $bs.valueInt32
      of BsonKindTimestamp:
          return "{\"$$timestamp\": $#}" % [$(cast[ptr int64](addr bs.valueTimestamp)[])]
      of BSonKindInt64:
          return $bs.valueInt64
      of BsonKindMinimumKey:
          return "{\"$$minkey\": 1}"
      of BsonKindMaximumKey:
          return "{\"$$maxkey\": 1}"
      else:
          raiseWrongNodeException(bs)
  return stringify(bs, "")


# #############################
#
# handlers for each basic TYPE
#
# #############################


#
# Oid
#


const
  allZeroesOid* = Oid()
    # A "blank" Oid represented by all-zeroes


proc toBson*(x: Oid): Bson =
  ## Convert Nim Object Id to BSON object. See the ``oids`` standard Nim library.
  ##
  ## If the Oid is all-zeroes ("000000000000000000000000"), then
  ## a null field is stored rather than an ObjectID value
  if $x == $allZeroesOid:
    return Bson(kind: BsonKindNull)
  return Bson(kind: BsonKindOid, valueOid: x)


converter toOid*(x: Bson): Oid =
  ## Convert Bson to Mongo Object ID
  ##
  ## if x is a null, then the all-zeroes Oid is returned
  ## if x is a real Oid, then that value is returned
  ## if x is a string, then an attempt is made to parse it to an Oid
  ## otherwise, the all-zeroes Oid is returned
  case x.kind:
  of BsonKindNull:
    result = allZeroesOid
  of BsonKindOid:
    result = x.valueOid
  of BsonKindStringUTF8:
    try:
      result = parseOid(x.valueString)
    except:
      result = allZeroesOid
  else:
    result = allZeroesOid

proc `[]=`*(bs: Bson, key: string, value: Oid) =
  ## Modify BSON object field with an explicit value
  ##
  ## If setting an ``Oid`` and the Object ID is all-zeroes ("000000000000000000000000"), then
  ## a null field is stored rather than an Object ID value
  ##
  ## Returns a Bson object
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# float
#

proc toBson*(x: float64): Bson =
  ## Convert value to Bson object
  return Bson(kind: BsonKindDouble, valueFloat64: x)

converter toFloat64*(x: Bson): float64 =
  ## Convert Bson object to float64
  return x.valueFloat64

proc `[]=`*(bs: Bson, key: string, value: float64) = #!GROUP=`[]=`
  # Modify Bson document field with an explicit value
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# string
#

proc toBson*(x: string): Bson =  #!GROUP=toBson
  # Convert string to Bson object
  return Bson(kind: BsonKindStringUTF8, valueString: x)

converter toString*(x: Bson): string =
  ## Convert Bson to UTF8 string
  case x.kind
  of BsonKindStringUTF8:
      return x.valueString
  else:
      return $x

proc `[]=`*(bs: Bson, key: string, value: string) =  #!GROUP=`[]=`
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# int64
#

proc toBson*(x: int64): Bson =   #!GROUP=toBson
  # Convert int64 to Bson object
  return Bson(kind: BsonKindInt64, valueInt64: x)

converter toInt64*(x: Bson): int64 =   #!GROUP=toBson
  ## Convert Bson object to int
  case x.kind
  of BsonKindInt64:
      return int64(x.valueInt64)
  of BsonKindInt32:
      return int64(x.valueInt32)
  else:
      raiseWrongNodeException(x)

proc `[]=`*(bs: Bson, key: string, value: int64) =  #!GROUP=`[]=`
  # Modify Bson document field with an explicit int64 value
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# int32
#

proc toBson*(x: int32): Bson =   #!GROUP=toBson
  # Convert int32 to Bson object
  return Bson(kind: BsonKindInt32, valueInt32: x)

converter toInt32*(x: Bson): int32 =
  ## Convert Bson to int32
  case x.kind
  of BsonKindInt64:
      return int32(x.valueInt64)
  of BsonKindInt32:
      return int32(x.valueInt32)
  else:
      raiseWrongNodeException(x)

proc `[]=`*(bs: Bson, key: string, value: int32) =  #!GROUP=`[]=`
  # Modify Bson document field with an explicit int32 value
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# int (generic)
#

converter toInt*(x: Bson): int =
  ## Convert Bson to int whether it is int32 or int64
  case x.kind
  of BsonKindInt64:
      return int(x.valueInt64)
  of BsonKindInt32:
      return int(x.valueInt32)
  else:
      raiseWrongNodeException(x)

proc toBson*(x: int): Bson =   #!GROUP=toBson
  # Convert int to Bson object
  return Bson(kind: BsonKindInt64, valueInt64: x)

proc `[]=`*(bs: Bson, key: string, value: int) =  #!GROUP=`[]=`
  # Modify Bson document field with an explicit int value
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# bool
#

proc toBson*(x: bool): Bson =   #!GROUP=toBson
  # Convert bool to Bson object
  return Bson(kind: BsonKindBool, valueBool: x)

converter toBool*(x: Bson): bool =
  ## Convert Bson object to bool
  return x.valueBool

proc `[]=`*(bs: Bson, key: string, value: bool) =  #!GROUP=`[]=`
  # Modify Bson document field with an explicit bool value
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# Time
#

proc fromMilliseconds*(since1970: int64): Time =
  # Convert number of milliseconds from Unix epoch to Time
  initTime(since1970 div 1000, since1970 mod 1000 * 1000000)

proc toMilliseconds*(t: Time): int64 =
  t.toUnix * 1000 + t.nanosecond div 1000000

proc toBson*(x: Time): Bson =  #!GROUP=toBson
  # Convert Time to Bson object
  return Bson(kind: BsonKindTimeUTC, valueTime: x)

converter toTime*(x: Bson): Time =
  ## Convert Bson object to Time
  return x.valueTime

proc `[]=`*(bs: Bson, key: string, value: Time) =  #!GROUP=`[]=`
  # Modify Bson document field with an explicit Time value
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = toBson(value)
  else:
    raiseWrongNodeException(bs)

#
# others
#

proc toBson*(x: BsonTimestamp): Bson =  #!GROUP=toBson
  # Convert inner BsonTimestamp to Bson object
  return Bson(kind: BsonKindTimestamp, valueTimestamp: x)

converter toTimestamp*(x: Bson): BsonTimestamp =
  ## Convert Bson object to inner BsonTimestamp type
  return x.valueTimestamp

proc toBson*(x: MD5Digest): Bson =  #!GROUP=toBson
  # Convert MD5Digest to Bson object
  return Bson(kind: BsonKindBinary, subtype: BsonSubtypeMd5, valueDigest: x)

proc toBson*(x: var MD5Context): Bson =
  ## Convert MD5Context to Bson object (still digest from current context).
  ## :WARNING: MD5Context is finalized during conversion.
  var digest: MD5Digest
  x.md5Final(digest)
  return Bson(kind: BsonKindBinary, subtype: BsonSubtypeMd5, valueDigest: digest)

# #############################
#
# convert to bytes handling
#
# #############################

proc podValueToBytesAtOffset[T](x: T, res: var string, off: int) {.inline.} =
  assert(off + sizeof(x) <= res.len)
  copyMem(addr res[off], unsafeAddr x, sizeof(x))

proc podValueToBytes[T](x: T, res: var string) {.inline.} =
  let off = res.len
  res.setLen(off + sizeof(x))
  podValueToBytesAtOffset(x, res, off)

proc int32ToBytesAtOffset(x: int32, res: var string, off: int) =
  podValueToBytesAtOffset(x, res, off)

proc int32ToBytes(x: int32, res: var string) {.inline.} =
  ## Convert int32 data piece into series of bytes
  podValueToBytes(x, res)

proc float64ToBytes(x: float64, res: var string) {.inline.} =
  ## Convert float64 data piece into series of bytes
  podValueToBytes(x, res)

proc int64ToBytes(x: int64, res: var string) {.inline.} =
  ## Convert int64 data piece into series of bytes
  podValueToBytes(x, res)

proc boolToBytes(x: bool, res: var string) {.inline.} =
  ## Convert bool data piece into series of bytes
  podValueToBytes(if x: 1'u8 else: 0'u8, res)

proc oidToBytes(x: Oid, res: var string) {.inline.} =
  # Convert Mongo Object ID data piece into series to bytes
  podValueToBytes(x, res)

proc toBytes(bs: Bson, res: var string) =
  # Serialize Bson object into byte-stream
  case bs.kind
  of BsonKindDouble:
      float64ToBytes(bs.valueFloat64, res)
  of BsonKindStringUTF8:
      int32ToBytes(int32(bs.valueString.len + 1), res)
      res &= bs.valueString
      res &= char(0)
  of BsonKindDocument:
      let off = res.len
      res.setLen(off + sizeof(int32)) # We shall write the length in here...
      for key, val in bs.valueDocument:
          if val.isNil:
            raise newException(ValueError, "Value assigned to key $1 is nil.".format(key))
          res &= val.kind
          res &= key
          res &= char(0)
          val.toBytes(res)
      res &= char(0)
      int32ToBytesAtOffset(int32(res.len - off), res, off)
  of BsonKindArray:
      let off = res.len
      res.setLen(off + sizeof(int32)) # We shall write the length in here...
      for i, val in bs.valueArray:
          res &= val.kind
          res &= $i
          res &= char(0)
          val.toBytes(res)
      res &= char(0)
      int32ToBytesAtOffset(int32(res.len - off), res, off)
  of BsonKindBinary:
      case bs.subtype
      of BsonSubtypeMd5:
          var sdig: string = newStringOfCap(16)
          for i in 0..<bs.valueDigest.len():
              add(sdig, bs.valueDigest[i].char)
          int32ToBytes(16, res)
          res &= bs.subtype.char & sdig
      of BsonSubtypeGeneric:
          int32ToBytes(int32(bs.valueGeneric.len), res)
          res &= bs.subtype.char & bs.valueGeneric
      of BsonSubtypeUserDefined:
          int32ToBytes(int32(bs.valueUserDefined.len), res)
          res &= bs.subtype.char & bs.valueUserDefined
      else:
          raiseWrongNodeException(bs)
  of BsonKindUndefined:
      discard
  of BsonKindOid:
      oidToBytes(bs.valueOid, res)
  of BsonKindBool:
      boolToBytes(bs.valueBool, res)
  of BsonKindTimeUTC:
      int64ToBytes(bs.valueTime.toMilliseconds, res)
  of BsonKindNull:
      discard
  of BsonKindRegexp:
      res &= bs.regex & char(0) & bs.options & char(0)
  of BsonKindDBPointer:
      int32ToBytes(int32(bs.refCol.len + 1), res)
      res &= bs.refCol & char(0)
      oidToBytes(bs.refOid, res)
  of BsonKindJSCode:
      int32ToBytes(int32(bs.valueCode.len + 1), res)
      res &= bs.valueCode & char(0)
  of BsonKindInt32:
      int32ToBytes(bs.valueInt32, res)
  of BsonKindTimestamp:
      int64ToBytes(cast[ptr int64](addr bs.valueTimestamp)[], res)
  of BsonKindInt64:
      int64ToBytes(bs.valueInt64, res)
  of BsonKindMinimumKey, BsonKindMaximumKey:
      discard
  else:
      raiseWrongNodeException(bs)

proc bytes*(bs: Bson): string =
  ## Serialize a BSON document into a raw byte-stream.
  ##
  ## Returns a binary string (not generally printable)
  result = ""
  bs.toBytes(result)

# ##################################
#
# Creating/Setting BSON objects
#
# ##################################

proc newBsonDocument*(): Bson =
  ## Create new empty Bson document
  result = Bson(kind: BsonKindDocument,
                valueDocument: initOrderedTable[string, Bson]())

proc newBsonArray*(): Bson =
  ## Create new Bson array
  result = Bson(
      kind: BsonKindArray,
      valueArray: newSeq[Bson]()
  )

# template B*: untyped =
#   newBsonDocument()

proc `[]`*(bs: Bson, key: string): Bson =
  ## Get BSON object field
  if bs.kind == BsonKindDocument:
      return bs.valueDocument.getOrDefault(key)
  else:
      raiseWrongNodeException(bs)

proc `[]=`*(bs: Bson, key: string, value: Bson) =
  ## Modify Bson document field
  if bs.kind == BsonKindDocument:
    bs.valueDocument[key] = value
  else:
    raiseWrongNodeException(bs)

proc `[]`*(bs: Bson, key: int): Bson =
  ## Get BSON array item by index
  if bs.kind == BsonKindArray:
      return bs.valueArray[key]
  else:
      raiseWrongNodeException(bs)

proc `[]=`*(bs: Bson, key: int, value: Bson) =
  ## Modify Bson array element
  if bs.kind == BsonKindArray:
      bs.valueArray[key] = value

proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =
  ## Generic constructor for BSON data.
  result = newBsonDocument()
  for key, val in items(keyVals): result[key] = val

proc toBson*[T](vals: openArray[T]): Bson =
  result = newBsonArray()
  for val in vals: result.add(toBson(val))

template toBson*(b: Bson): Bson = b
  ##

proc toBson*(x: NimNode): NimNode {.compileTime.} =
  ## Convert NimNode into BSON document

  case x.kind

  of nnkBracket:
    result = newNimNode(nnkBracket)
    for i in 0 ..< x.len():
        result.add(toBson(x[i]))
    result = newCall("toBson", result)

  of nnkTableConstr:
    result = newNimNode(nnkTableConstr)
    for i in 0 ..< x.len():
        x[i].expectKind(nnkExprColonExpr)
        result.add(newNimNode(nnkExprColonExpr).add(x[i][0]).add(toBson(x[i][1])))
    result = newCall("toBson", result)

  of nnkCurly:
    result = newCall("newBsonDocument")
    x.expectLen(0)

  else:
    result = newCall("toBson", x)


macro `@@`*(x: untyped): Bson =
  result = toBson(x)


proc dbref*(refCollection: string, refOid: Oid): Bson =
  ## Create a new DBRef (database reference) MongoDB bson type
  ##
  ## refCollection
  ##   the name of the collection being referenced
  ##
  ## refOid
  ##   the ``_id`` of the document sitting in the collection
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindDBPointer, refcol: refCollection, refoid: refOid)

proc undefined*(): Bson =
  ## Create new Bson 'undefined' value
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindUndefined)

proc null*(): Bson =
  ## Create new BSON 'null' value
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindNull)

proc minkey*(): Bson =
  ## Create new BSON value representing 'Min key' BSON type
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindMinimumKey)

proc maxkey*(): Bson =
  ## Create new BSON value representing 'Max key' BSON type
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindMaximumKey)

proc regex*(pattern: string, options: string): Bson =
  ## Create new Bson value representing Regexp BSON type
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindRegexp, regex: pattern, options: options)

proc js*(code: string): Bson =
  ## Create new Bson value representing JavaScript code bson type
  ##
  ## Returns a new BSON object
  return Bson(kind: BsonKindJSCode, valueCode: code)

proc bin*(bindata: string): Bson =
  ## Create new binary Bson object with 'generic' subtype
  ##
  ## To convert it back to a "binary string", use ``binstr``.
  ##
  ## Returns a new BSON object
  return Bson(
      kind: BsonKindBinary,
      subtype: BsonSubtypeGeneric,
      valueGeneric: bindata
  )

proc binstr*(x: Bson): string =
  ## Generate a "binary string" equivalent of the BSON "Generic Binary" field type.
  ##
  ## This is used strictly for that field type field. If you are wanting to 
  ## convert a BSON doc into it's true binary form, use ``bytes`` instead.
  if x.kind == BsonKindBinary:
    case x.subtype:
    of BsonSubtypeGeneric:     return x.valueGeneric
    of BsonSubtypeFunction:    return x.valueFunction
    of BsonSubtypeBinaryOld:   return x.valueBinOld
    of BsonSubtypeUuidOld:     return x.valueUuidOld
    of BsonSubtypeUuid:        return x.valueUuid
    of BsonSubtypeUserDefined: return x.valueUserDefined
    else:
      raiseWrongNodeException(x)      
  else:
    raiseWrongNodeException(x)

proc binuser*(bindata: string): Bson =
  ## Create new binary BSON object with 'user-defined' subtype
  ##
  ## Returns a new BSON object
  return Bson(
      kind: BsonKindBinary,
      subtype: BsonSubtypeUserDefined,
      valueUserDefined: bindata
  )

proc geo*(loc: GeoPoint): Bson =
  ## Convert array of two floats into Bson as MongoDB Geo-Point.
  ##
  ## Returns a new BSON object
  return Bson(
      kind: BsonKindArray,
      valueArray: @[loc[0].toBson(), loc[1].toBson()]
  )

proc timeUTC*(time: Time): Bson =
  ## Create UTC datetime BSON object.
  ##
  ## Returns a new BSON object.
  return Bson(
    kind: BsonKindTimeUTC,
    valueTime: time
  )

proc len*(bs: Bson):int =
  ## Get the length of an array or the number of fields in an object.
  ##
  ## If not an array or object, an exception is generated.
  ##
  ## Returns the length as an integer.
  if bs.kind == BsonKindArray:
      result = bs.valueArray.len
  elif bs.kind == BsonKindDocument:
      result = bs.valueDocument.len
  else:
      raiseWrongNodeException(bs)

proc add*[T](bs: Bson, value: T): Bson {.discardable.} =
  ## Add a new BSON item to the the array's list.
  ##
  ## It both returns a new BSON array and modifies the original in-place.
  result = bs
  result.valueArray.add(value.toBson())

proc del*(bs: Bson, key: string) =
  ## Deletes a field from a BSON object or array.
  ##
  ## If passed a string, it removes a field from an object.
  ## If passed an integer, it removes an item by index from an array
  ##
  ## This procedure modifies the object that is passed to it.
  if bs.kind == BsonKindDocument:
    bs.valueDocument.del(key)
  else:
    raiseWrongNodeException(bs)

proc del*(bs: Bson, idx: int) =  #!GROUP=del  
  if bs.kind == BsonKindArray:
    bs.valueArray.del(idx)
  else:
    raiseWrongNodeException(bs)

proc delete*(bs: Bson, key: string) =  #!GROUP=del
  if bs.kind == BsonKindDocument:
    bs.valueDocument.del(key)
  else:
    raiseWrongNodeException(bs)

proc delete*(bs: Bson, idx: int) =  #!GROUP=del
  if bs.kind == BsonKindArray:
    bs.valueArray.del(idx)
  else:
    raiseWrongNodeException(bs)

proc `{}`*(bs: Bson, keys: varargs[string]): Bson =
  var b = bs
  for k in keys:
    if b.kind == BsonKindDocument:
      b = b.valueDocument.getOrDefault(k)
      if b.isNil: return nil
    else:
      return nil
  return b

proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =
  var bs = bs
  for i in 0..(keys.len-2):
    if isNil(bs[keys[i]]):
      bs[keys[i]] = newBsonDocument()
    bs = bs[keys[i]]
  bs[keys[^1]] = value

iterator items*(bs: Bson): Bson =
  ## Iterate over BSON object field values or array items
  ##
  ## Each calls returns one BSON item.
  if bs.kind == BsonKindDocument:
      for _, v in bs.valueDocument:
          yield v
  elif bs.kind == BsonKindArray:
      for item in bs.valueArray:
          yield item

iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =
  ## Iterate over BSON object's fields
  ##
  ## Each call returns one (key, value) tuple.
  if bs.kind == BsonKindDocument:
      for k, v in bs.valueDocument:
          yield (k, v)

proc contains*(bs: Bson, key: string): bool =
  ## Checks if Bson document has a specified field
  ##
  ## Returns true if found, false otherwise.
  if bs.kind == BsonKindDocument:
    return key in bs.valueDocument
  else:
    return false

proc readStr(s: Stream, length: int, result: var string) =
  result.setLen(length)
  if length != 0:
    var L = readData(s, addr(result[0]), length)
    if L != length: setLen(result, L)

proc newBsonDocument*(s: Stream): Bson =
  ## Create new Bson document from a byte stream
  var buf = ""
  discard s.readInt32()   ## docSize
  result = newBsonDocument()
  var docStack = @[result]
  while docStack.len != 0:
      let kind: BsonKind = s.readChar()
      if kind == BsonKindUnknown:
          docStack.setLen(docStack.len - 1) # End of doc. pop stack.
          continue

      let doc = docStack[^1]

      discard s.readLine(buf)
      var sub: ptr Bson
      case doc.kind
      of BsonKindDocument:
          sub = addr doc.valueDocument.mgetOrPut(buf, nil)
      of BsonKindArray:
          doc.valueArray.add(nil)
          sub = addr doc.valueArray[^1]
      else:
          assert(false, "Internal error")

      case kind:
      of BsonKindDouble:
          sub[] = s.readFloat64().toBson()
      of BsonKindStringUTF8:
          s.readStr(s.readInt32() - 1, buf)
          discard s.readChar()
          sub[] = buf.toBson()
      of BsonKindDocument:
          discard s.readInt32()   ## docSize
          let subdoc = newBsonDocument()
          sub[] = subdoc
          docStack.add(subdoc)
      of BsonKindArray:
          discard s.readInt32()   ## docSize
          let subarr = newBsonArray()
          sub[] = subarr
          docStack.add(subarr)
      of BsonKindBinary:
          let
              ds: int32 = s.readInt32()
              st: BsonSubtype = s.readChar().BsonSubtype
          if ds > 0:
              s.readStr(ds, buf)
          else:
              buf = ""
          case st:
          of BsonSubtypeMd5:
              sub[] = cast[ptr MD5Digest](buf.cstring)[].toBson()
          of BsonSubtypeGeneric:
              sub[] = bin(buf)
          of BsonSubtypeUserDefined:
              sub[] = binuser(buf)
          of BsonSubtypeUuid:
              sub[] = bin(buf)
          else:
              raise newException(Exception, "Unexpected subtype: " & $(st.int))
      of BsonKindUndefined:
          sub[] = undefined()
      of BsonKindOid:
          s.readStr(12, buf)
          sub[] = cast[ptr Oid](buf.cstring)[].toBson()
      of BsonKindBool:
          sub[] = if s.readChar() == 0.char: false.toBson() else: true.toBson()
      of BsonKindTimeUTC:
          let timeUTC: Bson = Bson(kind: BsonKindTimeUTC, valueTime: fromMilliseconds(s.readInt64()))
          sub[] = timeUTC
      of BsonKindNull:
          sub[] = null()
      of BsonKindRegexp:
          # sub[] = regex(s.readLine().string(), seqCharToString(sorted(s.readLine().string, system.cmp)))
          sub[] = regex(s.readLine().string(), s.readLine().string)
      of BsonKindDBPointer:
          let refcol: string = s.readStr(s.readInt32() - 1)
          discard s.readChar()
          let refoid: Oid = cast[ptr Oid](s.readStr(12).cstring)[]
          sub[] = dbref(refcol, refoid)
      of BsonKindJSCode:
          s.readStr(s.readInt32() - 1, buf)
          discard s.readChar()
          sub[] = js(buf)
      of BsonKindInt32:
          sub[] = s.readInt32().toBson()
      of BsonKindTimestamp:
          sub[] = cast[BsonTimestamp](s.readInt64()).toBson()
      of BsonKindInt64:
          sub[] = s.readInt64().toBson()
      of BsonKindMinimumKey:
          sub[] = minkey()
      of BsonKindMaximumKey:
          sub[] = maxkey()
      else:
          raise newException(Exception, "Unexpected kind: " & $kind)

proc newBsonDocument*(bytes: string): Bson =
  ## Create new Bson document from byte string
  newBsonDocument(newStringStream(bytes))

proc merge*(a, b: Bson): Bson =
  ## Combine two BSON documents into a new one.
  ##
  ## The resulting document contains all the fields of both.
  ## If both ``a`` and ``b`` contain the same field, the
  ## value in ``b`` is used.
  ##
  ## For example:
  ##
  ##
  ## .. code:: nim
  ##
  ##     let a = @@{"name": "Joe", "age": 42, weight: 50 }
  ##     let b = @@{"name": "Joe", "feet": 2, weight: 52 }
  ##     let both = a.merge(b)
  ##     echo $both
  ##
  ## displays     
  ##
  ## .. code:: json
  ##
  ##     {
  ##         "name" : "Joe",
  ##         "age" : 42,
  ##         "weight" : 52,
  ##         "feet" : 2
  ##     }
  ##
  ## Returns the combined BSON document.

  proc m_rec(a, b, r: Bson)=
    for k, v in a:
      if not b[k].isNil:
        r[k] = v.merge(b[k])
      else:
        r[k] = v

    for k, v in b:
      if a[k].isNil:
        r[k] = v

  if (a.kind == BsonKindDocument or a.kind == BsonKindArray) and
     (b.kind == BsonKindDocument or b.kind == BsonKindArray):
    result = newBsonDocument()
    m_rec(a, b, result)
  else:
      result = b

proc update*(a, b: Bson)=
  ## Modifies the content of document ``a`` with the updated content of document ``b``.
  ##
  ## If ``a`` and ``b`` contain the same field, the value in ``b`` is set
  ## in ``a``.
  ##
  ## Works with both documents and arrays. With anything else, nothing happens.
  if (a.kind == BsonKindDocument or a.kind == BsonKindArray) and
     (b.kind == BsonKindDocument or b.kind == BsonKindArray):

    for k, v in a:
        if not b[k].isNil:
            a[k] = v.merge(b[k])

    for k, v in b:
        if a[k].isNil:
            a[k] = v


# macro to*(node: JsonNode, T: typedesc): untyped =
#   ## `Unmarshals`:idx: the specified node into the object type specified.
#   ##
#   ## Known limitations:
#   ##
#   ##   * Heterogeneous arrays are not supported.
#   ##   * Sets in object variants are not supported.
#   ##   * Not nil annotations are not supported.
#   ##
#   ## Example:
#   ##
#   ## .. code-block:: Nim
#   ##     let jsonNode = parseJson("""
#   ##        {
#   ##          "person": {
#   ##            "name": "Nimmer",
#   ##            "age": 21
#   ##          },
#   ##          "list": [1, 2, 3, 4]
#   ##        }
#   ##     """)
#   ##
#   ##     type
#   ##       Person = object
#   ##         name: string
#   ##         age: int
#   ##
#   ##       Data = object
#   ##         person: Person
#   ##         list: seq[int]
#   ##
#   ##     var data = to(jsonNode, Data)
#   ##     doAssert data.person.name == "Nimmer"
#   ##     doAssert data.person.age == 21
#   ##     doAssert data.list == @[1, 2, 3, 4]

#   let typeNode = getTypeImpl(T)
#   expectKind(typeNode, nnkBracketExpr)
#   doAssert(($typeNode[0]).normalize == "typedesc")

#   # Create `temp` variable to store the result in case the user calls this
#   # on `parseJson` (see bug #6604).
#   result = newNimNode(nnkStmtListExpr)
#   let temp = genSym(nskLet, "temp")
#   result.add quote do:
#     let `temp` = `node`

#   let constructor = createConstructor(typeNode[1], temp)
#   result.add(postProcessValue(constructor))

#   # echo(treeRepr(result))
#   # echo(toStrLit(result))

