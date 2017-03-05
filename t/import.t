#!/usr/bin/env perl6

use v6;
use Inline::Python;
use Test;

use string:from<Python>;

my $py = Inline::Python.default_python;
is(string::capwords('foo bar'), 'Foo Bar');

#use sys:from<Python>;
#BEGIN sys::path::append('t/pylib');

use named:from<Python>;
is named::test_named(a => 1, b => 2), 3;
is named::test_kwargs(a => 1, b => 2), 2;

done-testing;
