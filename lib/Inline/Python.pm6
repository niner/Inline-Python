unit class Inline::Python;

our $default_python;

has &!call_object;
has &!call_method;

use NativeCall;

sub native(Sub $sub) {
    my Str $path = %?RESOURCES<libraries/pyhelper>.Str;
    unless $path {
        die "unable to find pyhelper library";
    }
    trait_mod:<is>($sub, :native($path));
}

class PythonObject { ... }
role PythonParent { ... }

class ObjectKeeper {
    has @!objects;
    has $!last_free = -1;

    method keep(Any:D $value) returns Int {
        if $!last_free != -1 {
            my $index = $!last_free;
            $!last_free = @!objects[$!last_free];
            @!objects[$index] = $value;
            return $index;
        }
        else {
            @!objects.push($value);
            return @!objects.end;
        }
    }

    method get(Int $index) returns Any:D {
        @!objects[$index];
    }

    method free(Int $index) {
        @!objects[$index] = $!last_free;
        $!last_free = $index;
    }
}

sub py_init_python(&call_object (int32, OpaquePointer, OpaquePointer --> OpaquePointer), &call_method (int32, Str, OpaquePointer, OpaquePointer --> OpaquePointer))
    { ... }
    native(&py_init_python);
sub py_init_perl6object()
    { ... }
    native(&py_init_perl6object);
sub py_eval(Str, int32)
    returns OpaquePointer { ... }
    native(&py_eval);
sub py_instance_check(OpaquePointer)
    returns int32 { ... }
    native(&py_instance_check);
sub py_is_instance(OpaquePointer, OpaquePointer)
    returns int32 { ... }
    native(&py_is_instance);
sub py_int_check(OpaquePointer)
    returns int32 { ... }
    native(&py_int_check);
sub py_float_check(OpaquePointer)
    returns int32 { ... }
    native(&py_float_check);
sub py_unicode_check(OpaquePointer)
    returns int32 { ... }
    native(&py_unicode_check);
sub py_string_check(OpaquePointer)
    returns int32 { ... }
    native(&py_string_check);
sub py_sequence_check(OpaquePointer)
    returns int32 { ... }
    native(&py_sequence_check);
sub py_mapping_check(OpaquePointer)
    returns int32 { ... }
    native(&py_mapping_check);
sub py_callable_check(OpaquePointer)
    returns int32 { ... }
    native(&py_callable_check);
sub py_is_none(OpaquePointer)
    returns int32 { ... }
    native(&py_is_none);
sub py_int_as_long(OpaquePointer)
    returns int32 { ... }
    native(&py_int_as_long);
sub py_int_to_py(int32)
    returns OpaquePointer { ... }
    native(&py_int_to_py);
sub py_float_as_double(OpaquePointer)
    returns num64 { ... }
    native(&py_float_as_double);
sub py_float_to_py(num64)
    returns OpaquePointer { ... }
    native(&py_float_to_py);
sub py_unicode_as_utf8_string(OpaquePointer)
    returns OpaquePointer { ... }
    native(&py_unicode_as_utf8_string);
sub py_string_as_string(OpaquePointer)
    returns Str { ... }
    native(&py_string_as_string);
sub py_string_to_buf(OpaquePointer, CArray[CArray[int8]])
    returns int32 { ... }
    native(&py_string_to_buf);
sub py_str_to_py(int32, Str)
    returns OpaquePointer { ... }
    native(&py_str_to_py);
sub py_buf_to_py(int32, Blob)
    returns OpaquePointer { ... }
    native(&py_buf_to_py);
sub py_tuple_new(int32)
    returns OpaquePointer { ... }
    native(&py_tuple_new);
sub py_tuple_set_item(OpaquePointer, int32, OpaquePointer)
    { ... }
    native(&py_tuple_set_item);
sub py_list_new(int32)
    returns OpaquePointer { ... }
    native(&py_list_new);
sub py_list_set_item(OpaquePointer, int32, OpaquePointer)
    { ... }
    native(&py_list_set_item);
sub py_dict_new()
    returns OpaquePointer { ... }
    native(&py_dict_new);
sub py_dict_set_item(OpaquePointer, OpaquePointer, OpaquePointer)
    { ... }
    native(&py_dict_set_item);
