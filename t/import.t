#!/usr/bin/env perl6

use v6;
use Inline::Python;
use Test;

use string:from<Python>;

my $py = Inline::Python.default_python;
is($py.call('string', 'capwords', 'foo bar'), 'Foo Bar');

done-testing;
