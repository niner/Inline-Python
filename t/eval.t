#!/usr/bin/env perl6

use v6;
use Inline::Python;

say '1..1';

my $py = Inline::Python.new();

$py.run('
print "ok 1 - basic eval\n";
');

# vim: ft=perl6
