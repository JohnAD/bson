bson/marshal Reference
==============================================================================

The following are the references for bson/marshal.








Macros and Templates
====================


.. _pull.m:
pull
---------------------------------------------------------

    .. code:: nim

        macro pull*(varobj: typed, bd: Bson): untyped =

    source line: `43 <../src/bson/marshal.nim#L43>`__

    This macro "pulls" the values from the BSON document and copies them
    to the corresponding fields of the object, including any subtending objects.
    
    By design, this macro is very forgiving. If field names or types don't match,
    in either the object or the BSON document, they are simply ignored.
    
    Example of use:
    
    .. code:: nim
    
        type
          Pet = object
            shortName: string
          User = object
            displayName: string
            weight: Option[float]
            thePet: Pet
    
        var u = User()
    
        var b = @@{"displayName": "Bob", "weight": 95.3, "thePet": {"shortName": "Whiskers"}}
    
        pull(u, b)
    
        assert u.thePet.shortName == "Whiskers"
    
    **SIDE** **EFFECT**: as a secondary side effect of running this macro, a
    pair of new functions called
      ``applyBson(v: T, doc: Bson) =``
    and
      ``toBson(v: T): Bson =``
    with the specific object type of the variable are created the first time
    this macro (or the ``toBson`` macro) is invoked.
    
    Calling this or the other macro multiple times does not cause a problem.
    
    You can, for the remainder of the local source code file, also call
    those functions directly.


.. _toBson.m:
toBson
---------------------------------------------------------

    .. code:: nim

        macro toBson*(varobj: object): Bson =

    source line: `95 <../src/bson/marshal.nim#L95>`__

    This macro creates a new BSON document that has the corresonding fields
    and values.
    
    By design, this process is very forgiving. If a nim field type is encountered that
    does not have a known conversion to BSON, it is simply skipped.
    
    Example of use:
    
    .. code:: nim
    
        type
          Pet = object
            shortName: string
          User = object
            displayName: string
            weight: Option[float]
            thePet: Pet
    
        var a = Pet()
        a.shortName = "Bowser"
    
        var u = User()
        u.displayName = "Joe"
        u.weight = some(45.3)
        u.thePet = a
    
        var newBDoc = u.toBson()
    
        assert newBDoc["thePet"]["shortName"] == "Bowser"
    
    **SIDE** **EFFECT**: as a secondary side effect of running this macro, a
    pair of new functions called
      ``applyBson(v: T, doc: Bson) =``
    and
      ``toBson(v: T): Bson =``
    with the specific object type of the variable are created the first time
    this macro (or the ``pull`` macro) is invoked.
    
    Calling this or the other macro multiple times does not cause a problem.
    
    You can, for the remainder of the local source code file, also call
    those functions directly.





Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
    B. `bson/marshal Reference <bson-marshal-ref.rst>`__
    C. `bson/generators General Documentation <bson-generators-gen.rst>`__
    D. `bson/generators Reference <bson-generators-ref.rst>`__
