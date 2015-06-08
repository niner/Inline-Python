#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Python;

plan 12;

my $py = Inline::Python.new();
$py.run(q[
def identity(a):
    return a
]);

class Foo {
}

for ('abcö', Buf.new('äbc'.encode('latin-1')), 24, 2.4.Num, [1, 2], { a => 1, b => 2}, Any, Foo.new) -> $obj {
    is-deeply $py.call('__main__', 'identity', $obj), $obj, "Can round-trip " ~ $obj.^name;
}

$py.run(q/
# coding=utf-8
def check_utf8(str):
    return str == u'Töst'
/);

ok($py.call('__main__', 'check_utf8', 'Töst'), 'UTF-8 string recognized in Python');

$py.run(q/
# coding=utf-8
def check_latin1(str):
    return str.decode('latin-1') == u'Töst';
/);

ok($py.call('__main__', 'check_latin1', 'Töst'.encode('latin-1')), 'latin-1 works in Python');

$py.run(q/
def is_two_point_five(a):
    return a == 2.5;
/);

ok($py.call('__main__', 'is_two_point_five', 2.5));
ok($py.call('__main__', 'is_two_point_five', Num.new(2.5)));

# vim: ft=perl6
