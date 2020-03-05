#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Python;

plan 2;

subtest {
    my $py = Inline::Python.new();
    is $py.run('5', :eval), 5;
    is $py.run('"Python"', :eval), 'Python';
}, "Direct run values";

subtest {
    is EVAL('5', :lang<Python>), 5;
    is EVAL('"Python"', :lang<Python>), 'Python';
}, "EVAL returns values";

# vim: ft=perl6
