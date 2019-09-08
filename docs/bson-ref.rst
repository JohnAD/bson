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

        proc `$`*(bs: Bson): string =

    source line: `241 <../src/bson.nim#L241>`__

    Serialize Bson document into readable string


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: int, value: Bson) =

    source line: `712 <../src/bson.nim#L712>`__

    Modify Bson array element


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Bson) =

    source line: `698 <../src/bson.nim#L698>`__

    Modify Bson document field


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Oid) =

    source line: `360 <../src/bson.nim#L360>`__

    Modify Bson document field with an explicit Oid value
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Time) =

    source line: `518 <../src/bson.nim#L518>`__

    Modify Bson document field with an explicit Time value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: bool) =

    source line: `499 <../src/bson.nim#L499>`__

    Modify Bson document field with an explicit bool value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: float64) =

    source line: `382 <../src/bson.nim#L382>`__

    Modify Bson document field with an explicit float64 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int) =

    source line: `480 <../src/bson.nim#L480>`__

    Modify Bson document field with an explicit int value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int32) =

    source line: `455 <../src/bson.nim#L455>`__

    Modify Bson document field with an explicit int32 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int64) =

    source line: `430 <../src/bson.nim#L430>`__

    Modify Bson document field with an explicit int64 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: string) =

    source line: `405 <../src/bson.nim#L405>`__

    Modify Bson document field with an explicit string value


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: int): Bson =

    source line: `705 <../src/bson.nim#L705>`__

    Get Bson array item by index


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: string): Bson =

    source line: `691 <../src/bson.nim#L691>`__

    Get Bson document field


.. _`{}=`.p:
`{}=`
---------------------------------------------------------

    .. code:: nim

        proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =

    source line: `887 <../src/bson.nim#L887>`__



.. _`{}`.p:
`{}`
---------------------------------------------------------

    .. code:: nim

        proc `{}`*(bs: Bson, keys: varargs[string]): Bson =

    source line: `877 <../src/bson.nim#L877>`__



.. _add.p:
add
---------------------------------------------------------

    .. code:: nim

        proc add*[T](bs: Bson, value: T): Bson {.discardable.} =

    source line: `855 <../src/bson.nim#L855>`__



.. _bin.p:
bin
---------------------------------------------------------

    .. code:: nim

        proc bin*(bindata: string): Bson =

    source line: `805 <../src/bson.nim#L805>`__

    Create new binary Bson object with 'generic' subtype


.. _binstr.p:
binstr
---------------------------------------------------------

    .. code:: nim

        proc binstr*(x: Bson): string =

    source line: `813 <../src/bson.nim#L813>`__



.. _binuser.p:
binuser
---------------------------------------------------------

    .. code:: nim

        proc binuser*(bindata: string): Bson =

    source line: `824 <../src/bson.nim#L824>`__

    Create new binray Bson object with 'user-defined' subtype


.. _bytes.p:
bytes
---------------------------------------------------------

    .. code:: nim

        proc bytes*(bs: Bson): string =

    source line: `663 <../src/bson.nim#L663>`__

    Serialize Bson document into a raw byte-stream
    
    Returns a binary string (not generally printable)


.. _contains.p:
contains
---------------------------------------------------------

    .. code:: nim

        proc contains*(bs: Bson, key: string): bool =

    source line: `910 <../src/bson.nim#L910>`__

    Checks if Bson document has a specified field


.. _dbref.p:
dbref
---------------------------------------------------------

    .. code:: nim

        proc dbref*(refCollection: string, refOid: Oid): Bson =

    source line: `769 <../src/bson.nim#L769>`__

    Create a new DBRef (database reference) MongoDB bson type
    
    refCollection
      the name of the collection being referenced
    
    refOid
      the ``_id`` of the document sitting in the collection
    
    Returns a BSON object


.. _del.p:
del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, idx: int) =

    source line: `871 <../src/bson.nim#L871>`__



.. _del.p:
del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, key: string) =

    source line: `859 <../src/bson.nim#L859>`__



.. _delete.p:
delete
---------------------------------------------------------

    .. code:: nim

        proc delete*(bs: Bson, idx: int) =

    source line: `865 <../src/bson.nim#L865>`__



