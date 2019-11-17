import unittest

import os, strutils, sequtils, times, oids, md5, options

import bson
import bson/marshal

type
  MoneyDoc = object
    salary: float
  BigDoc = object
    name: string
    balance: float
    someId: Oid
    someTrue: bool
    someNull: Option[int]
    someInt: int
    subdoc: MoneyDoc
    someArray: seq[MoneyDoc]

suite "BSON Marshaling":
  test "pull":
    let readyOid = parseOid("5d6c66e4a0dc75753703ff48")
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
            @@{"salary": 3.1415},
            @@{"salary" : 99}
        ]
    }

    var bd = BigDoc()

    bd.pull(source)

    check bd.name == "John"
    check bd.balance == 1000.23
    check bd.someId == readyOid 
    check bd.someTrue == true
    check bd.someNull == none(int)
    check bd.someInt == 0   # the default as it is not actually in the BSON document
    check bd.subdoc.salary == 500.0
    check bd.someArray.len == 2
    check bd.someArray[0].salary == 3.1415
    check bd.someArray[1].salary == 0.0 # the 'int' in the BSON was rejected

    # TODO: add time checks


