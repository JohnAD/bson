Introduction to bson
==============================================================================
ver 0.1.0

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

For legacy reasons, you can also use the `%*` to do the same thing. However,
because JSON uses `*%`, this can make for confusing-to-read code if you
end up mixing JSON and BSON in the same code.

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

    var binString: string = doc.bytes()

Please keep in mind that this is a **binary** string and is not printable.

To convert a binary blob of data back into a Bson library document, pass
the string into 'newBsonDocument' as a string parameter.

.. code:: nim

    var newDoc = newBsonDocument(binString)


HANDLING TYPES
--------------

The BSON specification calls for 18 types of data (and a few subtypes).

Not all of them are fully supported by the libary yet.

+--------------------------------+-----------------+---------------------------+
| BSON                           | Nim Equiv       | Notes                     |
+================================+=================+===========================+
| 64-bit binary floating point   | float           | Nim defaults to 64 bit    |
+--------------------------------+-----------------+---------------------------+
| UTF-8 string                   | string          |                           |
+--------------------------------+-----------------+---------------------------+
| Embedded document              | newBsonDocument | from this library. for    |
|                                |                 | key/value pairs, the key  |
|                                |                 | must always be a string   |
+--------------------------------+-----------------+---------------------------+
| Array                          | newBsonArray    | actually a list, not an   |
|                                |                 | array. You can mix types. |
+--------------------------------+-----------------+---------------------------+
| Binary data                    | string (binary) | not printable, but works  |
+--------------------------------+-----------------+---------------------------+
| ObjectId                       | Oid             | std "oids" library        |
+--------------------------------+-----------------+---------------------------+
| Boolean "false"                | bool = false    |                           |
+--------------------------------+-----------------+---------------------------+
| Boolean "true"                 | bool = true     |                           |
+--------------------------------+-----------------+---------------------------+
| UTC datetime                   | Time            | std "times" library       |
+--------------------------------+-----------------+---------------------------+
| Null value                     | null            | from this library         |
+--------------------------------+-----------------+---------------------------+
| Regular expression             | regex()         | from this library         |
+--------------------------------+-----------------+---------------------------+
| DBPointer (deprecated)         | dbref()         | from this library         |
+--------------------------------+-----------------+---------------------------+
| JavaScript code                | js()            | from this library         |
+--------------------------------+-----------------+---------------------------+
| JavaScript code w/ scope       |                 |                           |
+--------------------------------+-----------------+---------------------------+
| 32-bit integer                 | int32           |                           |
+--------------------------------+-----------------+---------------------------+
| Timestamp                      | BsonTimestamp   | from this library         |
+--------------------------------+-----------------+---------------------------+
| 64-bit integer                 | int64           |                           |
+--------------------------------+-----------------+---------------------------+
| 128-bit decimal floating point |                 | would like to support !   |
+--------------------------------+-----------------+---------------------------+
| Min key                        |                 |                           |
+--------------------------------+-----------------+---------------------------+
| Max key                        |                 |                           |
+--------------------------------+-----------------+---------------------------+




Table Of Contents
=================

1. `Introduction to bson <index.rst>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
