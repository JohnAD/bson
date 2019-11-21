import unittest

import times, oids, md5

import bson

let expected_bdoc = """{
    "image" : {"$bindata": "MTIzMTJsM2prYWxrc2pzbGt2ZHNkYXM="},
    "balance" : 1000.23,
    "name" : "John",
    "someId" : {"$oid": "5d6c66e4a0dc75753703ff48"},
    "someTrue" : true,
    "surname" : "Smith",
    "someNull" : null,
    "minkey" : {"$$minkey": 1},
    "maxkey" : {"$$maxkey": 1},
    "digest" : {"$md5": "d41d8cd98f00b204e9800998ecf8427e"},
    "regexp-field" : {"$regex": "pattern", "$options": "ismx"},
    "undefined" : undefined,
    "someJS" : function identity(x) {return x;},
    "someRef" : {"$ref": "col", "$id": "5d6c66e4a0dc75753703ff48", "$db": "db"},
    "userDefined" : {"$bindata": "c29tZS1iaW5hcnktZGF0YQ=="},
    "someTimestamp" : {"$timestamp": 4294967297},
    "utcTime" : 2019-09-01T14:48:36-05:00,
    "subdoc" : {
        "salary" : 500
    },
    "array" : [
        {
            "string" : "hello"
        },
        {
            "string" : "world"
        }
    ]
}"""

let expected_bdoc2 = """[
    2,
    2
]"""

let expected_mdoc = """{
    "name" : "Joe",
    "age" : 42,
    "siblings" : [
        "Amy",
        "Jerry"
    ],
    "schedule" : {
        "8am" : "go to work",
        "11am" : "see dentist"
    }
}"""

suite "Basic BSON":
  test "nim-to-bson-to-binary and back":
    let oid = parseOid("5d6c66e4a0dc75753703ff48")
    let bdoc: Bson = @@{
        "image": bin("12312l3jkalksjslkvdsdas"),
        "balance": 1000.23,
        "name": "John",
        "someId": oid,
        "someTrue": true,
        "surname": "Smith",
        "someNull": null(),
        "minkey": minkey(),
        "maxkey": maxkey(),
        "digest": "".toMd5(),
        "regexp-field": regex("pattern", "ismx"),
        "undefined": undefined(),
        "someJS": js("function identity(x) {return x;}"),
        "someRef": dbref("db.col", oid),
        "userDefined": binuser("some-binary-data"),
        "someTimestamp": BsonTimestamp(increment: 1, timestamp: 1),
        "utcTime": parseTime("2019-09-01T19:48:36", "yyyy-MM-dd\'T\'HH:mm:ss", utc()),
        "subdoc": @@{
            "salary": 500
        },
        "array": [
            @@{"string": "hello"},
            @@{"string" : "world"}
        ]
    }

    check $bdoc == expected_bdoc

    let bbytes = bdoc.bytes()
    let recovered = newBsonDocument(bbytes)

    check $recovered == expected_bdoc

    var bdoc2 = newBsonArray()
    bdoc2 = bdoc2.add(2)
    bdoc2 = bdoc2.add(2)
    
    check $bdoc2 == expected_bdoc2
  test "building bson manually":
    var mdoc = newBsonDocument()
    mdoc["name"] = "Joe"
    mdoc["age"] = 42
    mdoc["siblings"] = newBsonArray()
    mdoc["siblings"].add "Amy"
    mdoc["siblings"].add "Jerry"
    mdoc["schedule"] = newBsonDocument()
    mdoc["schedule"]["8am"] = "go to work"
    mdoc["schedule"]["11am"] = "see dentist"

    check mdoc == expected_mdoc

  test "merge and update":
    const expected_out = """{
    "name" : "Joe",
    "age" : 42,
    "weight" : 52,
    "feet" : 2
}"""
    let a = @@{"name": "Joe", "age": 42, "weight": 50 }
    let b = @@{"name": "Joe", "feet": 2, "weight": 52 }
    let both = a.merge(b)
    
    check $both == expected_out

    update(a, b)

    check $a == expected_out
