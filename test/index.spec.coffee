describe "double-latte", ->
    {multiple, isinstance, issubclass} = require "../index"
    expect = require "expect"


    global = ""

    class A
        constructor: -> global += "A"
        method: -> "A"
        @static: -> "A"

    class B extends A
        constructor: ->
            global += "B"
            super
        method: -> "B" + super
        @static: -> "B" + super

    class C extends A
        constructor: ->
            global += "C"
            super
        method: -> "C" + super
        @static: -> "C" + super

    class D extends multiple B, C
        constructor: ->
            global += "D"
            super
        method: -> "D" + super
        @static: -> "D" + super

    class Random

    describe "multiple", ->

        it "checks that the constructor call order is correct", ->
            d = new D
            expect(global).toBe "DBCA"

        it "checks that the method call order is correct", ->
            d = new D
            expect(d.method()).toBe "DBCA"

        it "checks that the static method call order is correct", ->
            expect(D.static()).toBe "DBCA"

    describe "isinstance", ->
        it "checks that isinstance correctly labels instances of classes with
            multiple parents", ->

            d = new D
            a = new A
            o = new Object
            r = new Random
            expect(isinstance d, D).toBe true
            expect(isinstance d, B).toBe true
            expect(isinstance d, C).toBe true
            expect(isinstance d, A).toBe true
            expect(isinstance d, Object).toBe true
            expect(isinstance a, Object).toBe true
            expect(isinstance o, A).toBe false
            expect(isinstance r, D).toBe false
            expect(isinstance r, A).toBe false

    describe "issubclass", ->
        it "checks that issubclass correctly labels classes with multiple
            parents", ->

            expect(issubclass D, D).toBe true
            expect(issubclass D, B).toBe true
            expect(issubclass D, C).toBe true
            expect(issubclass D, A).toBe true
            expect(issubclass D, Object).toBe true
            expect(issubclass A, Object).toBe true
            expect(issubclass Object, A).toBe false
            expect(issubclass Random, D).toBe false
            expect(issubclass Random, A).toBe false
