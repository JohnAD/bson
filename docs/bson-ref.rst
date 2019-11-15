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


    source line: `181 <../src/bson.nim#L181>`__



.. _BsonTimestamp.type:
BsonTimestamp
---------------------------------------------------------

    .. code:: nim

        BsonTimestamp* = object ## Internal MongoDB type used by mongos instances
          increment*: int32
          timestamp*: int32


    source line: `177 <../src/bson.nim#L177>`__







Procs, Methods, Iterators
=========================


.. _`$`.p:
`$`
---------------------------------------------------------

    .. code:: nim

        proc `$`*(bs: Bson): string =

    source line: `225 <../src/bson.nim#L225>`__

    Serialize Bson document into readable string


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: int, value: Bson) =

    source line: `704 <../src/bson.nim#L704>`__

    Modify Bson array element


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Bson) =

    source line: `690 <../src/bson.nim#L690>`__

    Modify Bson document field


.. _`[]=`.p:
`[]=`
---------------------------------------------------------

    .. code:: nim

        proc `[]=`*(bs: Bson, key: string, value: Oid) =
        proc `[]=`*(bs: Bson, key: string, value: float64) = 
        proc `[]=`*(bs: Bson, key: string, value: string) =  
        proc `[]=`*(bs: Bson, key: string, value: int64) =  
        proc `[]=`*(bs: Bson, key: string, value: int32) =  
        proc `[]=`*(bs: Bson, key: string, value: int) =  
        proc `[]=`*(bs: Bson, key: string, value: bool) =  
        proc `[]=`*(bs: Bson, key: string, value: Time) =  

    source line: `351 <../src/bson.nim#L351>`__

    Modify BSON object field with an explicit value
    
    If setting an ``Oid`` and the Object ID is all-zeroes ("000000000000000000000000"), then
    a null field is stored rather than an Object ID value
    
    Returns a Bson object


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: int): Bson =

    source line: `697 <../src/bson.nim#L697>`__

    Get BSON array item by index


.. _`[]`.p:
`[]`
---------------------------------------------------------

    .. code:: nim

        proc `[]`*(bs: Bson, key: string): Bson =

    source line: `683 <../src/bson.nim#L683>`__

    Get BSON object field


.. _`{}=`.p:
`{}=`
---------------------------------------------------------

    .. code:: nim

        proc `{}=`*(bs: Bson, keys: varargs[string], value: Bson) =

    source line: `924 <../src/bson.nim#L924>`__



.. _`{}`.p:
`{}`
---------------------------------------------------------

    .. code:: nim

        proc `{}`*(bs: Bson, keys: varargs[string]): Bson =

    source line: `914 <../src/bson.nim#L914>`__



.. _add.p:
add
---------------------------------------------------------

    .. code:: nim

        proc add*[T](bs: Bson, value: T): Bson {.discardable.} =

    source line: `877 <../src/bson.nim#L877>`__

    Add a new BSON item to the the array's list.
    
    It both returns a new BSON array and modifies the original in-place.


.. _bin.p:
bin
---------------------------------------------------------

    .. code:: nim

        proc bin*(bindata: string): Bson =

    source line: `806 <../src/bson.nim#L806>`__

    Create new binary Bson object with 'generic' subtype
    
    To convert it back to a "binary string", use ``binstr``.
    
    Returns a new BSON object


.. _binstr.p:
binstr
---------------------------------------------------------

    .. code:: nim

        proc binstr*(x: Bson): string =

    source line: `818 <../src/bson.nim#L818>`__

    Generate a "binary string" equivalent of the BSON "Generic Binary" field type.
    
    This is used strictly for that field type field. If you are wanting to
    convert a BSON doc into it's true binary form, use ``bytes`` instead.


.. _binuser.p:
binuser
---------------------------------------------------------

    .. code:: nim

        proc binuser*(bindata: string): Bson =

    source line: `836 <../src/bson.nim#L836>`__

    Create new binary BSON object with 'user-defined' subtype
    
    Returns a new BSON object


