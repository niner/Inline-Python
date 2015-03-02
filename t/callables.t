#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Python;

plan 3;

my $py = Inline::Python.new();

$py.run(q:heredoc/PYTHON/);
    import logging
    def call_something(something, param):
        return something(param)

    def return_code(name):
        return lambda param: "%s %s" % (name, param)
    PYTHON

sub something($suffix) {
    return 'Perl ' ~ $suffix;
}

is $py.call('__main__', 'call_something', &something, 6), 'Perl 6';
is $py.call('__main__', 'return_code', 'Perl')(5), 'Perl 5';
my $sub = $py.call('__main__', 'return_code', 'Foo');
is $py.call('__main__', 'call_something', $sub, 1), 'Foo 1';

# vim: ft=perl6
