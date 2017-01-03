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
        def __init__(self, a, b):
            self.a = a
            self.b = b
        def concat(self, c):
            return self.a + c + self.b
    PYTHON

is($py.invoke('__main__', 'Foo', 'test', 1), 1);
is($py.invoke('__main__', 'Foo', 'test', x => 1), 1);
my $foo = $py.call('__main__', 'Foo', a => 'aa', b => 'bb');
is($foo.concat(c => '~'), 'aa~bb');

done-testing;

# vim: ft=perl6
