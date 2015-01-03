#!/usr/bin/env perl6

use v6;
use Inline::Python;
use Test;
use NativeCall;

plan 8;

my $py = Inline::Python.new();

$py.run(q:heredoc/PYTHON/);
    class PyFoo:
        def __init__(self, foo=u"Python default"):
            self._foo = foo

        def test(self):
            return self.bar()

        def foo(self):
            return self._foo

        def bar(self):
            return u"Python"

        def test_inherited(self):
            return self.baz()

        def baz(self):
            return u"Python"

    class PyBar:
        def test(self):
            return self.qux
    PYTHON

class Bar does Inline::Python::PythonParent['__main__', 'PyFoo'] {
    method bar() {
        return "Perl6";
    }
}

is(Bar.new().test, 'Perl6');
is(Bar.new().test_inherited, 'Python');
is(Bar.new().foo, 'Python default');

class Baz does Inline::Python::PythonParent['__main__', 'PyFoo'] {
    method bar() {
        return "Perl6!";
    }

}

is(Baz.new().test, 'Perl6!');

class Qux does Inline::Python::PythonParent['__main__', 'PyBar'] {
    method qux() {
        return "Perl6!!";
    }

}

is((Qux.new().test)(), 'Perl6!!');

# Test passing a Py object to the constructor of a P6 subclass

class Perl6ObjectCreator {
    method create($package, $parent) {
        ::($package).WHAT.new(parent => $parent);
    }
}

$py.run(q:heredoc/PYTHON/);
    def init_perl6_object_creator(creator):
        global perl6_object_creator
        perl6_object_creator = creator
    PYTHON

$py.call('__main__', 'init_perl6_object_creator', Perl6ObjectCreator.new);

$py.run(q:heredoc/PYTHON/);
    foo = Bar(None, u"injected")
    bar = perl6_object_creator.create(u"Bar", foo)
    PYTHON
my $bar = $py.run('bar', :eval)[0];
is($bar.foo, 'injected');
is($bar.test, 'Perl6');
is($bar.test_inherited, 'Python');

# vim: ft=perl6
