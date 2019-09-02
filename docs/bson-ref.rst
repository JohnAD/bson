bson Reference
==============================================================================

The following are the references for bson.



Types
=====



.. _Bson.type:
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


    source line: `197 <../src/bson.nim#L197>`__



.. _BsonTimestamp.type:
BsonTimestamp
---------------------------------------------------------

    .. code:: nim

        BsonTimestamp* = object ## Internal MongoDB type used by mongos instances
          increment*: int32
          timestamp*: int32


    source line: `193 <../src/bson.nim#L193>`__







Procs, Methods, Iterators
=========================


.. _`$`.p:
`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(bs: Bson): string

    source line: `239 <../src/bson.nim#L239>`__



.. _`$`.p:
`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(bs: Bson): string =

    source line: `575 <../src/bson.nim#L575>`__

    Serialize Bson document into readable string


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: int, value: Bson) =

    source line: `698 <../src/bson.nim#L698>`__

    Modify Bson array element


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Bson) =

    source line: `684 <../src/bson.nim#L684>`__

    Modify Bson document field


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Oid) =

    source line: `276 <../src/bson.nim#L276>`__

    Modify Bson document field with an explicit Oid value
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Time) =

    source line: `434 <../src/bson.nim#L434>`__

    Modify Bson document field with an explicit Time value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: bool) =

    source line: `415 <../src/bson.nim#L415>`__

    Modify Bson document field with an explicit bool value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: float64) =

    source line: `298 <../src/bson.nim#L298>`__

    Modify Bson document field with an explicit float64 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int) =

    source line: `396 <../src/bson.nim#L396>`__

    Modify Bson document field with an explicit int value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int32) =

    source line: `371 <../src/bson.nim#L371>`__

    Modify Bson document field with an explicit int32 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int64) =

    source line: `346 <../src/bson.nim#L346>`__

    Modify Bson document field with an explicit int64 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: string) =

    source line: `321 <../src/bson.nim#L321>`__

    Modify Bson document field with an explicit string value


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: int): Bson =

    source line: `691 <../src/bson.nim#L691>`__

    Get Bson array item by index


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: string): Bson =

    source line: `677 <../src/bson.nim#L677>`__

    Get Bson document field


.. _`{}=`.p:
`{}=`
---------------------------------------------------------

    .. code:: nim

        proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =

    source line: `866 <../src/bson.nim#L866>`__



.. _`{}`.p:
`{}`
---------------------------------------------------------

    .. code:: nim

        proc `{}`*(bs: Bson, keys: varargs[string]): Bson =

    source line: `856 <../src/bson.nim#L856>`__



.. _add.p:
add
---------------------------------------------------------

    .. code:: nim

        proc add*[T](bs: Bson, value: T): Bson {.discardable.} =

    source line: `834 <../src/bson.nim#L834>`__



.. _bin.p:
bin
---------------------------------------------------------

    .. code:: nim

        proc bin*(bindata: string): Bson =

    source line: `784 <../src/bson.nim#L784>`__

    Create new binary Bson object with 'generic' subtype


.. _binstr.p:
binstr
---------------------------------------------------------

    .. code:: nim

        proc binstr*(x: Bson): string =

    source line: `792 <../src/bson.nim#L792>`__



.. _binuser.p:
binuser
---------------------------------------------------------

    .. code:: nim

        proc binuser*(bindata: string): Bson =

    source line: `803 <../src/bson.nim#L803>`__

    Create new binray Bson object with 'user-defined' subtype


.. _boolToBytes.p:
boolToBytes
---------------------------------------------------------

    .. code:: nim

        proc boolToBytes*(x: bool, res: var string) {.inline.} =

    source line: `488 <../src/bson.nim#L488>`__

    Convert bool data piece into series of bytes


.. _bytes.p:
bytes
---------------------------------------------------------

    .. code:: nim

        proc bytes*(bs: Bson): string =

    source line: `571 <../src/bson.nim#L571>`__



.. _contains.p:
contains
---------------------------------------------------------

    .. code:: nim

        proc contains*(bs: Bson, key: string): bool =

    source line: `889 <../src/bson.nim#L889>`__

    Checks if Bson document has a specified field


