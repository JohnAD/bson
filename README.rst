Introduction to bson
==============================================================================
ver 1.0.1

.. image:: https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png
   :height: 34
   :width: 131
   :alt: nimble
   :target: https://nimble.directory/pkg/bson

.. image:: https://repo.support/img/rst-banner.png
   :height: 34
   :width: 131
   :alt: repo.support
   :target: https://repo.support/gh/JohnAD/bson

BSON

This is a Nim library for supporting BSON. BSON is short for Binary JSON -- a
compact binary protocol similar to the JSON it is based on.

Most notably, MongoDB, a document-oriented database uses BSON for it's
underlying storage, though there are other applications that use it as well.

More details about the protocol can be found at:

    http://bsonspec.org/

More detail can also be found in the reference document linked at the bottom.

CREATING A BSON DOCUMENT USING BRACKETS
---------------------------------------

You can use a pair of '@@' symbols prefixing a pair of curly braces with json-like
data in between to create a quick an easy BSON document.

For example:

.. code:: nim

    var doc = @@{"name": "Joe", "age": 42, "siblings": ["Amy", "Jerry"]}

CREATING A BSON DOCUMENT MANUALLY
---------------------------------

Start building a BSON document by declaring a new document with
`newBsonDocument` and start building out items in that document as if
were using a table.

.. code:: nim

    var doc = newBsonDocument()
    doc["name"] = "Joe"
    doc["age"] = 42

You can also add sub elements such as lists (with `newBsonArray`) and other
documents (with `newBsonDocument`):

.. code:: nim

    doc["siblings"] = newBsonArray()
    doc["siblings"].add "Amy"
    doc["siblings"].add "Jerry"
    doc["schedule"] = newBsonDocument()
    doc["schedule"]["8am"] = "go to work"
    doc["schedule"]["11am"] = "see dentist"

GENERATING THE BSON CODE
------------------------

To generate the actual binary code, such as to stream to a file or a service,
use the 'bytes' function:

.. code:: nim

    var bString: string = doc.bytes()

Please keep in mind that this is a **binary** **packed** string and is not printable.

To convert a binary blob of data back into a Bson library document, pass
the string into 'newBsonDocument' as a string parameter.

.. code:: nim

    var newDoc = newBsonDocument(bString)


HANDLING TYPES
--------------

The BSON specification calls for 18 types of data (and a few subtypes).

Not all of them are fully supported by the libary yet.

=============================== ================= ===========================
BSON                            Nim Equiv         Notes
=============================== ================= ===========================
64-bit binary floating point    float             Nim defaults to 64 bit
UTF-8 string                    string            Nim strings are UTF-8 ready by default
Embedded document               newBsonDocument   from this library. for key/value pairs, the key must always be a string
Array                           newBsonArray      technically a list, not an array, because you can mix types
Binary data                     string (binary)   not always printable, but works, see ``binstr``
ObjectId                        Oid               from standard `oids library <https://nim-lang.org/docs/oids.html>`_
Boolean "false"                 bool = false
Boolean "true"                  bool = true
UTC datetime                    Time              from standard `times library <https://nim-lang.org/docs/times.html>`_
Null value                      null              from this library
Regular expression              regex()           from this library
DBPointer (deprecated)          dbref()           from this library
JavaScript code                 js()              from this library
JavaScript code w/ scope
32-bit integer                  int32
Timestamp                       BsonTimestamp     from this library
64-bit integer                  int64
128-bit decimal floating point                    would like to support !
Min key
Max key
=============================== ================= ===========================

Marshal
=======

There is a submodule called ``marshal``, that allows for the easy conversion
of ``object`` types to/from BSON. It has a single macro: ``marshal`` which generates
the a ``toBson`` and ``pull`` procedure for the object.

An example:

.. code:: nim

    import bson
    import bson/marshal

    type
      User = object
        name: string
        height: Option[float]

    marshal(User)

    var u = User()

    var someBson = @@{"name": "Bob", "height": 95.3}

    u.pull(someBson)

    assert u.name == "Bob"

See the *bson/marshal Reference* link in the Table of Contents below for more detail.

Credit
======

Large portions of this code were pulled from the nimongo project, a scalable
pure-nim mongodb driver. See https://github.com/SSPkrolik/nimongo

However, this library is NOT compatilible with nimongo, as nimongo relies on an
internal implementation of BSON.



Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <https://github.com/JohnAD/bson/blob/master/docs/bson-ref.rst>`__
    B. `bson/marshal Reference <https://github.com/JohnAD/bson/blob/master/docs/bson-marshal-ref.rst>`__
