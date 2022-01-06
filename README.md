# TITLE

Inline::Python

[![Build Status](https://travis-ci.org/niner/Inline-Python.svg?branch=master)](https://travis-ci.org/niner/Inline-Python)

# SYNOPSIS

```
    use Inline::Python;
    my $py = Inline::Python.new();
    $py.run('print("hello world")');

    # Or
    say EVAL('1+3', :lang<Python>);

    use string:from<Python>;
    say string::capwords('foo bar'); # prints "Foo Bar"
```

# DESCRIPTION

Module for executing Python code and accessing Python libraries from Raku (formerly known as Perl 6).

# BUILDING

You will need a Python 3 built with the -fPIC option (position independent
code). Most distributions build their Python that way. To do this with pyenv,
use something like:

```
    PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.7
    pyenv global 3.7
    pyenv rehash
```

With a python in your path, then build:


```
    perl6 configure.pl6
    make test
    make install
```

Dockerfile examples with ubuntu dependencies are in df-amd/ and df-arm/ (e.g. docker pull p6steve/rakudo:inline-amd64-2021.05) then just go ```zef install -v Inline::Python --exclude="python3"```

# AUTHOR

Stefan Seifert <nine@detonation.org>
