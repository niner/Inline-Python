# TITLE

Inline::Python

[![Build Status](https://travis-ci.org/niner/Inline-Python.svg?branch=master)](https://travis-ci.org/niner/Inline-Python)

# SYNOPSIS

```
    use Inline::Python;
    my $py = Inline::Python.new();
    $py.run('print "hello world"');

    # Or
    say EVAL('1+3', :lang<Python>);
```

# DESCRIPTION

Module for executing Python code and accessing Python libraries from Perl 6.

# BUILDING

You will need a Python built with the -fPIC option (position independent
code). Most distributions build their Python that way. To do this with pyenv,
use something like:

```
    PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 2.7.12
    pyenv global 2.7.12
    pyenv rehash
```

With a python in your path, then build:


```
    perl6 configure.pl6
    make test
    make install
```

# AUTHOR

Stefan Seifert <nine@detonation.org>