.. _dbref.p:
dbref
---------------------------------------------------------

    .. code:: nim

        proc dbref*(refcol: string, refoid: Oid): Bson =

    source line: `756 <../src/bson.nim#L756>`__

    Create new DBRef (database reference) MongoDB bson type


.. _del.p:
del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, idx: int) =

    source line: `850 <../src/bson.nim#L850>`__



.. _del.p:
del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, key: string) =

    source line: `838 <../src/bson.nim#L838>`__



.. _delete.p:
delete
---------------------------------------------------------

    .. code:: nim

        proc delete*(bs: Bson, idx: int) =

    source line: `844 <../src/bson.nim#L844>`__



.. _float64ToBytes.p:
float64ToBytes
---------------------------------------------------------

    .. code:: nim

        proc float64ToBytes*(x: float64, res: var string) {.inline.} =

    source line: `480 <../src/bson.nim#L480>`__

    Convert float64 data piece into series of bytes


.. _geo.p:
geo
---------------------------------------------------------

    .. code:: nim

        proc geo*(loc: GeoPoint): Bson =

    source line: `811 <../src/bson.nim#L811>`__

    Convert array of two floats into Bson as MongoDB Geo-Point.


.. _initBsonArray.p:
initBsonArray
---------------------------------------------------------

    .. code:: nim

        proc initBsonArray*(): Bson {.deprecated.} =

    source line: `670 <../src/bson.nim#L670>`__

    Create new Bson array


.. _initBsonDocument.p:
initBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc initBsonDocument*(): Bson {.deprecated.}=

    source line: `653 <../src/bson.nim#L653>`__

    Create new top-level Bson document


.. _initBsonDocument.p:
initBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc initBsonDocument*(bytes: string): Bson {.deprecated.} =

    source line: `1003 <../src/bson.nim#L1003>`__

    Create new Bson document from byte string


.. _initBsonDocument.p:
initBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc initBsonDocument*(stream: Stream): Bson {.deprecated.} =

    source line: `1000 <../src/bson.nim#L1000>`__



.. _int32ToBytes.p:
int32ToBytes
---------------------------------------------------------

    .. code:: nim

        proc int32ToBytes*(x: int32, res: var string) {.inline.} =

    source line: `476 <../src/bson.nim#L476>`__

    Convert int32 data piece into series of bytes


.. _int32ToBytesAtOffset.p:
int32ToBytesAtOffset
---------------------------------------------------------

    .. code:: nim

        proc int32ToBytesAtOffset*(x: int32, res: var string, off: int) =

    source line: `473 <../src/bson.nim#L473>`__



.. _int64ToBytes.p:
int64ToBytes
---------------------------------------------------------

    .. code:: nim

        proc int64ToBytes*(x: int64, res: var string) {.inline.} =

    source line: `484 <../src/bson.nim#L484>`__

    Convert int64 data piece into series of bytes


.. _items.i:
items
---------------------------------------------------------

    .. code:: nim

        iterator items*(bs: Bson): Bson =

    source line: `874 <../src/bson.nim#L874>`__

    Iterate over Bson document or array fields


.. _js.p:
js
---------------------------------------------------------

    .. code:: nim

        proc js*(code: string): Bson =

    source line: `780 <../src/bson.nim#L780>`__

    Create new Bson value representing JavaScript code bson type


.. _len.p:
len
---------------------------------------------------------

    .. code:: nim

        proc len*(bs: Bson):int =

    source line: `825 <../src/bson.nim#L825>`__



.. _maxkey.p:
maxkey
---------------------------------------------------------

    .. code:: nim

        proc maxkey*(): Bson =

    source line: `772 <../src/bson.nim#L772>`__

    Create new Bson value representing 'Max key' bson type


.. _merge.p:
merge
---------------------------------------------------------

    .. code:: nim

        proc merge*(a, b: Bson): Bson =

    source line: `1011 <../src/bson.nim#L1011>`__



