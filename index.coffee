merge = (lists) ->
    # Returns the result of merging `lists` in a C3-serialization sense
    # Will destroy 'lists' in the process
    # Throws an exception if no merging is possible
    if not lists or not lists.length
        return []

    candidates = []
    for list in lists
        if list[0] not in candidates
            candidates.push(list[0])

    for list in lists
        for item, tails in list
            if tails
                position = `indexOf`.call(candidates, item)
                if ~position
                    candidates.splice(position, 1)

    if not candidates.length
        throw new SyntaxError("Ambiguous class inheritance schema")

    result = []
    for candidate in candidates
        result.push(candidate)
        for list in lists
            if list[0] is candidate
                list.shift()

    result.concat(merge(list for list in lists when list.length > 0))


mro = (cls) ->
    # Caches and returns the mro of a class. This only handles single
    # inheritance cases, as multiple inheritance virtual classes always have
    # their mro saved upon construction.
    if `hasProp`.call(cls::, "__mro__")
        return cls::__mro__

    result = [cls]
    if `hasProp`.call(cls, "__super__")
        result = result.concat(mro(cls.__super__.constructor))

    cls::__mro__ = result


rebind = (from, to, fn) ->
    # Decorates fn so that it uses `to.__super__` instead of `from.__super__`
    # Returns fn unchanged if it is not a function
    if typeof fn isnt "function"
        fn
    else
        ->
            old = from.__super__
            from.__super__ = to.__super__
            try
                return fn.apply(@, arguments)
            finally
                from.__super__ = old


exports.multiple = ->
    # Returns a virtual class that behaves as if its arguments have been merged
    # into a single class, with regards to the C3 Linearization Algorithm.
    #
    # Note that properties (of the constructor or the prototype) are simply
    # copied into the
    if arguments.length < 2
        throw new SyntaxError("Expecting at least two arguments")

    bases = new Array(arguments.length)
    for k in [0..arguments.length-1]
        bases[k] = arguments[k]

    # merge destroys its input, so make copies of the mro (__mro__ prop)
    lists = (mro(base)[..] for base in bases)
    lists.push(bases)

    hierarchy = merge(lists)

    end = hierarchy.length - 1
    Parent = hierarchy[end]
    while --end >= 0
        Mixin = hierarchy[end]
        Parent = do (Mixin, Parent) ->
            class Child extends Parent
                constructor: ->
                    old = Mixin.__super__
                    Mixin.__super__ = Child.__super__
                    try
                        Mixin.apply @, arguments
                    finally
                        Mixin.__super__ = old

            # copy class properties
            for own prop of Mixin
                if prop isnt "__super__"
                    Child[prop] = rebind(Mixin, Child, Mixin[prop])

            # copy prototype properties
            for own prop of Mixin::
                if prop not in ["__mro__", "constructor"]
                    Child::[prop] = rebind(Mixin, Child, Mixin::[prop])

            Child

    Parent::.__mro__ = hierarchy
    Parent


exports.isinstance = (obj, targets) ->
    exports.issubclass(obj.constructor, targets)


exports.issubclass = (cls, targets) ->
    hierarchy = mro(cls)
    if targets instanceof Array
        for target in targets
            if target in hierarchy or target is Object
                return true
        false
    else
        targets in hierarchy or targets is Object