sub py_call_function(Str, Str, OpaquePointer)
    returns OpaquePointer { ... }
    native(&py_call_function);
sub py_call_static_method(Str, Str, Str, OpaquePointer)
    returns OpaquePointer { ... }
    native(&py_call_static_method);
sub py_call_method(OpaquePointer, Str, OpaquePointer)
    returns OpaquePointer { ... }
    native(&py_call_method);
sub py_sequence_length(OpaquePointer)
    returns int32 { ... }
    native(&py_sequence_length);
sub py_sequence_get_item(OpaquePointer, int32)
    returns OpaquePointer { ... }
    native(&py_sequence_get_item);
sub py_mapping_items(OpaquePointer)
    returns OpaquePointer { ... }
    native(&py_mapping_items);
sub py_none()
    returns OpaquePointer { ... }
    native(&py_none);
sub py_dec_ref(OpaquePointer)
    { ... }
    native(&py_dec_ref);
sub py_inc_ref(OpaquePointer)
    { ... }
    native(&py_inc_ref);
sub py_getattr(OpaquePointer, Str)
    returns OpaquePointer { ... }
    native(&py_getattr);
sub py_fetch_error(CArray[OpaquePointer])
    { ... }
    native(&py_fetch_error);

method py_dec_ref(OpaquePointer $obj) {
    py_dec_ref($obj);
}

my $objects = ObjectKeeper.new;

sub free_p6_object(Int $index) {
    $objects.free($index);
}

method py_array_to_array(OpaquePointer $py_array) {
    my $array = [];
    my $len = py_sequence_length($py_array);
    for 0..^$len {
        my $item = py_sequence_get_item($py_array, $_);
        $array[$_] = self.py_to_p6($item);
        py_dec_ref($item);
    }
    return $array;
}

method py_dict_to_hash(OpaquePointer $py_dict) {
    my %hash;
    my $py_items = py_mapping_items($py_dict);
    my $items = self.py_to_p6($py_items);
    py_dec_ref($py_items);
    %hash{$_[0]} = $_[1] for $items.list;
    return %hash;
}

my OpaquePointer $perl6object;

method py_to_p6(OpaquePointer $value) {
    return Any unless defined $value;
    if py_is_none($value) {
        return Any;
    }
    elsif py_instance_check($value) or py_callable_check($value) {
        if py_is_instance($value, $perl6object) {
            return $objects.get(
                py_int_as_long(
                    py_call_method(
                        $value,
                        'get_perl6_object',
                        self!setup_arguments([])
                    )
                )
            );
        }
        else {
            py_inc_ref($value);
            return PythonObject.new(python => self, ptr => $value);
        }
    }
    elsif py_int_check($value) {
        return py_int_as_long($value);
    }
    elsif py_float_check($value) {
        return py_float_as_double($value);
    }
    elsif py_unicode_check($value) {
        my $string = py_unicode_as_utf8_string($value) or return;
        my $p6_str = py_string_as_string($string);
        py_dec_ref($string);
        return $p6_str;
    }
    elsif py_string_check($value) {
        my $string_ptr = CArray[CArray[int8]].new;
        $string_ptr[0] = CArray[int8];
        my $len = py_string_to_buf($value, $string_ptr);
        my $buf = Buf.new;
        for 0..^$len {
            $buf[$_] = $string_ptr[0][$_];
        }
        return $buf;

    }
    elsif py_sequence_check($value) {
        return self.py_array_to_array($value);
    }
    elsif py_mapping_check($value) {
        return self.py_dict_to_hash($value);
    }
    return Any;
}

multi method p6_to_py(Int:D $value) returns OpaquePointer {
    py_int_to_py($value);
}

multi method p6_to_py(Num:D $value) returns OpaquePointer {
    py_float_to_py($value);
}

multi method p6_to_py(Rat:D $value) returns OpaquePointer {
    py_float_to_py($value.Num);
}

multi method p6_to_py(Str:D $value) returns OpaquePointer {
    py_str_to_py($value.encode('UTF-8').bytes, $value);
}

multi method p6_to_py(blob8:D $value) returns OpaquePointer {
    py_buf_to_py($value.elems, $value);
}

