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


    source line: `203 <../src/bson.nim#L203>`__



.. _BsonTimestamp.type:
BsonTimestamp
---------------------------------------------------------

    .. code:: nim

        BsonTimestamp* = object ## Internal MongoDB type used by mongos instances
          increment*: int32
          timestamp*: int32


    source line: `199 <../src/bson.nim#L199>`__







Procs, Methods, Iterators
=========================


.. _`$`.p:
`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(bs: Bson): string =

    source line: `247 <../src/bson.nim#L247>`__

    Serialize Bson document into readable string


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: int, value: Bson) =

    source line: `725 <../src/bson.nim#L725>`__

    Modify Bson array element


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Bson) =

    source line: `711 <../src/bson.nim#L711>`__

    Modify Bson document field


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Oid) =

    source line: `373 <../src/bson.nim#L373>`__

    Modify Bson document field with an explicit Oid value
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Time) =

    source line: `531 <../src/bson.nim#L531>`__

    Modify Bson document field with an explicit Time value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: bool) =

    source line: `512 <../src/bson.nim#L512>`__

    Modify Bson document field with an explicit bool value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: float64) =

    source line: `395 <../src/bson.nim#L395>`__

    Modify Bson document field with an explicit float64 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int) =

    source line: `493 <../src/bson.nim#L493>`__

    Modify Bson document field with an explicit int value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int32) =

    source line: `468 <../src/bson.nim#L468>`__

    Modify Bson document field with an explicit int32 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: int64) =

    source line: `443 <../src/bson.nim#L443>`__

    Modify Bson document field with an explicit int64 value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: string) =

    source line: `418 <../src/bson.nim#L418>`__

    Modify Bson document field with an explicit string value


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: int): Bson =

    source line: `718 <../src/bson.nim#L718>`__

    Get Bson array item by index


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: string): Bson =

    source line: `704 <../src/bson.nim#L704>`__

    Get Bson document field


.. _`{}=`.p:
`{}=`
---------------------------------------------------------

    .. code:: nim

        proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =

    source line: `897 <../src/bson.nim#L897>`__



.. _`{}`.p:
`{}`
---------------------------------------------------------

    .. code:: nim

        proc `{}`*(bs: Bson, keys: varargs[string]): Bson =

    source line: `887 <../src/bson.nim#L887>`__



.. _add.p:
add
---------------------------------------------------------

    .. code:: nim

        proc add*[T](bs: Bson, value: T): Bson {.discardable.} =

    source line: `865 <../src/bson.nim#L865>`__



.. _bin.p:
bin
---------------------------------------------------------

    .. code:: nim

        proc bin*(bindata: string): Bson =

    source line: `815 <../src/bson.nim#L815>`__

    Create new binary Bson object with 'generic' subtype


.. _binstr.p:
binstr
---------------------------------------------------------

    .. code:: nim

        proc binstr*(x: Bson): string =

    source line: `823 <../src/bson.nim#L823>`__



.. _binuser.p:
binuser
---------------------------------------------------------

    .. code:: nim

        proc binuser*(bindata: string): Bson =

    source line: `834 <../src/bson.nim#L834>`__

    Create new binray Bson object with 'user-defined' subtype


.. _bytes.p:
bytes
---------------------------------------------------------

    .. code:: nim

        proc bytes*(bs: Bson): string =

    source line: `676 <../src/bson.nim#L676>`__

    Serialize Bson document into a raw byte-stream
    
    Returns a binary string (not generally printable)


.. _contains.p:
contains
---------------------------------------------------------

    .. code:: nim

        proc contains*(bs: Bson, key: string): bool =

    source line: `920 <../src/bson.nim#L920>`__

    Checks if Bson document has a specified field


.. _dbref.p:
dbref
---------------------------------------------------------

    .. code:: nim

        proc dbref*(refCollection: string, refOid: Oid): Bson =

    source line: `779 <../src/bson.nim#L779>`__

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

    source line: `881 <../src/bson.nim#L881>`__



