import unittest

import times, oids, options

import bson
import bson/marshal

type
  BlingDoc = object
    shinyLevel: float
    crazy: Option[seq[Option[int]]]  # an optional seq of optional ints

  MoneyDoc = object
    salary: float
  
  GradCeremony = object
    year: int
  
  BigDoc = object
    name: string
    balance: float
    someId: Oid
    someTrue: bool
    someNull: Option[int]
    someInt: int
    subdoc: MoneyDoc
    someArray: seq[BlingDoc]
    possibleGrad: Option[GradCeremony]
    today: Time

  ExtraDoc = object
    anotherField: MoneyDoc

let readyOid = parseOid("5d6c66e4a0dc75753703ff48")

suite "BSON Marshaling":
  test "pull":
    let source: Bson = @@{
        "balance": 1000.23,
        "name": "John",
        "someId": readyOid,
        "someTrue": true,
        "someNull": null(),
        "subdoc": @@{
            "salary": 500.0
        },
        "someArray": [
            @@{"shinyLevel": 3.1415},
            @@{"shinyLevel": 99},
            @@{"shinyLevel": 0.0, "crazy": [14]}
        ],
        "possibleGrad": null(),
        "today": parseTime("2019-09-01T19:48:36", "yyyy-MM-dd\'T\'HH:mm:ss", utc())
    }

    marshal(BigDoc)

    var bd = BigDoc()

    bd.pull(source)

    check bd.name == "John"
    check bd.balance == 1000.23
    check bd.someId == readyOid 
    check bd.someTrue == true
    check bd.someNull == none(int)
    check bd.someInt == 0   # the default: field is not actually in the BSON document
    check bd.subdoc.salary == 500.0
    check bd.someArray.len == 3
    check bd.someArray[0].shinyLevel == 3.1415
    check bd.someArray[1].shinyLevel == 0.0 # the default: the 'int' in the BSON was rejected (not a float)
    let optionalArr = bd.someArray[2].crazy.get
    check optionalArr.len == 1
    check optionalArr[0] == some(14)
    check bd.possibleGrad.isNone
    check $(bd.today.inZone(utc())) == "2019-09-01T19:48:36Z"

  test "toBson macro":

    marshal(BigDoc)

    var bd = BigDoc()
    bd.name = "abc"
    bd.balance = 99.9
    bd.someId = readyOid
    bd.someTrue = false
    bd.someNull = none(int)
    bd.someInt = 33
    bd.subdoc.salary = 99999.3
    bd.somearray = @[BlingDoc(shinyLevel: 84.12)]   
    bd.possibleGrad = none(GradCeremony)
    bd.today = parseTime("2019-09-01T19:48:36", "yyyy-MM-dd\'T\'HH:mm:ss", utc())
    
    let newDoc = bd.toBson

    check $newDoc == """{
    "name" : "abc",
    "balance" : 99.90000000000001,
    "someId" : {"$oid": "5d6c66e4a0dc75753703ff48"},
    "someTrue" : false,
    "someNull" : null,
    "someInt" : 33,
    "subdoc" : {
        "salary" : 99999.3
    },
    "someArray" : [
        {
            "shinyLevel" : 84.12,
            "crazy" : null
        }
    ],
    "possibleGrad" : null,
    "today" : 2019-09-01T14:48:36-05:00
}"""

  test "macro recursion limiting":

    marshal(BigDoc)
    marshal(ExtraDoc, recurse=false)
