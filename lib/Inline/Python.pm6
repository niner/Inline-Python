class Inline::Python;

has &!call_object;
has &!call_method;

use NativeCall;

sub native(Sub $sub) {
    my $so = 'pyhelper.so';
    state Str $path;
    unless $path {
        for @*INC {
            if "$_/Inline/$so".IO ~~ :f {
                $path = "$_/Inline/$so";
                last;
            }
        }
    }
    unless $path {
        die "unable to find Inline/$so IN \@*INC";
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

sub py_init_python(&call_object(Int, OpaquePointer, OpaquePointer --> OpaquePointer), &call_method(Int, Str, OpaquePointer, OpaquePointer --> OpaquePointer))
    { ... }
    native(&py_init_python);
sub py_init_perl6object()
    { ... }
    native(&py_init_perl6object);
sub py_eval(Str, Int)
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
    returns Int { ... }
    native(&py_int_as_long);
sub py_int_to_py(Int)
    returns OpaquePointer { ... }
    native(&py_int_to_py);
sub py_float_as_double(OpaquePointer)
    returns num64 { ... }
    native(&py_float_as_double);
sub py_float_to_py(num64)
    returns OpaquePointer { ... }
    native(&py_float_to_py);
sub py_unicode_to_char_star(OpaquePointer)
    returns Str { ... }
    native(&py_unicode_to_char_star);
sub py_string_to_buf(OpaquePointer, CArray[CArray[int8]])
    returns Int { ... }
    native(&py_string_to_buf);
sub py_str_to_py(Int, Str)
    returns OpaquePointer { ... }
    native(&py_str_to_py);
sub py_buf_to_py(Int, CArray[uint8])
    returns OpaquePointer { ... }
    native(&py_buf_to_py);
sub py_tuple_new(Int)
    returns OpaquePointer { ... }
    native(&py_tuple_new);
sub py_tuple_set_item(OpaquePointer, Int, OpaquePointer)
    { ... }
    native(&py_tuple_set_item);
sub py_list_new(Int)
    returns OpaquePointer { ... }
    native(&py_list_new);
sub py_list_set_item(OpaquePointer, Int, OpaquePointer)
    { ... }
    native(&py_list_set_item);
sub py_dict_new()
    returns OpaquePointer { ... }
    native(&py_dict_new);
sub py_dict_set_item(OpaquePointer, OpaquePointer, OpaquePointer)
    { ... }
    native(&py_dict_set_item);
sub py_call_function(Str, Str, int, CArray[OpaquePointer])
    returns OpaquePointer { ... }
    native(&py_call_function);
sub py_call_method(OpaquePointer, Str, int, CArray[OpaquePointer])
    returns OpaquePointer { ... }
    native(&py_call_method);
sub py_call_method_inherited(OpaquePointer, OpaquePointer, Str, int, CArray[OpaquePointer])
    returns OpaquePointer { ... }
    native(&py_call_method_inherited);
sub py_sequence_length(OpaquePointer)
    returns int { ... }
    native(&py_sequence_length);
sub py_sequence_get_item(OpaquePointer, int)
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
sub py_fetch_error(CArray[OpaquePointer], CArray[OpaquePointer], CArray[OpaquePointer], CArray[OpaquePointer])
    { ... }
    native(&py_fetch_error);

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
        return py_unicode_to_char_star($value);
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
    my $array = CArray[uint8].new();
    for ^$value.elems {
        $array[$_] = $value[$_];
    }
    py_buf_to_py($value.elems, $array);
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
    loop (my Int $i = 0; $i < $len; $i = $i + 1) {
        py_tuple_set_item($tuple, $i, self.p6_to_py(@args[$i]));
    }
    return $tuple;
}

method handle_python_exception() is hidden_from_backtrace {
    my @exception := CArray[OpaquePointer].new();
    @exception[$_] = OpaquePointer for ^4;
    py_fetch_error(@exception);
    my $ex_type    = @exception[0];
    my $ex_message = @exception[3];
    if $ex_type {
        my $message = self.py_to_p6($ex_message);
        @exception[$_] and py_dec_ref(@exception[$_]) for ^4;
        die $message;
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

multi method invoke(OpaquePointer $obj, Str $method, *@args) {
    my $py_retval = py_call_method($obj, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}
multi method invoke(PythonParent $p6obj, OpaquePointer $obj, Str $method, *@args) {
    my $py_retval = py_call_method_inherited(self.p6_to_py($p6obj), $obj, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}

method py_getattr(OpaquePointer $obj, Str $name) {
    return py_getattr($obj, $name);
}

method BUILD {
    &!call_object = sub (Int $index, OpaquePointer $args, OpaquePointer $err) returns OpaquePointer {
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
    &!call_method = sub (Int $index, Str $name, OpaquePointer $args, OpaquePointer $err) returns OpaquePointer {
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
        import perl6
        from logging import warn
        from functools import partial
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

    method postcircumfix:<( )>(\args) {
        $.python.invoke($.ptr, '__call__', args.list);
    }

    method invoke(\args) {
        $.python.invoke($.ptr, '__call__', args.list);
    }

    method DESTROY {
        $!python.py_dec_ref($!ptr) if $!ptr;
        $!ptr = OpaquePointer;
    }
}

role PythonParent[$package, $class] {
    has $.parent;
    has $.python;

    submethod BUILD(:$python, :$parent?) {
        $!parent = $parent // $python.call($package, $class);
        $!python = $python;
        #$python.rebless($!parent);
    }

    method __getattr__($attr) {
        my $candidates = self.^can($attr);
        return (
            $candidates.elems
                ?? -> |args { $candidates[0](self, |args.list) }
                !! $.python.py_getattr($.parent.ptr, $attr)
        );
    }

    ::?CLASS.HOW.add_fallback(::?CLASS, -> $, $ { True },
        method ($name) {
            -> \self, |args {
                $.python.invoke(self, $.parent.ptr, $name, args.list);
            }
        }
    );
}

BEGIN {
    PythonObject.^add_fallback(-> $, $ { True },
        method ($name) {
            -> \self, |args {
                $.python.invoke($.ptr, $name, args.list);
            }
        }
    );
}
