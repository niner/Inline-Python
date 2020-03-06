#!/usr/bin/env perl6

use v6;
use Inline::Python;

use Test;

plan 3;

my $py = Inline::Python.new;
$py.run: 'import datetime';
my $py_date = $py.call('datetime', 'date', 2017, 3, 1);

ok defined($py_date), 'date object is unmarshalled from Python';
is $py_date.isoformat, '2017-03-01', 'can marshall datetime.date object';

my $py_datetime = $py.call('datetime', 'datetime', 2017, 3, 1, 10, 7, 5);

is $py_datetime.isoformat, '2017-03-01T10:07:05', 'datetime.datetime';
