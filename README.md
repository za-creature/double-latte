# Double Latte

Python-like [MRO based](http://en.wikipedia.org/wiki/C3_linearization) multiple inheritance for CoffeeScript.

Works with all browsers supported by CoffeeScript.

## Example

```coffeescript

{multiple, isinstance, issubclass} = require("double-latte")

class A
    constructor: ->
        console.log("A")


class B extends A
    constructor: ->
        console.log("B")
        super


class C extends A
    constructor: ->
        console.log("C")
        super


class D extends multiple B, C
    constructor: ->
        console.log("D")
        super


d = new D  # will print D; B; C; A;
isinstance d, B  # true

```

## Install

```bash
npm install double-latte
```

## FAQ

Q: Can I use this with &lt;insert favorite compile-to-javascript language here&gt; *

A: Probably not. This relies on the *cls.__super__* property that CoffeeScript uses to figure out what parent to call. If your compiler does that, then **maybe**.

Q: How fast is this?

A: Fast enough ( [Guido for president!](http://www.infoworld.com/article/2619428/python/van-rossum--python-is-not-too-slow.html) ). If you're *that* worried about performance then you should probably code in javascript directly.

Q: What's the deal with `isinstance`?

A: For technical reasons, the `instanceof` operator doesn't work with classes that have multiple parents. The `isinstance` and `issubclass` are provided to work around this fact.