.. _geo.p:
geo
---------------------------------------------------------

    .. code:: nim

        proc geo*(loc: GeoPoint): Bson =

    source line: `832 <../src/bson.nim#L832>`__

    Convert array of two floats into Bson as MongoDB Geo-Point.


.. _items.i:
items
---------------------------------------------------------

    .. code:: nim

        iterator items*(bs: Bson): Bson =

    source line: `895 <../src/bson.nim#L895>`__

    Iterate over Bson document or array fields


.. _js.p:
js
---------------------------------------------------------

    .. code:: nim

        proc js*(code: string): Bson =

    source line: `801 <../src/bson.nim#L801>`__

    Create new Bson value representing JavaScript code bson type


.. _len.p:
len
---------------------------------------------------------

    .. code:: nim

        proc len*(bs: Bson):int =

    source line: `846 <../src/bson.nim#L846>`__



.. _maxkey.p:
maxkey
---------------------------------------------------------

    .. code:: nim

        proc maxkey*(): Bson =

    source line: `793 <../src/bson.nim#L793>`__

    Create new Bson value representing 'Max key' bson type


.. _merge.p:
merge
---------------------------------------------------------

    .. code:: nim

        proc merge*(a, b: Bson): Bson =

    source line: `1025 <../src/bson.nim#L1025>`__

    Combine two BSON documents into a new one.
    
    The resulting document contains all the fields of both.
    If both ``a`` and ``b`` contain the same field, the
    value in ``b`` is used.
    
    For example:
    
    
    .. code:: nim
    
        let a = @@{"name": "Joe", "age": 42, weight: 50 }
        let b = @@{"name": "Joe", "feet": 2, weight: 52 }
        let both = a.merge(b)
        echo $both
    
    displays
    
    .. code:: json
    
        {
            "name" : "Joe",
            "age" : 42,
            "weight" : 52,
            "feet" : 2
        }
    
    Returns the combined BSON document.


.. _minkey.p:
minkey
---------------------------------------------------------

    .. code:: nim

        proc minkey*(): Bson =

    source line: `789 <../src/bson.nim#L789>`__

    Create new Bson value representing 'Min key' bson type


.. _newBsonArray.p:
newBsonArray
---------------------------------------------------------

    .. code:: nim

        proc newBsonArray*(): Bson =

    source line: `681 <../src/bson.nim#L681>`__

    Create new Bson array


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(): Bson =

    source line: `676 <../src/bson.nim#L676>`__

    Create new empty Bson document


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(bytes: string): Bson =

    source line: `1021 <../src/bson.nim#L1021>`__

    Create new Bson document from byte string


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(s: Stream): Bson =

    source line: `923 <../src/bson.nim#L923>`__

    Create new Bson document from a byte stream


.. _null.p:
null
---------------------------------------------------------

    .. code:: nim

        proc null*(): Bson =

    source line: `785 <../src/bson.nim#L785>`__

    Create new Bson 'null' value


.. _pairs.i:
pairs
---------------------------------------------------------

    .. code:: nim

        iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =

    source line: `904 <../src/bson.nim#L904>`__

    Iterate over Bson document


.. _regex.p:
regex
---------------------------------------------------------

    .. code:: nim

        proc regex*(pattern: string, options: string): Bson =

    source line: `797 <../src/bson.nim#L797>`__

    Create new Bson value representing Regexp bson type


.. _timeUTC.p:
timeUTC
---------------------------------------------------------

    .. code:: nim

        proc timeUTC*(time: Time): Bson =

    source line: `839 <../src/bson.nim#L839>`__

    Create UTC datetime Bson object.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =

    source line: `717 <../src/bson.nim#L717>`__

    Generic constructor for BSON data.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: BsonTimestamp): Bson =

    source line: `529 <../src/bson.nim#L529>`__

    Convert inner BsonTimestamp to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: MD5Digest): Bson =

    source line: `537 <../src/bson.nim#L537>`__

    Convert MD5Digest to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Oid): Bson =

    source line: `331 <../src/bson.nim#L331>`__

    Convert Mongo Object Id to Bson object
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Time): Bson =

    source line: `510 <../src/bson.nim#L510>`__

    Convert Time to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: bool): Bson =

    source line: `491 <../src/bson.nim#L491>`__

    Convert bool to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: float64): Bson =

    source line: `374 <../src/bson.nim#L374>`__

    Convert float64 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int): Bson =

    source line: `476 <../src/bson.nim#L476>`__

    Convert int to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int32): Bson =

    source line: `441 <../src/bson.nim#L441>`__

    Convert int32 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int64): Bson =

    source line: `416 <../src/bson.nim#L416>`__

    Convert int64 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: string): Bson =

    source line: `393 <../src/bson.nim#L393>`__

    Convert string to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: var MD5Context): Bson =

    source line: `541 <../src/bson.nim#L541>`__

    Convert MD5Context to Bson object (still digest from current context).
    :WARNING: MD5Context is finalized during conversion.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*[T](vals: openArray[T]): Bson =

    source line: `722 <../src/bson.nim#L722>`__



