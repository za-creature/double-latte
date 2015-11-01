require("chai").should()


{multiple, isinstance, issubclass} = require "../index"


global = ""


class A
    prop: "A"
    @prop: "A"
    constructor: ->
        global += "A"
    method: -> "A"
    @method: -> "A"


class B extends A
    prop: "B"
    @prop: "B"
    constructor: ->
        global += "B"
        super()
    method: -> "B" + super()
    @method: -> "B" + super()


class C extends A
    prop: "C"
    @prop: "C"
    constructor: ->
        global += "C"
        super()
    method: -> "C" + super()
    @method: -> "C" + super()


class D extends multiple B, C
    prop: "D"
    @prop: "D"
    constructor: ->
        global += "D"
        super()
    method: -> "D" + super()
    @method: -> "D" + super()


class Random


describe "multiple", ->
    it "calls super() in the correct order for constructors", ->
        d = new D()
        global.should.equal("DBCA")

    it "calls super() in the correct order for methods", ->
        d = new D()
        d.method().should.equal("DBCA")

    it "calls super() in the correct order for static methods", ->
        D.method().should.equal("DBCA")

    it "inherits properties in the correct order", ->
        new D().prop.should.equal("D")
        new C().prop.should.equal("C")
        new B().prop.should.equal("B")
        new A().prop.should.equal("A")

        D.prop.should.equal("D")
        C.prop.should.equal("C")
        B.prop.should.equal("B")
        A.prop.should.equal("A")

    it "inherits properties without calling the constructor", ->
        class BaseA
            prop: "A"
            propA: "A"

        class BaseB
            prop: "B"
            propB: "B"

        class Derived extends multiple BaseA, BaseB
            constructor: ->
                undefined

        d = new Derived()
        d.prop.should.equal("A")
        d.propA.should.equal("A")
        d.propB.should.equal("B")


describe "isinstance", ->
    it "should correctly label instances of classes with multiple parents", ->
        d = new D()
        a = new A()
        o = new Object()
        r = new Random()
        isinstance(d, D).should.be.true
        isinstance(d, B).should.be.true
        isinstance(d, C).should.be.true
        isinstance(d, A).should.be.true
        isinstance(d, Object).should.be.true
        isinstance(a, Object).should.be.true
        isinstance(o, A).should.be.false
        isinstance(r, D).should.be.false
        isinstance(r, A).should.be.false


describe "issubclass", ->
    it "should correctly label classes with multiple parents", ->
        issubclass(D, D).should.be.true
        issubclass(D, B).should.be.true
        issubclass(D, C).should.be.true
        issubclass(D, A).should.be.true
        issubclass(D, Object).should.be.true
        issubclass(A, Object).should.be.true
        issubclass(Object, A).should.be.false
        issubclass(Random, D).should.be.false
        issubclass(Random, A).should.be.false
