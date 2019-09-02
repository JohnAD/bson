bson Reference
==============================================================================

The following are the references for bson.



Types
=====



Bson
---------------------------------------------------------

    .. code:: nim

        Bson* = ref object of RootObj  ## Bson Node
          case kind*: BsonKind
          of BsonKindDouble:           valueFloat64:     float64
          of BsonKindStringUTF8:       valueString:      string
          of BsonKindDocument:         valueDocument:    OrderedTable[string, Bson]
          of BsonKindArray:            valueArray:       seq[Bson]
          of BsonKindBinary:
          of BsonKindUndefined:        discard
          of BsonKindOid:              valueOid:         Oid
          of BsonKindBool:             valueBool:        bool
          of BsonKindTimeUTC:          valueTime:        Time
          of BsonKindNull:             discard
          of BsonKindRegexp:
          of BsonKindDBPointer:
          of BsonKindJSCode:           valueCode:        string
          of BsonKindDeprecated:       valueDepr:        string
          of BsonKindJSCodeWithScope:  valueCodeWS:      string
          of BsonKindInt32:            valueInt32:       int32
          of BsonKindTimestamp:        valueTimestamp:   BsonTimestamp
          of BsonKindInt64:            valueInt64:       int64
          of BsonKindMaximumKey:       discard
          of BsonKindMinimumKey:       discard
          else:                        discard


    *source line: 198*



BsonTimestamp
---------------------------------------------------------

    .. code:: nim

        BsonTimestamp* = object ## Internal MongoDB type used by mongos instances
          increment*: int32
          timestamp*: int32


    *source line: 194*







Procs, Methods, Iterators, Converters
=====================================


`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(bs: Bson): string

    *source line: 452*



`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(bs: Bson): string =

    *source line: 458*

    Serialize Bson document into readable string


`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: int, value: Bson) =

    *source line: 581*

    Modify Bson array element


`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Bson) =

    *source line: 567*

    Modify Bson document field


`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: int): Bson =

    *source line: 574*

    Get Bson array item by index


`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: string): Bson =

    *source line: 560*

    Get Bson document field


`{}=`
---------------------------------------------------------

    .. code:: nim

        proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =

    *source line: 749*



`{}`
---------------------------------------------------------

    .. code:: nim

        proc `{}`*(bs: Bson, keys: varargs[string]): Bson =

    *source line: 739*



add
---------------------------------------------------------

    .. code:: nim

        proc add*[T](bs: Bson, value: T): Bson {.discardable.} =

    *source line: 717*



bin
---------------------------------------------------------

    .. code:: nim

        proc bin*(bindata: string): Bson =

    *source line: 667*

    Create new binary Bson object with 'generic' subtype


binstr
---------------------------------------------------------

    .. code:: nim

        proc binstr*(x: Bson): string =

    *source line: 675*



binuser
---------------------------------------------------------

    .. code:: nim

        proc binuser*(bindata: string): Bson =

    *source line: 686*

    Create new binray Bson object with 'user-defined' subtype


boolToBytes
---------------------------------------------------------

    .. code:: nim

        proc boolToBytes*(x: bool, res: var string) {.inline.} =

    *source line: 369*

    Convert bool data piece into series of bytes


bytes
---------------------------------------------------------

    .. code:: nim

        proc bytes*(bs: Bson): string =

    *source line: 454*



contains
---------------------------------------------------------

    .. code:: nim

        proc contains*(bs: Bson, key: string): bool =

    *source line: 772*

    Checks if Bson document has a specified field


dbref
---------------------------------------------------------

    .. code:: nim

        proc dbref*(refcol: string, refoid: Oid): Bson =

    *source line: 639*

    Create new DBRef (database reference) MongoDB bson type


del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, idx: int) =

    *source line: 733*



del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, key: string) =

    *source line: 721*



delete
---------------------------------------------------------

    .. code:: nim

        proc delete*(bs: Bson, idx: int) =

    *source line: 727*



float64ToBytes
---------------------------------------------------------

    .. code:: nim

        proc float64ToBytes*(x: float64, res: var string) {.inline.} =

    *source line: 361*

    Convert float64 data piece into series of bytes