.. _minkey.p:
minkey
---------------------------------------------------------

    .. code:: nim

        proc minkey*(): Bson =

    source line: `768 <../src/bson.nim#L768>`__

    Create new Bson value representing 'Min key' bson type


.. _newBsonArray.p:
newBsonArray
---------------------------------------------------------

    .. code:: nim

        proc newBsonArray*(): Bson =

    source line: `663 <../src/bson.nim#L663>`__

    Create new Bson array


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(): Bson =

    source line: `658 <../src/bson.nim#L658>`__

    Create new empty Bson document


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(bytes: string): Bson =

    source line: `1007 <../src/bson.nim#L1007>`__

    Create new Bson document from byte string


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(s: Stream): Bson =

    source line: `902 <../src/bson.nim#L902>`__

    Create new Bson document from byte stream


.. _null.p:
null
---------------------------------------------------------

    .. code:: nim

        proc null*(): Bson =

    source line: `764 <../src/bson.nim#L764>`__

    Create new Bson 'null' value


.. _oidToBytes.p:
oidToBytes
---------------------------------------------------------

    .. code:: nim

        proc oidToBytes*(x: Oid, res: var string) {.inline.} =

    source line: `492 <../src/bson.nim#L492>`__

    Convert Mongo Object ID data piece into series to bytes


.. _pairs.i:
pairs
---------------------------------------------------------

    .. code:: nim

        iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =

    source line: `883 <../src/bson.nim#L883>`__

    Iterate over Bson document


.. _regex.p:
regex
---------------------------------------------------------

    .. code:: nim

        proc regex*(pattern: string, options: string): Bson =

    source line: `776 <../src/bson.nim#L776>`__

    Create new Bson value representing Regexp bson type


.. _timeUTC.p:
timeUTC
---------------------------------------------------------

    .. code:: nim

        proc timeUTC*(time: Time): Bson =

    source line: `818 <../src/bson.nim#L818>`__

    Create UTC datetime Bson object.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =

    source line: `703 <../src/bson.nim#L703>`__

    Generic constructor for BSON data.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: BsonTimestamp): Bson =

    source line: `445 <../src/bson.nim#L445>`__

    Convert inner BsonTimestamp to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: MD5Digest): Bson =

    source line: `453 <../src/bson.nim#L453>`__

    Convert MD5Digest to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Oid): Bson =

    source line: `253 <../src/bson.nim#L253>`__

    Convert Mongo Object Id to Bson object
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Time): Bson =

    source line: `426 <../src/bson.nim#L426>`__

    Convert Time to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: bool): Bson =

    source line: `407 <../src/bson.nim#L407>`__

    Convert bool to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: float64): Bson =

    source line: `290 <../src/bson.nim#L290>`__

    Convert float64 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int): Bson =

    source line: `392 <../src/bson.nim#L392>`__

    Convert int to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int32): Bson =

    source line: `357 <../src/bson.nim#L357>`__

    Convert int32 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int64): Bson =

    source line: `332 <../src/bson.nim#L332>`__

    Convert int64 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: string): Bson =

    source line: `309 <../src/bson.nim#L309>`__

    Convert string to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: var MD5Context): Bson =

    source line: `457 <../src/bson.nim#L457>`__

    Convert MD5Context to Bson object (still digest from current context).
    :WARNING: MD5Context is finalized during conversion.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*[T](vals: openArray[T]): Bson =

    source line: `708 <../src/bson.nim#L708>`__



.. _toBytes.p:
toBytes
---------------------------------------------------------

    .. code:: nim

        proc toBytes*(bs: Bson, res: var string) =

    source line: `496 <../src/bson.nim#L496>`__

    Serialize Bson object into byte-stream


.. _undefined.p:
undefined
---------------------------------------------------------

    .. code:: nim

        proc undefined*(): Bson =

    source line: `760 <../src/bson.nim#L760>`__

    Create new Bson 'undefined' value


.. _update.p:
update
---------------------------------------------------------

    .. code:: nim

        proc update*(a, b: Bson)=

    source line: `1031 <../src/bson.nim#L1031>`__





Converters
==========