.. _del.p:
del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, key: string) =

    source line: `869 <../src/bson.nim#L869>`__



.. _delete.p:
delete
---------------------------------------------------------

    .. code:: nim

        proc delete*(bs: Bson, idx: int) =

    source line: `875 <../src/bson.nim#L875>`__



.. _geo.p:
geo
---------------------------------------------------------

    .. code:: nim

        proc geo*(loc: GeoPoint): Bson =

    source line: `842 <../src/bson.nim#L842>`__

    Convert array of two floats into Bson as MongoDB Geo-Point.


.. _items.i:
items
---------------------------------------------------------

    .. code:: nim

        iterator items*(bs: Bson): Bson =

    source line: `905 <../src/bson.nim#L905>`__

    Iterate over Bson document or array fields


.. _js.p:
js
---------------------------------------------------------

    .. code:: nim

        proc js*(code: string): Bson =

    source line: `811 <../src/bson.nim#L811>`__

    Create new Bson value representing JavaScript code bson type


.. _len.p:
len
---------------------------------------------------------

    .. code:: nim

        proc len*(bs: Bson):int =

    source line: `856 <../src/bson.nim#L856>`__



.. _maxkey.p:
maxkey
---------------------------------------------------------

    .. code:: nim

        proc maxkey*(): Bson =

    source line: `803 <../src/bson.nim#L803>`__

    Create new Bson value representing 'Max key' bson type


.. _merge.p:
merge
---------------------------------------------------------

    .. code:: nim

        proc merge*(a, b: Bson): Bson =

    source line: `1035 <../src/bson.nim#L1035>`__

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

    source line: `799 <../src/bson.nim#L799>`__

    Create new Bson value representing 'Min key' bson type


.. _newBsonArray.p:
newBsonArray
---------------------------------------------------------

    .. code:: nim

        proc newBsonArray*(): Bson =

    source line: `694 <../src/bson.nim#L694>`__

    Create new Bson array


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(): Bson =

    source line: `689 <../src/bson.nim#L689>`__

    Create new empty Bson document


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(bytes: string): Bson =

    source line: `1031 <../src/bson.nim#L1031>`__

    Create new Bson document from byte string


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(s: Stream): Bson =

    source line: `933 <../src/bson.nim#L933>`__

    Create new Bson document from a byte stream


.. _null.p:
null
---------------------------------------------------------

    .. code:: nim

        proc null*(): Bson =

    source line: `795 <../src/bson.nim#L795>`__

    Create new Bson 'null' value


.. _pairs.i:
pairs
---------------------------------------------------------

    .. code:: nim

        iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =

    source line: `914 <../src/bson.nim#L914>`__

    Iterate over Bson document


.. _regex.p:
regex
---------------------------------------------------------

    .. code:: nim

        proc regex*(pattern: string, options: string): Bson =

    source line: `807 <../src/bson.nim#L807>`__

    Create new Bson value representing Regexp bson type


.. _timeUTC.p:
timeUTC
---------------------------------------------------------

    .. code:: nim

        proc timeUTC*(time: Time): Bson =

    source line: `849 <../src/bson.nim#L849>`__

    Create UTC datetime Bson object.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =

    source line: `730 <../src/bson.nim#L730>`__

    Generic constructor for BSON data.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: BsonTimestamp): Bson =

    source line: `542 <../src/bson.nim#L542>`__

    Convert inner BsonTimestamp to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: MD5Digest): Bson =

    source line: `550 <../src/bson.nim#L550>`__

    Convert MD5Digest to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Oid): Bson =

    source line: `343 <../src/bson.nim#L343>`__

    Convert Mongo Object Id to Bson object
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Time): Bson =

    source line: `523 <../src/bson.nim#L523>`__

    Convert Time to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: bool): Bson =

    source line: `504 <../src/bson.nim#L504>`__

    Convert bool to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: float64): Bson =

    source line: `387 <../src/bson.nim#L387>`__

    Convert float64 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int): Bson =

    source line: `489 <../src/bson.nim#L489>`__

    Convert int to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int32): Bson =

    source line: `454 <../src/bson.nim#L454>`__

    Convert int32 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: int64): Bson =

    source line: `429 <../src/bson.nim#L429>`__

    Convert int64 to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: string): Bson =

    source line: `406 <../src/bson.nim#L406>`__

    Convert string to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: var MD5Context): Bson =

    source line: `554 <../src/bson.nim#L554>`__

    Convert MD5Context to Bson object (still digest from current context).
    :WARNING: MD5Context is finalized during conversion.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*[T](vals: openArray[T]): Bson =

    source line: `735 <../src/bson.nim#L735>`__



