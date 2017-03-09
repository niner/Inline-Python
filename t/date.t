#!/usr/bin/env perl6

use v6;
use Inline::Python;

use Test;

plan 1;

my $py = Inline::Python.new;
$py.run: 'import datetime';
my $py_date = $py.call('datetime', 'date', 2017, 3, 1);

is $py_date.isoformat.decode, '2017-03-01';