.. _undefined.p:
undefined
---------------------------------------------------------

    .. code:: nim

        proc undefined*(): Bson =

    source line: `781 <../src/bson.nim#L781>`__

    Create new Bson 'undefined' value


.. _update.p:
update
---------------------------------------------------------

    .. code:: nim

        proc update*(a, b: Bson)=

    source line: `1073 <../src/bson.nim#L1073>`__

    Modifies the content of document ``a`` with the updated content of document ``b``.
    
    If ``a`` and ``b`` contain the same field, the value in ``b`` is set
    in ``a``.
    
    Works with both documents and arrays. With anything else, nothing happens.




Converters
==========


.. _toBool.c:
toBool
---------------------------------------------------------

    .. code:: nim

        converter toBool*(x: Bson): bool =

    source line: `495 <../src/bson.nim#L495>`__

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

    source line: `378 <../src/bson.nim#L378>`__

    Convert Bson object to float64


.. _toInt.c:
toInt
---------------------------------------------------------

    .. code:: nim

        converter toInt*(x: Bson): int =

    source line: `466 <../src/bson.nim#L466>`__

    Convert Bson to int whether it is int32 or int64


.. _toInt32.c:
toInt32
---------------------------------------------------------

    .. code:: nim

        converter toInt32*(x: Bson): int32 =

    source line: `445 <../src/bson.nim#L445>`__

    Convert Bson to int32


.. _toInt64.c:
toInt64
---------------------------------------------------------

    .. code:: nim

        converter toInt64*(x: Bson): int64 =

    source line: `420 <../src/bson.nim#L420>`__

    Convert Bson object to int


.. _toOid.c:
toOid
---------------------------------------------------------

    .. code:: nim

        converter toOid*(x: Bson): Oid =

    source line: `340 <../src/bson.nim#L340>`__

    Convert Bson to Mongo Object ID
    
    if x is a null, then the all-zeroes Oid is returned
    if x is a real Oid, then that value is returned
    if x is a string, then an attempt is made to parse it to an Oid
    otherwise, the all-zeroes Oid is returned


.. _toString.c:
toString
---------------------------------------------------------

    .. code:: nim

        converter toString*(x: Bson): string =

    source line: `397 <../src/bson.nim#L397>`__

    Convert Bson to UTF8 string


.. _toTime.c:
toTime
---------------------------------------------------------

    .. code:: nim

        converter toTime*(x: Bson): Time =

    source line: `514 <../src/bson.nim#L514>`__

    Convert Bson object to Time


.. _toTimestamp.c:
toTimestamp
---------------------------------------------------------

    .. code:: nim

        converter toTimestamp*(x: Bson): BsonTimestamp =

    source line: `533 <../src/bson.nim#L533>`__

    Convert Bson object to inner BsonTimestamp type




Macros and Templates
====================


.. _`%*`.m:
`%*`
---------------------------------------------------------

    .. code:: nim

        macro `%*`*(x: untyped): Bson =

    source line: `753 <../src/bson.nim#L753>`__

    Perform dict-like structure conversion into bson


.. _`@@`.m:
`@@`
---------------------------------------------------------

    .. code:: nim

        macro `@@`*(x: untyped): Bson =

    source line: `757 <../src/bson.nim#L757>`__



.. _toBson.t:
toBson
---------------------------------------------------------

    .. code:: nim

        template toBson*(b: Bson): Bson = b

    source line: `726 <../src/bson.nim#L726>`__

    





Table Of Contents
=================

1. `Introduction to bson <index.rst>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
