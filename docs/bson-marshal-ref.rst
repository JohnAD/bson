bson/marshal Reference
==============================================================================

The following are the references for bson/marshal.








Macros and Templates
====================


.. _marshal.m:
marshal
---------------------------------------------------------

    .. code:: nim

        macro marshal*(obj: typed, recurse=true): untyped =

    source line: `7 <../src/bson/marshal.nim#L7>`__

    This macro creates one or more pairs of procedures to easily for the object
    type passed.
    
    The pairs of new procedures are:
    
    *  ``pull(v: var T, doc: Bson) =``  *which converts Bson to Object*
    *  ``toBson(v: T): Bson =``  *which converts Object to Bson*
    
    Where T is the object (or object referenced by the object.)
    
    .. code:: nim
    
        type
          Pet = object
            shortName: string
          User = object
            displayName: string
            weight: Option[float]
            thePet: Pet
    
        marshal(User)
    
        # Now, the following procedures exist:
        #   pull(v: User, doc: Bson)
        #   pull(v: Pet, doc: Bson)
        #   toBson(v: User): Bson
        #   toBson(v: Pet): Bson
    
        var u = User()
    
        var b = @@{"displayName": "Bob", "weight": 95.3, "thePet": {"shortName": "Whiskers"}}
    
        u.pull(b)
    
        assert u.thePet.shortName == "Whiskers"
    
    By design, the procedures created are very forgiving. If field names or
    types don't match, in either the object or the BSON document, they are
    simply ignored.





Table Of Contents
=================

1. `Introduction to bson <https://github.com/JohnAD/bson>`__
2. Appendices

    A. `bson Reference <bson-ref.rst>`__
    B. `bson/marshal Reference <bson-marshal-ref.rst>`__
    C. `bson/generators Reference <bson-generators-ref.rst>`__
