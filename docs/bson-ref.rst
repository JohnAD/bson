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

    source line: `724 <../src/bson.nim#L724>`__

    Modify Bson array element


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Bson) =

    source line: `710 <../src/bson.nim#L710>`__

    Modify Bson document field


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Oid) =
        proc `[]=`*(bs: Bson, key: string, value: string) =  
        proc `[]=`*(bs: Bson, key: string, value: int64) =  
        proc `[]=`*(bs: Bson, key: string, value: int32) =  
        proc `[]=`*(bs: Bson, key: string, value: int) =  
        proc `[]=`*(bs: Bson, key: string, value: bool) =  
        proc `[]=`*(bs: Bson, key: string, value: Time) =  

    source line: `373 <../src/bson.nim#L373>`__

    Modify Bson document field with an explicit Oid value
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: float64) =
        proc `[]=`*(bs: Bson, key: string, value: string) =  
        proc `[]=`*(bs: Bson, key: string, value: int64) =  
        proc `[]=`*(bs: Bson, key: string, value: int32) =  
        proc `[]=`*(bs: Bson, key: string, value: int) =  
        proc `[]=`*(bs: Bson, key: string, value: bool) =  
        proc `[]=`*(bs: Bson, key: string, value: Time) =  

    source line: `395 <../src/bson.nim#L395>`__

    Modify Bson document field with an explicit value


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: int): Bson =

    source line: `717 <../src/bson.nim#L717>`__

    Get BSON array item by index


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: string): Bson =

    source line: `703 <../src/bson.nim#L703>`__

    Get BSON object field


.. _`{}=`.p:
`{}=`
---------------------------------------------------------

    .. code:: nim

        proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =

    source line: `944 <../src/bson.nim#L944>`__



.. _`{}`.p:
`{}`
---------------------------------------------------------

    .. code:: nim

        proc `{}`*(bs: Bson, keys: varargs[string]): Bson =

    source line: `934 <../src/bson.nim#L934>`__



.. _add.p:
add
---------------------------------------------------------

    .. code:: nim

        proc add*[T](bs: Bson, value: T): Bson {.discardable.} =

    source line: `897 <../src/bson.nim#L897>`__

    Add a new BSON item to the the array's list.
    
    It both returns a new BSON array and modifies the original in-place.


.. _bin.p:
bin
---------------------------------------------------------

    .. code:: nim

        proc bin*(bindata: string): Bson =

    source line: `826 <../src/bson.nim#L826>`__

    Create new binary Bson object with 'generic' subtype
    
    To convert it back to a "binary string", use ``binstr``.
    
    Returns a new BSON object


.. _binstr.p:
binstr
---------------------------------------------------------

    .. code:: nim

        proc binstr*(x: Bson): string =

    source line: `838 <../src/bson.nim#L838>`__

    Generate a "binary string" equivalent of the BSON "Generic Binary" field type.
    
    This is used strictly for that field type field. If you are wanting to
    convert a BSON doc into it's true binary form, use ``bytes`` instead.


.. _binuser.p:
binuser
---------------------------------------------------------

    .. code:: nim

        proc binuser*(bindata: string): Bson =

    source line: `856 <../src/bson.nim#L856>`__

    Create new binary BSON object with 'user-defined' subtype
    
    Returns a new BSON object


.. _bytes.p:
bytes
---------------------------------------------------------

    .. code:: nim

        proc bytes*(bs: Bson): string =

    source line: `675 <../src/bson.nim#L675>`__

    Serialize a BSON document into a raw byte-stream.
    
    Returns a binary string (not generally printable)


.. _contains.p:
contains
---------------------------------------------------------

    .. code:: nim

        proc contains*(bs: Bson, key: string): bool =

    source line: `971 <../src/bson.nim#L971>`__

    Checks if Bson document has a specified field
    
    Returns true if found, false otherwise.


.. _dbref.p:
dbref
---------------------------------------------------------

    .. code:: nim

        proc dbref*(refCollection: string, refOid: Oid): Bson =

    source line: `778 <../src/bson.nim#L778>`__

    Create a new DBRef (database reference) MongoDB bson type
    
    refCollection
      the name of the collection being referenced
    
    refOid
      the ``_id`` of the document sitting in the collection
    
    Returns a new BSON object


