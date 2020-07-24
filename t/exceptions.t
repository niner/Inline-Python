#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Python;

my $py = Inline::Python.new();
{
    try $py.run(q:heredoc/PYTHON/);
        raise Exception("foo")
        PYTHON
    ok 1, 'survived Python exception';
    ok $!.isa('X::AdHoc'), 'got an exception';
    ok $!.Str() ~~ m/foo/, 'exception message found';
}
{
    $py.run(q:heredoc/PYTHON/);
        def perish():
            raise Exception("foo")
        PYTHON
    try $py.call('__main__', 'perish');
    ok 1, 'survived Python exception in function call';
    ok $!.isa('X::AdHoc'), 'got an exception from function call';
    ok $!.Str() ~~ m/foo/, 'exception message found from function call';
}
{
    $py.run(q:heredoc/PYTHON/);
        class Foo:
            def depart(self):
                raise Exception("foo")
        PYTHON
    my $foo = $py.call('__main__', 'Foo');
    $foo.depart;
    CATCH {
        ok 1, 'survived Python exception in method call';
        when X::AdHoc {
            ok $_.isa('X::AdHoc'), 'got an exception from method call';
            ok $_.Str() ~~ m/foo/, 'exception message found from method call';
        }
    }
}
{
    $py.call('__main__', 'non_existing');
    CATCH {
        ok 1, 'survived calling missing Python function';
        when X::AdHoc {
            ok $_.isa('X::AdHoc'), 'got an exception for calling a missing function';
            is $_.Str(), "name 'non_existing' is not defined", 'exception message found for missing function';
        }
    }
}
{
    $py.run(q:heredoc/PYTHON/);
        class Foo:
            pass
        PYTHON
    my $foo = $py.call('__main__', 'Foo');
    $foo.non_existing;
    CATCH {
        ok 1, 'survived Python missing method';
        when X::AdHoc {
            ok $_.isa('X::AdHoc'), 'got an exception for calling missing method';
            is $_.Str(), "instance has no attribute 'non_existing'", 'exception message found for calling missing method';
        }
    }
}


class Foo {
    method depart {
        die "foo";
    }
}

$py.run(q:heredoc/PYTHON/);
    import logging
    def test_foo(foo):
        try:
            foo.depart()
        except Exception as e:
            return str(e)
    PYTHON

is $py.call('__main__', 'test_foo', Foo.new), 'foo';

{
    $py.run(q:heredoc/PYTHON/);
        def pass_through(foo):
            foo.depart()
        PYTHON
    $py.call('__main__', 'pass_through', Foo.new);
    CATCH {
        ok 1, 'P6 exception made it through Python code';
        when X::AdHoc {
            ok $_.isa('X::AdHoc'), 'got an exception from method call';
            ok $_.Str() ~~ m/foo/, 'exception message found from method call';
        }
    }
}

done-testing;

# vim: ft=perl6