.. _bytes.p:
bytes
---------------------------------------------------------

    .. code:: nim

        proc bytes*(bs: Bson): string =

    source line: `655 <../src/bson.nim#L655>`__

    Serialize a BSON document into a raw byte-stream.
    
    Returns a binary string (not generally printable)


.. _contains.p:
contains
---------------------------------------------------------

    .. code:: nim

        proc contains*(bs: Bson, key: string): bool =

    source line: `951 <../src/bson.nim#L951>`__

    Checks if Bson document has a specified field
    
    Returns true if found, false otherwise.


.. _dbref.p:
dbref
---------------------------------------------------------

    .. code:: nim

        proc dbref*(refCollection: string, refOid: Oid): Bson =

    source line: `758 <../src/bson.nim#L758>`__

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

    source line: `884 <../src/bson.nim#L884>`__

    Deletes a field from a BSON object or array.
    
    If passed a string, it removes a field from an object.
    If passed an integer, it removes an item by index from an array
    
    This procedure modifies the object that is passed to it.


.. _geo.p:
geo
---------------------------------------------------------

    .. code:: nim

        proc geo*(loc: GeoPoint): Bson =

    source line: `846 <../src/bson.nim#L846>`__

    Convert array of two floats into Bson as MongoDB Geo-Point.
    
    Returns a new BSON object


.. _items.i:
items
---------------------------------------------------------

    .. code:: nim

        iterator items*(bs: Bson): Bson =

    source line: `932 <../src/bson.nim#L932>`__

    Iterate over BSON object field values or array items
    
    Each calls returns one BSON item.


.. _js.p:
js
---------------------------------------------------------

    .. code:: nim

        proc js*(code: string): Bson =

    source line: `800 <../src/bson.nim#L800>`__

    Create new Bson value representing JavaScript code bson type
    
    Returns a new BSON object


.. _len.p:
len
---------------------------------------------------------

    .. code:: nim

        proc len*(bs: Bson):int =

    source line: `864 <../src/bson.nim#L864>`__

    Get the length of an array or the number of fields in an object.
    
    If not an array or object, an exception is generated.
    
    Returns the length as an integer.


.. _maxkey.p:
maxkey
---------------------------------------------------------

    .. code:: nim

        proc maxkey*(): Bson =

    source line: `788 <../src/bson.nim#L788>`__

    Create new BSON value representing 'Max key' BSON type
    
    Returns a new BSON object


.. _merge.p:
merge
---------------------------------------------------------

    .. code:: nim

        proc merge*(a, b: Bson): Bson =

    source line: `1068 <../src/bson.nim#L1068>`__

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

    source line: `782 <../src/bson.nim#L782>`__

    Create new BSON value representing 'Min key' BSON type
    
    Returns a new BSON object


.. _newBsonArray.p:
newBsonArray
---------------------------------------------------------

    .. code:: nim

        proc newBsonArray*(): Bson =

    source line: `673 <../src/bson.nim#L673>`__

    Create new Bson array


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(): Bson =

    source line: `668 <../src/bson.nim#L668>`__

    Create new empty Bson document


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(bytes: string): Bson =

    source line: `1064 <../src/bson.nim#L1064>`__

    Create new Bson document from byte string


.. _newBsonDocument.p:
newBsonDocument
---------------------------------------------------------

    .. code:: nim

        proc newBsonDocument*(s: Stream): Bson =

    source line: `966 <../src/bson.nim#L966>`__

    Create new Bson document from a byte stream


.. _null.p:
null
---------------------------------------------------------

    .. code:: nim

        proc null*(): Bson =

    source line: `776 <../src/bson.nim#L776>`__

    Create new BSON 'null' value
    
    Returns a new BSON object


.. _pairs.i:
pairs
---------------------------------------------------------

    .. code:: nim

        iterator pairs*(bs: Bson): tuple[key: string, val: Bson] =

    source line: `943 <../src/bson.nim#L943>`__

    Iterate over BSON object's fields
    
    Each call returns one (key, value) tuple.


.. _regex.p:
regex
---------------------------------------------------------

    .. code:: nim

        proc regex*(pattern: string, options: string): Bson =

    source line: `794 <../src/bson.nim#L794>`__

    Create new Bson value representing Regexp BSON type
    
    Returns a new BSON object