.. _toBool.c:
toBool
---------------------------------------------------------

    .. code:: nim

        converter toBool*(x: Bson): bool =

    source line: `411 <../src/bson.nim#L411>`__

    Convert Bson object to bool


.. _toBsonKind.c:
toBsonKind
---------------------------------------------------------

    .. code:: nim

        converter toBsonKind*(c: char): BsonKind =

    source line: `186 <../src/bson.nim#L186>`__

    Convert char to BsonKind


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        converter toChar*(bk: BsonKind): char =

    source line: `178 <../src/bson.nim#L178>`__

    Convert BsonKind to char


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        converter toChar*(sub: BsonSubtype): char =

    source line: `182 <../src/bson.nim#L182>`__

    Convert BsonSubtype to char


.. _toFloat64.c:
toFloat64
---------------------------------------------------------

    .. code:: nim

        converter toFloat64*(x: Bson): float64 =

    source line: `294 <../src/bson.nim#L294>`__

    Convert Bson object to float64


.. _toInt.c:
toInt
---------------------------------------------------------

    .. code:: nim

        converter toInt*(x: Bson): int =

    source line: `382 <../src/bson.nim#L382>`__

    Convert Bson to int whether it is int32 or int64


.. _toInt32.c:
toInt32
---------------------------------------------------------

    .. code:: nim

        converter toInt32*(x: Bson): int32 =

    source line: `361 <../src/bson.nim#L361>`__

    Convert Bson to int32


.. _toInt64.c:
toInt64
---------------------------------------------------------

    .. code:: nim

        converter toInt64*(x: Bson): int64 =

    source line: `336 <../src/bson.nim#L336>`__

    Convert Bson object to int


.. _toOid.c:
toOid
---------------------------------------------------------

    .. code:: nim

        converter toOid*(x: Bson): Oid =

    source line: `262 <../src/bson.nim#L262>`__

    Convert Bson to Mongo Object ID
    
    if x is a null, then the all-zeroes Oid is returned
    if x is a real Oid, then that value is returned
    otherwise and attempt is made to parse the string equivalent into an Oid


.. _toString.c:
toString
---------------------------------------------------------

    .. code:: nim

        converter toString*(x: Bson): string =

    source line: `313 <../src/bson.nim#L313>`__

    Convert Bson to UTF8 string


.. _toTime.c:
toTime
---------------------------------------------------------

    .. code:: nim

        converter toTime*(x: Bson): Time =

    source line: `430 <../src/bson.nim#L430>`__

    Convert Bson object to Time


.. _toTimestamp.c:
toTimestamp
---------------------------------------------------------

    .. code:: nim

        converter toTimestamp*(x: Bson): BsonTimestamp =

    source line: `449 <../src/bson.nim#L449>`__

    Convert Bson object to inner BsonTimestamp type




Macros and Templates
====================


.. _B.t:
B
---------------------------------------------------------

.. code:: nim

    template B*(key: string, val: Bson): Bson =  ## Shortcut for `newBsonDocument`

    source line: `746 <../src/bson.nim#L746>`__



.. _B.t:
B
---------------------------------------------------------

.. code:: nim

    template B*: untyped =

    source line: `674 <../src/bson.nim#L674>`__



.. _B.t:
B
---------------------------------------------------------

.. code:: nim

    template B*[T](key: string, values: seq[T]): Bson =

    source line: `751 <../src/bson.nim#L751>`__



.. _`%*`.m:
`%*`
---------------------------------------------------------

.. code:: nim

    macro `%*`*(x: untyped): Bson =

    source line: `739 <../src/bson.nim#L739>`__

    Perform dict-like structure conversion into bson


.. _`@@`.m:
`@@`
---------------------------------------------------------

.. code:: nim

    macro `@@`*(x: untyped): Bson =

    source line: `743 <../src/bson.nim#L743>`__



.. _toBson.t:
toBson
---------------------------------------------------------

.. code:: nim

    template toBson*(b: Bson): Bson = b

    source line: `712 <../src/bson.nim#L712>`__

    





Table Of Contents
=================

1. `Introduction to bson <index.rst>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