.. _undefined.p:
undefined
---------------------------------------------------------

    .. code:: nim

        proc undefined*(): Bson =

    source line: `791 <../src/bson.nim#L791>`__

    Create new Bson 'undefined' value


.. _update.p:
update
---------------------------------------------------------

    .. code:: nim

        proc update*(a, b: Bson)=

    source line: `1083 <../src/bson.nim#L1083>`__

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

    source line: `508 <../src/bson.nim#L508>`__

    Convert Bson object to bool


.. _toBsonKind.c:
toBsonKind
---------------------------------------------------------

    .. code:: nim

        converter toBsonKind*(c: char): BsonKind =

    source line: `192 <../src/bson.nim#L192>`__

    Convert char to BsonKind


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        converter toChar*(bk: BsonKind): char =

    source line: `184 <../src/bson.nim#L184>`__

    Convert BsonKind to char


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        converter toChar*(sub: BsonSubtype): char =

    source line: `188 <../src/bson.nim#L188>`__

    Convert BsonSubtype to char


.. _toFloat64.c:
toFloat64
---------------------------------------------------------

    .. code:: nim

        converter toFloat64*(x: Bson): float64 =

    source line: `391 <../src/bson.nim#L391>`__

    Convert Bson object to float64


.. _toInt.c:
toInt
---------------------------------------------------------

    .. code:: nim

        converter toInt*(x: Bson): int =

    source line: `479 <../src/bson.nim#L479>`__

    Convert Bson to int whether it is int32 or int64


.. _toInt32.c:
toInt32
---------------------------------------------------------

    .. code:: nim

        converter toInt32*(x: Bson): int32 =

    source line: `458 <../src/bson.nim#L458>`__

    Convert Bson to int32


.. _toInt64.c:
toInt64
---------------------------------------------------------

    .. code:: nim

        converter toInt64*(x: Bson): int64 =

    source line: `433 <../src/bson.nim#L433>`__

    Convert Bson object to int


.. _toOid.c:
toOid
---------------------------------------------------------

    .. code:: nim

        converter toOid*(x: Bson): Oid =

    source line: `353 <../src/bson.nim#L353>`__

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

    source line: `410 <../src/bson.nim#L410>`__

    Convert Bson to UTF8 string


.. _toTime.c:
toTime
---------------------------------------------------------

    .. code:: nim

        converter toTime*(x: Bson): Time =

    source line: `527 <../src/bson.nim#L527>`__

    Convert Bson object to Time


.. _toTimestamp.c:
toTimestamp
---------------------------------------------------------

    .. code:: nim

        converter toTimestamp*(x: Bson): BsonTimestamp =

    source line: `546 <../src/bson.nim#L546>`__

    Convert Bson object to inner BsonTimestamp type




Macros and Templates
====================


.. _`@@`.m:
`@@`
---------------------------------------------------------

    .. code:: nim

        macro `@@`*(x: untyped): Bson =

    source line: `767 <../src/bson.nim#L767>`__



.. _toBson.t:
toBson
---------------------------------------------------------

    .. code:: nim

        template toBson*(b: Bson): Bson = b

    source line: `739 <../src/bson.nim#L739>`__

    





Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
