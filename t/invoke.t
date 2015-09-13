#!/usr/bin/env perl6

use v6;
use Inline::Python;
use Test;

my $py = Inline::Python.new();
$py.run(q:heredoc/PYTHON/);
    class Foo(object):
        @staticmethod
        def test(x):
            return x
    PYTHON

is($py.invoke('__main__', 'Foo', 'test', 1), 1);

done-testing;

# vim: ft=perl6
