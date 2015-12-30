#!/usr/bin/env perl6

use v6;
use Inline::Python;

say '1..2';

EVAL 'print "ok 1 - EVAL eval\n"', :from<Python>;

my $py = Inline::Python.new();

$py.run('
print "ok 2 - direct eval\n";
', :file);

# vim: ft=perl6