multi method p6_to_py(Positional:D $value) returns OpaquePointer {
    my $array = py_list_new($value.elems);
    for @$value.kv -> $i, $item {
        py_list_set_item($array, $i, self.p6_to_py($item));
    }
    return $array;
}

multi method p6_to_py(Hash:D $value) returns OpaquePointer {
    my $dict = py_dict_new();
    for %$value -> $item {
        py_dict_set_item($dict, self.p6_to_py($item.key), self.p6_to_py($item.value));
    }
    return $dict;
}

multi method p6_to_py(PythonObject:D $value) {
    $value.ptr;
}

multi method p6_to_py(OpaquePointer:D $value) {
    return $value;
}

multi method p6_to_py(Any:U $value) returns OpaquePointer {
    py_none();
}

multi method p6_to_py(Any:D $value, OpaquePointer $inst = OpaquePointer) {
    my $index = $objects.keep($value);

    return py_call_function('__main__', 'Perl6Object', self!setup_arguments([$index]));
}

method !setup_arguments(@args) {
    my $len = @args.elems;
    my $tuple = py_tuple_new($len);
    loop (my int32 $i = 0; $i < $len; $i = $i + 1) {
        py_tuple_set_item($tuple, $i, self.p6_to_py(@args[$i]));
    }
    return $tuple;
}

method handle_python_exception() is hidden-from-backtrace {
    my @exception := CArray[OpaquePointer].new();
    @exception[$_] = OpaquePointer for ^4;
    py_fetch_error(@exception);
    my $ex_type    = @exception[0];
    my $ex_message = @exception[3];
    if $ex_type {
        my $message = self.py_to_p6($ex_message);
        @exception[$_] and py_dec_ref(@exception[$_]) for ^4;
        die $message.decode('UTF-8');
    }
}

multi method run($python, :$eval!) {
    my $res = py_eval($python, 0);
    self.handle_python_exception();
    self.py_to_p6($res);
}

multi method run($python, :$file) {
    my $res = py_eval($python, 1);
    self.handle_python_exception();
    self.py_to_p6($res);
}

