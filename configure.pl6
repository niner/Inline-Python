#!/usr/bin/env perl6
use v6;
use LibraryMake;

my %vars = get-vars('.');

my $python-config = 'python3-config';

%vars<pyhelper> = 'resources'.IO.child('libraries').child($*VM.platform-library-name('pyhelper'.IO)).Str;
%vars<cflags> = chomp qqx/$python-config --cflags/;
%vars<ldflags> = chomp qqx/$python-config --ldflags/;

mkdir 'resources' unless 'resources'.IO.e;
mkdir 'resources/libraries' unless 'resources/libraries'.IO.e;

process-makefile('.', %vars);
shell(%vars<MAKE>);

# vim: ft=perl6
