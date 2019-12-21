import unittest

import times, oids, options

import bson
import bson/marshal

let readyOid = parseOid("5d6c66e4a0dc75753703ff48")

suite "JSON Conversion":
  test "pretty JSON & stringify":
    let doc = @@{
        "name": "abc",
        "balance": 1000.23,
        "someId": readyOid,
        "someTrue": true,
        "someNull": null(),
        "binthing": bin("kung foo"),
        "subdoc": @@{
            "salary": 500.0,
            "zed": "Hello"
        },
        "strArray": ["hello", "world"],
        "objArray": [
            @@{"shinyLevel": 3.1415},
            @@{"shinyLevel": 99},
            @@{"shinyLevel": 0.0, "crazy": [14]}
        ],
        "possibleGrad": null(),
        "today": parseTime("2019-09-01T19:48:36", "yyyy-MM-dd\'T\'HH:mm:ss", utc()),
        "olderdate": parseTime("1019-09-01T19:48:36", "yyyy-MM-dd\'T\'HH:mm:ss", utc()),
        "small": minkey(),
        "big": maxkey(),
        "search": regex("/*/*/", "gims")
    }

    check doc.pretty == """{
    "name": "abc",
    "balance": 1000.23,
    "someId": {"$oid": "5d6c66e4a0dc75753703ff48"},
    "someTrue": true,
    "someNull": null,
    "binthing": {
        "$binary": {
            "base64": "a3VuZyBmb28=",
            "subtype": "00"
        }
    },
    "subdoc": {
        "salary": 500.0,
        "zed": "Hello"
    },
    "strArray": [
        "hello",
        "world"
    ],
    "objArray": [
        {
            "shinyLevel": 3.1415
        },
        {
            "shinyLevel": 99
        },
        {
            "shinyLevel": 0.0,
            "crazy": [
                14
            ]
        }
    ],
    "possibleGrad": null,
    "today": {"$date": "2019-09-01T19:48:36Z"},
    "olderdate": {"$date": {$numberLong: "-29989627884000"}},
    "small": {"$minKey" :1},
    "big": {"$maxKey" :1},
    "search": {"$regularExpression":
        {
            "pattern": "/*/*/",
            "options": "gims"
        }
    }
}"""

    check doc.pretty(tab=2, canonical=true) == """{
  "name": "abc",
  "balance": {"$numberDouble": "1000.23"},
  "someId": {"$oid": "5d6c66e4a0dc75753703ff48"},
  "someTrue": true,
  "someNull": null,
  "binthing": {
    "$binary": {
      "base64": "a3VuZyBmb28=",
      "subtype": "00"
    }
  },
  "subdoc": {
    "salary": {"$numberDouble": "500.0"},
    "zed": "Hello"
  },
  "strArray": [
    "hello",
    "world"
  ],
  "objArray": [
    {
      "shinyLevel": {"$numberDouble": "3.1415"}
    },
    {
      "shinyLevel": {"$numberLong": "99"}
    },
    {
      "shinyLevel": {"$numberDouble": "0.0"},
      "crazy": [
        {"$numberLong": "14"}
      ]
    }
  ],
  "possibleGrad": null,
  "today": {"$date": {"$numberLong": "1567367316000"}},
  "olderdate": {"$date": {"$numberLong": "-29989627884000"}},
  "small": {"$minKey" :1},
  "big": {"$maxKey" :1},
  "search": {"$regularExpression":
    {
      "pattern": "/*/*/",
      "options": "gims"
    }
  }
}"""

    check $doc == """{
  "name": "abc",
  "balance": {"$numberDouble": "1000.23"},
  "someId": {"$oid": "5d6c66e4a0dc75753703ff48"},
  "someTrue": true,
  "someNull": null,
  "binthing": {
    "$binary": {
      "base64": "a3VuZyBmb28=",
      "subtype": "00"
    }
  },
  "subdoc": {
    "salary": {"$numberDouble": "500.0"},
    "zed": "Hello"
  },
  "strArray": [
    "hello",
    "world"
  ],
  "objArray": [
    {
      "shinyLevel": {"$numberDouble": "3.1415"}
    },
    {
      "shinyLevel": {"$numberLong": "99"}
    },
    {
      "shinyLevel": {"$numberDouble": "0.0"},
      "crazy": [
        {"$numberLong": "14"}
      ]
    }
  ],
  "possibleGrad": null,
  "today": {"$date": {"$numberLong": "1567367316000"}},
  "olderdate": {"$date": {"$numberLong": "-29989627884000"}},
  "small": {"$minKey" :1},
  "big": {"$maxKey" :1},
  "search": {"$regularExpression":
    {
      "pattern": "/*/*/",
      "options": "gims"
    }
  }
}"""
