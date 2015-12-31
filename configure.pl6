#!/usr/bin/env perl6
use v6;
use LibraryMake;

sub get_config_var(Str $name) {
    return chomp(qqx/python -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('$name'));"/);
}

my %vars = get-vars('.');
%vars<INCLUDEPY> = get_config_var('INCLUDEPY');
my $library = get_config_var('LIBRARY');
$library ~~ s/\.a$//;
$library ~~ s/^lib//;
%vars<LIBRARYPY> = $library;
%vars<LIBPLPY> = get_config_var('LIBPL');
%vars<pyhelper> = $*VM.platform-library-name('pyhelper'.IO);
mkdir 'resources' unless 'resources'.IO.e;
mkdir 'resources/libraries' unless 'resources/libraries'.IO.e;
process-makefile('.', %vars);
shell(%vars<MAKE>);

# vim: ft=perl6