method call(Str $package, Str $function, *@args) {
    my $py_retval = py_call_function($package, $function, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    return retval;
}

multi method invoke(Str $pkg, Str $class, Str $method, *@args) {
    my $py_retval = py_call_static_method($pkg, $class, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}
multi method invoke(OpaquePointer $obj, Str $method, *@args) {
    my $py_retval = py_call_method($obj, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}
multi method invoke(PythonParent $p6obj, OpaquePointer $obj, Str $method, *@args) {
    my $py_retval = py_call_method($obj, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}

method py_getattr(OpaquePointer $obj, Str $name) {
    return py_getattr($obj, $name);
}

method create_subclass(Str $package, Str $class, Str $subclass_name) {
    my $subclass = ::($subclass_name);
    my $methods = $subclass\
        .^methods\
        .grep({$_.gist ~~ /^\w+$/})\
        .map({"    def {$_.gist}(self, *args): return perl6.invoke(self.__p6_index__, '{$_.gist}', args)"})\
        .join("\n");
    my $baseclass_name = $package eq '__main__' ?? $class !! "$package.$class";
    self.run(qq:heredoc/PYTHON/ ~ $methods, :file);
        class {$subclass_name}($baseclass_name):
            def __init__(self, i, *args):
                if i is not None:
                    self.__set_p6_index__(i)
                if hasattr({$baseclass_name}, '__init__'):
                    {$baseclass_name}.__init__(self, *args)
            def __set_p6_index__(self, i):
                self.__p6_index__ = i
        PYTHON
    CATCH {
        default {
            die "$_ trying to create subclass $subclass_name from $package.$class";
        }
    }
}

method create_parent_object(Str $package, Str $class, PythonParent $obj) returns PythonObject {
    my $tuple = py_tuple_new(1);
    my $index = $objects.keep($obj);
    py_tuple_set_item($tuple, 0, self.p6_to_py($index));
    my $parent = py_call_function($package, $class, $tuple);
    self.handle_python_exception();
    return self.py_to_p6($parent);
}

method upgrade_parent_object(PythonObject $parent, PythonParent $obj) {
    my $tuple = py_tuple_new(1);
    my $index = $objects.keep($obj);
    py_tuple_set_item($tuple, 0, self.p6_to_py($index));
    my $py_retval = py_call_method($parent.ptr, '__set_p6_index__', $tuple);
    self.handle_python_exception();
    return;
}

method BUILD {
    $default_python = self;

    &!call_object = sub (int32 $index, OpaquePointer $args, OpaquePointer $err) returns OpaquePointer {
        my $p6obj = $objects.get($index);
        my \retvals = $p6obj(|self.py_array_to_array($args));
        return self.p6_to_py(retvals);
        CATCH {
            default {
                nativecast(CArray[OpaquePointer], $err)[0] = self.p6_to_py($_.Str());
                return OpaquePointer;
            }
        }
    }
    &!call_method = sub (int32 $index, Str $name, OpaquePointer $args, OpaquePointer $err) returns OpaquePointer {
        my $p6obj = $objects.get($index);
        my \retvals = $p6obj."$name"(|self.py_array_to_array($args));
        return self.p6_to_py(retvals);
        CATCH {
            default {
                nativecast(CArray[OpaquePointer], $err)[0] = self.p6_to_py($_.Str());
                return OpaquePointer;
            }
        }
    }

    py_init_python(&!call_object, &!call_method);

    self.run(q:heredoc/PYTHON/);
        import signal
        import perl6
        from functools import partial
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        class Perl6Object:
            def __init__(self, index):
                self.index = index
            def get_perl6_object(self):
                return self.index
            def __call__(self, *args):
                return perl6.call(self.index, args)
            def __getattr__(self, attr):
                if attr == '__p6_getattr__':
                    raise AttributeError(attr)
                if not hasattr(self, '__p6_getattr__'):
                    self.__p6_getattr__ = perl6.invoke(self.index, 'can', [u"__getattr__"])
                if len(self.__p6_getattr__):
                    return self.__p6_getattr__[0](self, attr.decode('UTF-8'))
                else:
                    candidates = perl6.invoke(self.index, 'can', [attr.decode('UTF-8')])
                    if not len(candidates):
                        raise AttributeError(attr)
                    return partial(candidates[0], self)
                return lambda *args: perl6.invoke(self.index, attr, args)
        PYTHON

    py_init_perl6object();

    $perl6object = py_eval('Perl6Object', 0);
}

class PythonObject {
    has OpaquePointer $.ptr;
    has Inline::Python $.python;

    method sink() { self }

    method postcircumfix:<( )>(*@args) {
        $.python.invoke($.ptr, '__call__', |@args);
    }

    method CALL-ME(*@args) {
        $.python.invoke($.ptr, '__call__', |@args);
    }

    method DESTROY {
        $!python.py_dec_ref($!ptr) if $!ptr;
        $!ptr = OpaquePointer;
    }
}

role PythonParent[$package, $class] {
    has $.parent;
    my %python_subclass_created;

    submethod BUILD(:$parent?) {
        unless (%python_subclass_created{::?CLASS.^name}) {
            %python_subclass_created{::?CLASS.^name} = True;

            $default_python.create_subclass($package, $class, ::?CLASS.^name);
        }
        $default_python.upgrade_parent_object($parent, self) if $parent;
        $!parent = $parent // $default_python.create_parent_object('__main__', ::?CLASS.^name, self);
    }

    ::?CLASS.HOW.add_fallback(::?CLASS, -> $, $ { True },
        method ($name) {
            -> \self, |args {
                $default_python.invoke(self, $.parent.ptr, $name, args.list);
            }
        }
    );
}

method default_python {
    $default_python //= self.new;
}

BEGIN {
    PythonObject.^add_fallback(-> $, $ { True },
        method ($name) {
            -> \self, |args {
                $.python.invoke($.ptr, $name, args.list);
            }
        }
    );
    for Any.^methods>>.name -> $name {
        PythonObject.^add_method(
            $name,
            method (|args) {
                $.python.invoke($.ptr, $name, args.list);
            }
        );
    }
    PythonObject.^compose;
}

multi sub EVAL(
        Cool $code,
        Str :$lang where { ($lang // '') eq 'Python' },
        PseudoStash :$context,
        :$mode = 'eval') is export {
    my $py = Inline::Python.default_python;
    CATCH { note $_ }
    $py.run($code, |($mode eq 'eval' ?? :eval !! :file));
}