.. _timeUTC.p:
timeUTC
---------------------------------------------------------

    .. code:: nim

        proc timeUTC*(time: Time): Bson =

    source line: `855 <../src/bson.nim#L855>`__

    Create UTC datetime BSON object.
    
    Returns a new BSON object.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(keyVals: openArray[tuple[key: string, val: Bson]]): Bson =

    source line: `709 <../src/bson.nim#L709>`__

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

    source line: `321 <../src/bson.nim#L321>`__

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

    source line: `367 <../src/bson.nim#L367>`__

    Convert value to Bson object


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*(x: var MD5Context): Bson =

    source line: `533 <../src/bson.nim#L533>`__

    Convert MD5Context to Bson object (still digest from current context).
    :WARNING: MD5Context is finalized during conversion.


.. _toBson.p:
toBson
---------------------------------------------------------

    .. code:: nim

        proc toBson*[T](vals: openArray[T]): Bson =

    source line: `714 <../src/bson.nim#L714>`__



.. _undefined.p:
undefined
---------------------------------------------------------

    .. code:: nim

        proc undefined*(): Bson =

    source line: `770 <../src/bson.nim#L770>`__

    Create new Bson 'undefined' value
    
    Returns a new BSON object


.. _update.p:
update
---------------------------------------------------------

    .. code:: nim

        proc update*(a, b: Bson)=

    source line: `1116 <../src/bson.nim#L1116>`__

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

        

    source line: `487 <../src/bson.nim#L487>`__

    Convert Bson object to bool


.. _toBsonKind.c:
toBsonKind
---------------------------------------------------------

    .. code:: nim

        

    source line: `170 <../src/bson.nim#L170>`__

    Convert char to BsonKind


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        

    source line: `162 <../src/bson.nim#L162>`__

    Convert BsonKind to char


.. _toChar.c:
toChar
---------------------------------------------------------

    .. code:: nim

        

    source line: `166 <../src/bson.nim#L166>`__

    Convert BsonSubtype to char


.. _toFloat64.c:
toFloat64
---------------------------------------------------------

    .. code:: nim

        

    source line: `371 <../src/bson.nim#L371>`__

    Convert Bson object to float64


.. _toInt.c:
toInt
---------------------------------------------------------

    .. code:: nim

        

    source line: `458 <../src/bson.nim#L458>`__

    Convert Bson to int whether it is int32 or int64


.. _toInt32.c:
toInt32
---------------------------------------------------------

    .. code:: nim

        

    source line: `437 <../src/bson.nim#L437>`__

    Convert Bson to int32


.. _toOid.c:
toOid
---------------------------------------------------------

    .. code:: nim

        

    source line: `331 <../src/bson.nim#L331>`__

    Convert Bson to Mongo Object ID
    
    if x is a null, then the all-zeroes Oid is returned
    if x is a real Oid, then that value is returned
    if x is a string, then an attempt is made to parse it to an Oid
    otherwise, the all-zeroes Oid is returned


.. _toString.c:
toString
---------------------------------------------------------

    .. code:: nim

        

    source line: `390 <../src/bson.nim#L390>`__

    Convert Bson to UTF8 string


.. _toTime.c:
toTime
---------------------------------------------------------

    .. code:: nim

        

    source line: `506 <../src/bson.nim#L506>`__

    Convert Bson object to Time


.. _toTimestamp.c:
toTimestamp
---------------------------------------------------------

    .. code:: nim

        

    source line: `525 <../src/bson.nim#L525>`__

    Convert Bson object to inner BsonTimestamp type




Macros and Templates
====================


.. _`@@`.m:
`@@`
---------------------------------------------------------

    .. code:: nim

        macro `@@`*(x: untyped): Bson =

    source line: `746 <../src/bson.nim#L746>`__



.. _toBson.t:
toBson
---------------------------------------------------------

    .. code:: nim

        template toBson*(b: Bson): Bson = b

    source line: `718 <../src/bson.nim#L718>`__

    





Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