geo
---------------------------------------------------------

    .. code:: nim

        proc geo*(loc: GeoPoint): Bson =

    *source line: 694*

    Convert array of two floats into Bson as MongoDB Geo-Point.


initBsonArray
---------------------------------------------------------

    .. code:: nim

        proc initBsonArray*(): Bson {.deprecated.} =

    *source line: 553*

    Create new Bson array


initBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc initBsonDocument*(): Bson {.deprecated.}=

    *source line: 536*

    Create new top-level Bson document


initBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc initBsonDocument*(bytes: string): Bson {.deprecated.} =

    *source line: 886*

    Create new Bson document from byte string


initBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc initBsonDocument*(stream: Stream): Bson {.deprecated.} =

    *source line: 883*



int32ToBytes
---------------------------------------------------------

    .. code:: nim

        proc int32ToBytes*(x: int32, res: var string) {.inline.} =

    *source line: 357*

    Convert int32 data piece into series of bytes


int32ToBytesAtOffset
---------------------------------------------------------

    .. code:: nim

        proc int32ToBytesAtOffset*(x: int32, res: var string, off: int) =

    *source line: 354*



int64ToBytes
---------------------------------------------------------

    .. code:: nim

        proc int64ToBytes*(x: int64, res: var string) {.inline.} =

    *source line: 365*

    Convert int64 data piece into series of bytes


items
---------------------------------------------------------

    .. code:: nim

        iterator items*(bs: Bson): Bson =

    *source line: 757*

    Iterate over Bson document or array fields


js
---------------------------------------------------------

    .. code:: nim

        proc js*(code: string): Bson =

    *source line: 663*

    Create new Bson value representing JavaScript code bson type


len
---------------------------------------------------------

    .. code:: nim

        proc len*(bs: Bson):int =

    *source line: 708*



maxkey
---------------------------------------------------------

    .. code:: nim

        proc maxkey*(): Bson =

    *source line: 655*

    Create new Bson value representing 'Max key' bson type


merge
---------------------------------------------------------

    .. code:: nim

        proc merge*(a, b: Bson): Bson =

    *source line: 894*



minkey
---------------------------------------------------------

    .. code:: nim

        proc minkey*(): Bson =

    *source line: 651*

    Create new Bson value representing 'Min key' bson type


newBsonArray
---------------------------------------------------------

    .. code:: nim

        proc newBsonArray*(): Bson =

    *source line: 546*

    Create new Bson array


newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(): Bson =

    *source line: 541*

    Create new empty Bson document


newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(bytes: string): Bson =

    *source line: 890*

    Create new Bson document from byte string


newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(s: Stream): Bson =

    *source line: 785*

    Create new Bson document from byte stream


null
---------------------------------------------------------

    .. code:: nim

        proc null*(): Bson =

    *source line: 647*

    Create new Bson 'null' value


oidToBytes
---------------------------------------------------------

    .. code:: nim

        proc oidToBytes*(x: Oid, res: var string) {.inline.} =

    *source line: 373*

    Convert Mongo Object ID data piece into series to bytes


pairs
---------------------------------------------------------

    .. code:: nim

        iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =

    *source line: 766*

    Iterate over Bson document


regex
---------------------------------------------------------

    .. code:: nim

        proc regex*(pattern: string, options: string): Bson =

    *source line: 659*

    Create new Bson value representing Regexp bson type


timeUTC
---------------------------------------------------------

    .. code:: nim

        proc timeUTC*(time: Time): Bson =

    *source line: 701*

    Create UTC datetime Bson object.