.. _del.p:
del
---------------------------------------------------------

    .. code:: nim

        proc del*(bs: Bson, key: string) =
        proc del*(bs: Bson, idx: int) =  
        proc delete*(bs: Bson, key: string) =  
        proc delete*(bs: Bson, idx: int) =  

    source line: `904 <../src/bson.nim#L904>`__

    Deletes a field from a BSON object or array.
    
    If passed a string, it removes a field from an object.
    If passed an integer, it removes an item by index from an array
    
    This procedure modifies the object that is passed to it.


.. _geo.p:
geo
---------------------------------------------------------

    .. code:: nim

        proc geo*(loc: GeoPoint): Bson =

    source line: `866 <../src/bson.nim#L866>`__

    Convert array of two floats into Bson as MongoDB Geo-Point.
    
    Returns a new BSON object


.. _items.i:
items
---------------------------------------------------------

    .. code:: nim

        iterator items*(bs: Bson): Bson =

    source line: `952 <../src/bson.nim#L952>`__

    Iterate over BSON object field values or array items
    
    Each calls returns one BSON item.


.. _js.p:
js
---------------------------------------------------------

    .. code:: nim

        proc js*(code: string): Bson =

    source line: `820 <../src/bson.nim#L820>`__

    Create new Bson value representing JavaScript code bson type
    
    Returns a new BSON object


.. _len.p:
len
---------------------------------------------------------

    .. code:: nim

        proc len*(bs: Bson):int =

    source line: `884 <../src/bson.nim#L884>`__

    Get the length of an array or the number of fields in an object.
    
    If not an array or object, an exception is generated.
    
    Returns the length as an integer.


.. _maxkey.p:
maxkey
---------------------------------------------------------

    .. code:: nim

        proc maxkey*(): Bson =

    source line: `808 <../src/bson.nim#L808>`__

    Create new BSON value representing 'Max key' BSON type
    
    Returns a new BSON object


.. _merge.p:
merge
---------------------------------------------------------

    .. code:: nim

        proc merge*(a, b: Bson): Bson =

    source line: `1088 <../src/bson.nim#L1088>`__

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

    source line: `802 <../src/bson.nim#L802>`__

    Create new BSON value representing 'Min key' BSON type
    
    Returns a new BSON object


.. _newBsonArray.p:
newBsonArray
---------------------------------------------------------

    .. code:: nim

        proc newBsonArray*(): Bson =

    source line: `693 <../src/bson.nim#L693>`__

    Create new Bson array


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(): Bson =

    source line: `688 <../src/bson.nim#L688>`__

    Create new empty Bson document


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(bytes: string): Bson =

    source line: `1084 <../src/bson.nim#L1084>`__

    Create new Bson document from byte string


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(s: Stream): Bson =

    source line: `986 <../src/bson.nim#L986>`__

    Create new Bson document from a byte stream


.. _null.p:
null
---------------------------------------------------------

    .. code:: nim

        proc null*(): Bson =

    source line: `796 <../src/bson.nim#L796>`__

    Create new BSON 'null' value
    
    Returns a new BSON object


.. _pairs.i:
pairs
---------------------------------------------------------

    .. code:: nim

        iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =

    source line: `963 <../src/bson.nim#L963>`__

    Iterate over BSON object's fields
    
    Each call returns one (key, value) tuple.


.. _regex.p:
regex
---------------------------------------------------------

    .. code:: nim

        proc regex*(pattern: string, options: string): Bson =

    source line: `814 <../src/bson.nim#L814>`__

    Create new Bson value representing Regexp BSON type
    
    Returns a new BSON object


