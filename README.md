# TITLE

Inline::Python

# SYNOPSIS

```
    use Inline::Python;
    my $py = Inline::Python.new();
    $py.run('print "hello world"');
```

# DESCRIPTION

Module for executing Python code and accessing Python libraries from Perl 6.

# BUILDING

You will need a Python built with the -fPIC option (position independent
code). Most distributions build their Python that way.

```
    perl6 configure.pl6
    make test
    make install
```

# AUTHOR

Stefan Seifert <nine@detonation.org>