toBool
---------------------------------------------------------

    .. code:: nim

        converter toBool*(x: Bson): bool =

    *source line: 314*

    Convert Bson object to bool


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =

    *source line: 586*

    Generic constructor for BSON data.


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: BsonTimestamp): Bson =

    *source line: 326*

    Convert inner BsonTimestamp to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: MD5Digest): Bson =

    *source line: 334*

    Convert MD5Digest to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Oid): Bson =

    *source line: 240*

    Convert Mongo Object Id to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Time): Bson =

    *source line: 318*

    Convert Time to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: bool): Bson =

    *source line: 310*

    Convert bool to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: float64): Bson =

    *source line: 248*

    Convert float64 to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int): Bson =

    *source line: 306*

    Convert int to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int32): Bson =

    *source line: 282*

    Convert int32 to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int64): Bson =

    *source line: 268*

    Convert int64 to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: string): Bson =

    *source line: 256*

    Convert string to Bson object


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: var MD5Context): Bson =

    *source line: 338*

    Convert MD5Context to Bson object (still digest from current context).
    :WARNING: MD5Context is finalized during conversion.


toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*[T](vals: openArray[T]): Bson =

    *source line: 591*



toBsonKind
---------------------------------------------------------

    .. code:: nim

        converter toBsonKind*(c: char): BsonKind =

    *source line: 187*

    Convert char to BsonKind


toBytes
---------------------------------------------------------

    .. code:: nim

        proc toBytes*(bs: Bson, res: var string) =

    *source line: 377*

    Serialize Bson object into byte-stream


toChar
---------------------------------------------------------

    .. code:: nim

        converter toChar*(bk: BsonKind): char =

    *source line: 179*

    Convert BsonKind to char


toChar
---------------------------------------------------------

    .. code:: nim

        converter toChar*(sub: BsonSubtype): char =

    *source line: 183*

    Convert BsonSubtype to char


toFloat64
---------------------------------------------------------

    .. code:: nim

        converter toFloat64*(x: Bson): float64 =

    *source line: 252*

    Convert Bson object to float64


toInt
---------------------------------------------------------

    .. code:: nim

        converter toInt*(x: Bson): int =

    *source line: 296*

    Convert Bson to int whether it is int32 or int64


toInt32
---------------------------------------------------------

    .. code:: nim

        converter toInt32*(x: Bson): int32 =

    *source line: 286*

    Convert Bson to int32


toInt64
---------------------------------------------------------

    .. code:: nim

        converter toInt64*(x: Bson): int64 =

    *source line: 272*

    Convert Bson object to int


toOid
---------------------------------------------------------

    .. code:: nim

        converter toOid*(x: Bson): Oid =

    *source line: 244*

    Convert Bson to Mongo Object ID


toString
---------------------------------------------------------

    .. code:: nim

        converter toString*(x: Bson): string =

    *source line: 260*

    Convert Bson to UTF8 string


toTime
---------------------------------------------------------

    .. code:: nim

        converter toTime*(x: Bson): Time =

    *source line: 322*

    Convert Bson object to Time


toTimestamp
---------------------------------------------------------

    .. code:: nim

        converter toTimestamp*(x: Bson): BsonTimestamp =

    *source line: 330*

    Convert Bson object to inner BsonTimestamp type


undefined
---------------------------------------------------------

    .. code:: nim

        proc undefined*(): Bson =

    *source line: 643*

    Create new Bson 'undefined' value


update
---------------------------------------------------------

    .. code:: nim

        proc update*(a, b: Bson)=

    *source line: 914*





Macros and Templates
====================


B
---------------------------------------------------------

.. code:: nim

    template B*(key: string, val: Bson): Bson =  ## Shortcut for `newBsonDocument`

*source line: 629*



B
---------------------------------------------------------

.. code:: nim

    template B*: untyped =

*source line: 557*



B
---------------------------------------------------------

.. code:: nim

    template B*[T](key: string, values: seq[T]): Bson =

*source line: 634*



`%*`
---------------------------------------------------------

.. code:: nim

    macro `%*`*(x: untyped): Bson =

*source line: 622*

    Perform dict-like structure conversion into bson


`@@`
---------------------------------------------------------

.. code:: nim

    macro `@@`*(x: untyped): Bson =

*source line: 626*



toBson
---------------------------------------------------------

.. code:: nim

    template toBson*(b: Bson): Bson = b

*source line: 595*

    





Table Of Contents
=================

1. `Introduction to bson <index.rst>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