.. _timeUTC.p:
timeUTC
---------------------------------------------------------

    .. code:: nim

        proc timeUTC*(time: Time): Bson =

    source line: `875 <../src/bson.nim#L875>`__

    Create UTC datetime BSON object.
    
    Returns a new BSON object.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =

    source line: `729 <../src/bson.nim#L729>`__

    Generic constructor for BSON data.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: Oid): Bson =
        proc toBson*(x: string): Bson =  
        proc toBson*(x: int64): Bson =   
        converter toInt64*(x: Bson): int64 =   
        proc toBson*(x: int32): Bson =   
        proc toBson*(x: int): Bson =   
        proc toBson*(x: bool): Bson =   
        proc toBson*(x: Time): Bson =  
        proc toBson*(x: BsonTimestamp): Bson =  
        proc toBson*(x: MD5Digest): Bson =  

    source line: `343 <../src/bson.nim#L343>`__

    Convert Nim Object Id to BSON object. See the ``oids`` standard Nim library.
    
    If the Oid is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an ObjectID value


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: float64): Bson =
        proc toBson*(x: string): Bson =  
        proc toBson*(x: int64): Bson =   
        converter toInt64*(x: Bson): int64 =   
        proc toBson*(x: int32): Bson =   
        proc toBson*(x: int): Bson =   
        proc toBson*(x: bool): Bson =   
        proc toBson*(x: Time): Bson =  
        proc toBson*(x: BsonTimestamp): Bson =  
        proc toBson*(x: MD5Digest): Bson =  

    source line: `387 <../src/bson.nim#L387>`__

    Convert value to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: var MD5Context): Bson =

    source line: `553 <../src/bson.nim#L553>`__

    Convert MD5Context to Bson object (still digest from current context).
    :WARNING: MD5Context is finalized during conversion.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*[T](vals: openArray[T]): Bson =

    source line: `734 <../src/bson.nim#L734>`__



.. _undefined.p:
undefined
---------------------------------------------------------

    .. code:: nim

        proc undefined*(): Bson =

    source line: `790 <../src/bson.nim#L790>`__

    Create new Bson 'undefined' value
    
    Returns a new BSON object


.. _update.p:
update
---------------------------------------------------------

    .. code:: nim

        proc update*(a, b: Bson)=

    source line: `1136 <../src/bson.nim#L1136>`__

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

        

    source line: `507 <../src/bson.nim#L507>`__

    Convert Bson object to bool


.. _toBsonKind.c:
toBsonKind
---------------------------------------------------------

    .. code:: nim

        

    source line: `192 <../src/bson.nim#L192>`__

    Convert char to BsonKind


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        

    source line: `184 <../src/bson.nim#L184>`__

    Convert BsonKind to char


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        

    source line: `188 <../src/bson.nim#L188>`__

    Convert BsonSubtype to char


.. _toFloat64.c:
toFloat64
---------------------------------------------------------

    .. code:: nim

        

    source line: `391 <../src/bson.nim#L391>`__

    Convert Bson object to float64


.. _toInt.c:
toInt
---------------------------------------------------------

    .. code:: nim

        

    source line: `478 <../src/bson.nim#L478>`__

    Convert Bson to int whether it is int32 or int64


.. _toInt32.c:
toInt32
---------------------------------------------------------

    .. code:: nim

        

    source line: `457 <../src/bson.nim#L457>`__

    Convert Bson to int32


.. _toOid.c:
toOid
---------------------------------------------------------

    .. code:: nim

        

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

        

    source line: `410 <../src/bson.nim#L410>`__

    Convert Bson to UTF8 string


.. _toTime.c:
toTime
---------------------------------------------------------

    .. code:: nim

        

    source line: `526 <../src/bson.nim#L526>`__

    Convert Bson object to Time


.. _toTimestamp.c:
toTimestamp
---------------------------------------------------------

    .. code:: nim

        

    source line: `545 <../src/bson.nim#L545>`__

    Convert Bson object to inner BsonTimestamp type




Macros and Templates
====================


.. _`@@`.m:
`@@`
---------------------------------------------------------

    .. code:: nim

        macro `@@`*(x: untyped): Bson =

    source line: `766 <../src/bson.nim#L766>`__



.. _toBson.t:
toBson
---------------------------------------------------------

    .. code:: nim

        template toBson*(b: Bson): Bson = b

    source line: `738 <../src/bson.nim#L738>`__

    





Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
