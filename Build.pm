use v6;
use Panda::Common;
use Panda::Builder;
use Shell::Command;
use LibraryMake;

class Build is Panda::Builder {
    sub get_config_var(Str $name) {
        return chomp(qqx/python -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('$name'));"/);
    }

    method build($dir) {
        mkdir "$dir/resources" unless "$dir/resources".IO.e;

        my %vars = get-vars($dir);
        %vars<INCLUDEPY> = get_config_var('INCLUDEPY');
        my $library = get_config_var('LIBRARY');
        $library ~~ s/\.a$//;
        $library ~~ s/^lib//;
        %vars<LIBRARYPY> = $library;
        %vars<LIBPLPY> = get_config_var('LIBPL');
        process-makefile($dir, %vars);

        my $goback = $*CWD;
        chdir($dir);
        shell(%vars<MAKE>);
        chdir($goback);
    }
}

# vim: ft=perl6
