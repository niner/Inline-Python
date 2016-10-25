#!/usr/bin/env perl6

use v6;
use Inline::Python;

say '1..2';

EVAL 'print "ok 1 - EVAL eval"', :lang<Python>, :mode<file>;

my $py = Inline::Python.new();
$py.run('print "ok 2 - direct eval"', :file);

# vim: ft=perl6
