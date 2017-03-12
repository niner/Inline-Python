unit class Inline::Python;

our $default_python;

has &!call_object;
has &!call_method;

use NativeCall;

my constant $pyhelper = %?RESOURCES<libraries/pyhelper>.Str;

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

sub py_init_python(&call_object (int32, Pointer, Pointer --> Pointer), &call_method (int32, Str, Pointer, Pointer --> Pointer))
    is native($pyhelper)
    { ... }
sub py_init_perl6object()
    is native($pyhelper)
    { ... }
sub py_eval(Str, int32)
    is native($pyhelper)
    returns Pointer { ... }
sub py_import(Str)
    returns Pointer
    is native($pyhelper)
    { ... }
sub py_instance_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_is_instance(Pointer, Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_int_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_float_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_unicode_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_ascii_string_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_string_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_sequence_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_mapping_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_callable_check(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_is_none(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_int_as_long(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_int_to_py(int32)
    is native($pyhelper)
    returns Pointer { ... }
sub py_float_as_double(Pointer)
    is native($pyhelper)
    returns num64 { ... }
sub py_float_to_py(num64)
    is native($pyhelper)
    returns Pointer { ... }
sub py_unicode_as_utf8_string(Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_string_as_string(Pointer)
    is native($pyhelper)
    returns Str { ... }
sub py_string_to_buf(Pointer, CArray[CArray[int8]])
    is native($pyhelper)
    returns int32 { ... }
sub py_str_to_py(int32, Str)
    is native($pyhelper)
    returns Pointer { ... }
sub py_buf_to_py(int32, Blob)
    is native($pyhelper)
    returns Pointer { ... }
sub py_tuple_new(int32)
    is native($pyhelper)
    returns Pointer { ... }
sub py_tuple_set_item(Pointer, int32, Pointer)
    is native($pyhelper)
    { ... }
sub py_list_new(int32)
    is native($pyhelper)
    returns Pointer { ... }
sub py_list_set_item(Pointer, int32, Pointer)
    is native($pyhelper)
    { ... }
sub py_dict_new()
    is native($pyhelper)
    returns Pointer { ... }
sub py_dict_set_item(Pointer, Pointer, Pointer)
    is native($pyhelper)
    { ... }
sub py_call_function(Str, Str, Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_call_function_kw(Str, Str, Pointer, Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_call_static_method(Str, Str, Str, Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_call_static_method_kw(Str, Str, Str, Pointer, Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_call_method(Pointer, Str, Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_call_method_kw(Pointer, Str, Pointer, Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_sequence_length(Pointer)
    is native($pyhelper)
    returns int32 { ... }
sub py_sequence_get_item(Pointer, int32)
    is native($pyhelper)
    returns Pointer { ... }
sub py_mapping_items(Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_none()
    is native($pyhelper)
    returns Pointer { ... }
sub py_dec_ref(Pointer)
    is native($pyhelper)
    { ... }
sub py_inc_ref(Pointer)
    is native($pyhelper)
    { ... }
sub py_getattr(Pointer, Str)
    is native($pyhelper)
    returns Pointer { ... }
sub py_dir(Pointer)
    is native($pyhelper)
    returns Pointer { ... }
sub py_fetch_error(CArray[Pointer])
    is native($pyhelper)
    { ... }

method py_dec_ref(Pointer $obj) {
    py_dec_ref($obj);
}

my $objects = ObjectKeeper.new;

sub free_p6_object(Int $index) {
    $objects.free($index);
}

method py_array_to_array(Pointer $py_array) {
    my @array;
    my $len = py_sequence_length($py_array);
    for 0..^$len {
        my $item = py_sequence_get_item($py_array, $_);
        @array[$_] = self.py_to_p6($item);
        py_dec_ref($item);
    }
    return @array;
}

method py_dict_to_hash(Pointer $py_dict) {
    my %hash;
    my $py_items = py_mapping_items($py_dict);
    my $items = self.py_to_p6($py_items);
    py_dec_ref($py_items);
    %hash{$_[0]} = $_[1] for $items.list;
    return %hash;
}

my Pointer $perl6object;

method py_to_p6(Pointer $value) {
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

multi method p6_to_py(Int:D $value) returns Pointer {
    py_int_to_py($value);
}

multi method p6_to_py(Num:D $value) returns Pointer {
    py_float_to_py($value);
}

multi method p6_to_py(Rat:D $value) returns Pointer {
    py_float_to_py($value.Num);
}

multi method p6_to_py(Str:D $value) returns Pointer {
    py_str_to_py($value.encode('UTF-8').bytes, $value);
}

multi method p6_to_py(blob8:D $value) returns Pointer {
    py_buf_to_py($value.elems, $value);
}

multi method p6_to_py(Positional:D $value) returns Pointer {
    my $array = py_list_new($value.elems);
    for @$value.kv -> $i, $item {
        py_list_set_item($array, $i, self.p6_to_py($item));
    }
    return $array;
}

multi method p6_to_py(Hash:D $value) returns Pointer {
    my $dict = py_dict_new();
    for %$value -> $item {
        py_dict_set_item($dict, self.p6_to_py($item.key), self.p6_to_py($item.value));
    }
    return $dict;
}

multi method p6_to_py(PythonObject:D $value) {
    $value.ptr;
}

multi method p6_to_py(Pointer:D $value) {
    return $value;
}

multi method p6_to_py(Any:U $value) returns Pointer {
    py_none();
}

multi method p6_to_py(Any:D $value, Pointer $inst = Pointer) {
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

method !setup_arguments_kw(@args, %args) {
    my $len = @args.elems;
    my $tuple = py_tuple_new($len);
    loop (my int32 $i = 0; $i < $len; $i = $i + 1) {
        py_tuple_set_item($tuple, $i, self.p6_to_py(@args[$i]));
    }
    my $dict = py_dict_new();
    for %args -> $item {
        py_dict_set_item($dict, self.p6_to_py($item.key), self.p6_to_py($item.value));
    }
    return $tuple, $dict;
}

method handle_python_exception() is hidden-from-backtrace {
    my @exception := CArray[Pointer].new();
    @exception[$_] = Pointer for ^4;
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

method call(Str $package, Str $function, *@args, *%args) {
    my $py_retval = %args
        ?? py_call_function_kw($package, $function, |self!setup_arguments_kw(@args, %args))
        !! py_call_function($package, $function, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    return retval;
}

multi method invoke(Str $pkg, Str $class, Str $method, *@args, *%args) {
    my $py_retval = %args
        ?? py_call_static_method_kw($pkg, $class, $method, |self!setup_arguments_kw(@args, %args))
        !! py_call_static_method(   $pkg, $class, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}
multi method invoke(Pointer $obj, Str $method, *@args, *%args) {
    my $py_retval = %args
        ?? py_call_method_kw($obj, $method, |self!setup_arguments_kw(@args, %args))
        !! py_call_method(   $obj, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}
multi method invoke(PythonParent $p6obj, Pointer $obj, Str $method, *@args) {
    my $py_retval = py_call_method($obj, $method, self!setup_arguments(@args));
    self.handle_python_exception();
    my \retval = self.py_to_p6($py_retval);
    py_dec_ref($py_retval);
    return retval;
}

method import(Str $name) {
    my $py_module = py_import($name);
    my $module    = self.py_to_p6($py_module);

    my $class := Metamodel::ClassHOW.new_type(name => $name);

    my @parts = $name.split('.');
    my $inner = @parts.pop;
    my $stash := Stash.new;
    my $ns := $stash;
    for @parts {
        $ns{$_} := Metamodel::PackageHOW.new_type(name => $_);
        $ns := $ns{$_}.WHO;
    }
    $ns{$inner} := $class;

    my @attrs     = self.py_to_p6(py_dir($py_module));
    for @attrs -> $attr {
        my $attr_name = $attr ~~ Blob ?? $attr.decode('latin-1') !! $attr;
        next unless $attr_name;
        my $value = py_getattr($py_module, $attr_name);
        if py_callable_check($value) {
            # create wrapper function in package
            $class.WHO{"&$attr_name"} := sub (*@args, *%args) {
                self.call($name, $attr_name, |@args, |%args);
            }
        }
    }

    return CompUnit::Handle.from-unit($stash);
}

method create_subclass(Str $package, Str $class, Str $subclass_name) {
    my $subclass = ::($subclass_name);
    my $methods = $subclass\
        .^methods\
        .grep({$_.gist ~~ /^\w+$/})\
        .map({"    def {$_.gist}(self, *args): return perl6.invoke(self.__p6_index__, '{$_.gist}', args)"})\
        .join("\n");
    my $baseclass_name = $package eq '__main__' ?? $class !! "$package.$class";
    my $final_subclass_name = $subclass_name;
    $final_subclass_name ~~ s:g{'::'} = '__';
    self.run(qq:heredoc/PYTHON/ ~ $methods, :file);
        class {$final_subclass_name}($baseclass_name):
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
    my $final_class = $class;
    $final_class ~~ s:g{'::'} = '__';
    my $parent = py_call_function($package, $final_class, $tuple);
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

    &!call_object = sub (int32 $index, Pointer $args, Pointer $err) returns Pointer {
        my $p6obj = $objects.get($index);
        my \retvals = $p6obj(|self.py_array_to_array($args));
        return self.p6_to_py(retvals);
        CATCH {
            default {
                nativecast(CArray[Pointer], $err)[0] = self.p6_to_py($_.Str());
                return Pointer;
            }
        }
    }
    &!call_method = sub (int32 $index, Str $name, Pointer $args, Pointer $err) returns Pointer {
        my $p6obj = $objects.get($index);
        my \retvals = $p6obj."$name"(|self.py_array_to_array($args));
        return self.p6_to_py(retvals);
        CATCH {
            default {
                nativecast(CArray[Pointer], $err)[0] = self.p6_to_py($_.Str());
                return Pointer;
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
    has Pointer $.ptr;
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
        $!ptr = Pointer;
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
                $.python.invoke($.ptr, $name, |args.list, |args.hash);
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

CompUnit::RepositoryRegistry.use-repository(
    class :: does CompUnit::Repository {
        method need(
            CompUnit::DependencySpecification $spec,
            CompUnit::PrecompilationRepository $precomp?,
        )
            returns CompUnit:D
        {
            if $spec.from eq 'Python' {
                my $python = Inline::Python.default_python;

                if $*RAKUDO_MODULE_DEBUG -> $RMD {
                    $RMD("Loading {$spec.short-name} via Inline::Python");
                }
                my $handle := $python.import(
                    $spec.short-name,
                );
                return CompUnit.new(
                    :short-name($spec.short-name),
                    :$handle,
                    :repo(self),
                    :repo-id($spec.short-name),
                    :from($spec.from),
                );
            }

            return self.next-repo.need($spec, |($precomp ?? $precomp !! ())) if self.next-repo;
            X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw;
        }

        method loaded() {
            []
        }

        method id() {
            'Python'
        }

        method path-spec() {
            'python#'
        }
    }.new(),
    :current($*REPO),
)
