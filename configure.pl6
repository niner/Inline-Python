#!/usr/bin/env perl6
use v6;
use LibraryMake;

my %vars = get-vars('.');

%vars<pyhelper> = $*VM.platform-library-name('pyhelper'.IO);
%vars<cflags> = chomp qx/python2-config --cflags/;
%vars<ldflags> = chomp qx/python2-config --ldflags/;

mkdir 'resources' unless 'resources'.IO.e;
mkdir 'resources/libraries' unless 'resources/libraries'.IO.e;

process-makefile('.', %vars);
shell(%vars<MAKE>);

# vim: ft=perl6
