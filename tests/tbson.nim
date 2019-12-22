import unittest

import times, oids, md5

import bson

let expected_bdoc = """{
  "image": {
    "$binary": {
      "base64": "MTIzMTJsM2prYWxrc2pzbGt2ZHNkYXM=",
      "subtype": "00"
    }
  },
  "balance": {"$numberDouble": "1000.23"},
  "name": "John",
  "someId": {"$oid": "5d6c66e4a0dc75753703ff48"},
  "someTrue": true,
  "surname": "Smith",
  "someNull": null,
  "minkey": {"$minKey" :1},
  "maxkey": {"$maxKey" :1},
  "digest": {
    "$binary": {
      "base64": "ZDQxZDhjZDk4ZjAwYjIwNGU5ODAwOTk4ZWNmODQyN2U=",
      "subtype": "05"
    }
  },
  "regexp-field": {"$regularExpression":
    {
      "pattern": "pattern",
      "options": "ismx"
    }
  },
  "undefined": {"$undefined": true},
  "someJS": {"$code":"function identity(x) {return x;}"},
  "someRef": {"$dbPointer":{"$ref":"db.col","$id":{"$oid":"48FF03377575DCA0E4666C5D"}}},
  "userDefined": {
    "$binary": {
      "base64": "c29tZS1iaW5hcnktZGF0YQ==",
      "subtype": "80"
    }
  },
  "someTimestamp": {"$timestamp": {"t": 1,"i": 1}},
  "utcTime": {"$date": {"$numberLong": "1567367316000"}},
  "subdoc": {
    "salary": {"$numberLong": "500"}
  },
  "array": [
    {
      "string": "hello"
    },
    {
      "string": "world"
    }
  ]
}"""

let expected_bdoc2 = """[
  {"$numberLong": "2"},
  {"$numberLong": "2"}
]"""

let expected_mdoc = """{
  "name": "Joe",
  "age": {"$numberLong": "42"},
  "siblings": [
    "Amy",
    "Jerry"
  ],
  "schedule": {
    "8am": "go to work",
    "11am": "see dentist"
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
    const merge_expected_out = """{
  "name": "Joe",
  "age": {"$numberLong": "42"},
  "weight": {"$numberLong": "52"},
  "feet": {"$numberLong": "2"}
}"""
    const pull_expected_out = """{
  "name": "Joe",
  "age": {"$numberLong": "42"},
  "weight": {"$numberLong": "52"}
}"""
    var a = @@{"name": "Joe", "age": 42, "weight": 50 }
    let b = @@{"name": "Joe", "feet": 2, "weight": 52 }
    let both = a.merge(b)
    
    check $both == merge_expected_out

    pull(a, b)

    check $a == pull_expected_out

    var aa = @@{"abc": 4, "xyz": {"foo": "bar", "zip": [10, 11, 12, 13]}}
    let bb = @@{"abc": 2, "xyz": {"foo": "tada", "j": "u"}}
    let cc = @@{"abc": "hello"}
    let dd = @@{"zip": [0.1, 0.2, 0.3]}

    aa.pull(bb)
    assert aa["abc"] == 2
    assert aa["xyz"]["foo"] == "tada"
    assert aa{"xyz", "j"}.isNull       # "j" is not set because it is not found in ``a``
    assert aa["xyz"]["zip"].len == 4   # "zip" is left alone

    aa.pull(cc)
    assert aa["abc"] == "hello"

    var sub = aa["xyz"]
    sub.pull(dd)
    aa["xzy"] = sub
    assert aa["xyz"]["foo"] == "tada"
    assert aa["xyz"]["zip"][0] == 0.1
    assert aa["xyz"]["zip"][1] == 0.2
    assert aa["xyz"]["zip"][2] == 0.3
    assert aa["xyz"]["zip"][3] == 13

  test "time to bson to time":
    let bdoc = @@{"d": parseTime("2019-09-01T19:48:36.123", "yyyy-MM-dd\'T\'HH:mm:ss'.'fff", utc())}
    check bdoc["d"].toTime.nanosecond == 123000000
    let bdoc2 = newBsonDocument(bdoc.bytes)
    check bdoc2["d"].toTime.nanosecond == 123000000

  test "test safe `{}` functions":

    let myDoc = @@{"abc": 4, "xyz": {"foo": "bar", "zip": [10, 11, 12, 13]}}
  
    check myDoc{"abc"} == 4
    check myDoc{"missing"}.kind == BsonKindNull
    check myDoc{"xyz", "foo"} == "bar"
    check myDoc{"xyz", "zip", "2"} == 12
    check myDoc{"xyz", "zip", "19"}.isNull

    myDoc{"abc"} = toBson(5)
    myDoc{"xyz", "foo"} = toBson("BAR2")
    myDoc{"def", "ghi"} = toBson(99.2)
    myDoc{"xyz", "zip", "2"} = toBson(112)

    check myDoc["abc"] == 5
    check myDoc["xyz"]["foo"] == "BAR2"
    check myDoc["def"]["ghi"] == 99.2
    check myDoc["xyz"]["zip"][2] == 112

    myDoc{"abc"} = 6
    myDoc{"xyz", "foo"} = "BAR3"
    myDoc{"def", "ghi"} = 199.9
    myDoc{"xyz", "zip", "2"} = true  # BSON arrays can mix types!

    check myDoc["abc"] == 6
    check myDoc["xyz"]["foo"] == "BAR3"
    check myDoc["def"]["ghi"] == 199.9
    check myDoc["xyz"]["zip"][2] == true

  test "iterators":

    let myDoc = @@{"abc": 4, "xyz": {"foo": "bar", "zip": [10, 11, 12, 13]}}

    var fldList: seq[string]
    for f in myDoc.fields():
      fldList.add f

    check fldList[0] == "abc"
    check fldList[1] == "xyz"

    var itemList: seq[Bson]
    for itm in myDoc.items():
      itemList.add itm

    check itemList[0] == 4
    check itemList[1].kind == BsonKindDocument

    fldList = @[]
    itemList = @[]
    for k, v in myDoc.pairs():
      fldList.add k
      itemList.add v

    check fldList[0] == "abc"
    check fldList[1] == "xyz"
    check itemList[0] == 4
    check itemList[1].kind == BsonKindDocument
    
    var sum = 0
    for x in myDoc["xyz"]["zip"].items():
      sum += x

    check sum == 10 + 11 + 12 + 13

    expect Exception:
      for k, v in myDoc["xyz"]["zip"].pairs():
        discard
