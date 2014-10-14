class Inline::Python;

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

sub py_init_python()
    { ... }
    native(&py_init_python);
sub py_eval(Str, Int)
    returns OpaquePointer { ... }
    native(&py_eval);
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
sub py_sequence_length(OpaquePointer)
    returns int { ... }
    native(&py_sequence_length);
sub py_sequence_get_item(OpaquePointer, int)
    returns OpaquePointer { ... }
    native(&py_sequence_get_item);
sub py_mapping_items(OpaquePointer)
    returns OpaquePointer { ... }
    native(&py_mapping_items);
sub py_dec_ref(OpaquePointer)
    { ... }
    native(&py_dec_ref);

method py_array_to_array(OpaquePointer $py_array) {
    my @array = [];
    my $len = py_sequence_length($py_array);
    for 0..^$len {
        my $item = py_sequence_get_item($py_array, $_);
        @array[$_] = self.py_to_p6($item);
        py_dec_ref($item);
    }
    return @array;
}

method py_dict_to_hash(OpaquePointer $py_dict) {
    my %hash;
    my $items = py_mapping_items($py_dict);
    my @items = self.py_to_p6($items);
    py_dec_ref($items);
    %hash{$_[0]} = $_[1] for @items;
    return %hash;
}

method py_to_p6(OpaquePointer $value) {
    if py_int_check($value) {
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

method !setup_arguments(@args) {
    my $len = @args.elems;
    my $tuple = py_tuple_new($len);
    loop (my Int $i = 0; $i < $len; $i = $i + 1) {
        py_tuple_set_item($tuple, $i, self.p6_to_py(@args[$i]));
    }
    return $tuple;
}

multi method run($python, :$eval!) {
    my $res = py_eval($python, 0);
    self.py_to_p6($res);
}

multi method run($python, :$file) {
    my $res = py_eval($python, 1);
    self.py_to_p6($res);
}

method call(Str $package, Str $function, *@args) {
    return self.py_to_p6(py_call_function($package, $function, self!setup_arguments(@args)));
}

method BUILD {
    py_init_python();
}
