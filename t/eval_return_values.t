#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Python;

plan 1;

my $py = Inline::Python.new();
is $py.run('5', :eval), 5;

# vim: ft=perl6
