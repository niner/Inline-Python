use v6;
use Panda::Common;
use Panda::Builder;
use Shell::Command;
use LibraryMake;

class Build is Panda::Builder {
    method build($dir) {
      my %vars = get-vars('.');

      %vars<pyhelper> = $*VM.platform-library-name('pyhelper'.IO);
      %vars<cflags> = chomp qx/python-config --cflags/;
      %vars<ldflags> = chomp qx/python-config --ldflags/;

      mkdir 'resources' unless 'resources'.IO.e;
      mkdir 'resources/libraries' unless 'resources/libraries'.IO.e;

      process-makefile('.', %vars);
      shell(%vars<MAKE>);
    }
}

# vim: ft=perl6
