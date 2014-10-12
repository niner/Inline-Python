#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Python;

plan 3;

my $py = Inline::Python.new();
is $py.run('5', :eval), 5;
is $py.run('u"Python"', :eval), 'Python';
is $py.run('"Python"', :eval).decode('latin-1'), 'Python';

# vim: ft=perl6
