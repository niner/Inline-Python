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
sub py_int_as_long(OpaquePointer)
    returns Int { ... }
    native(&py_int_as_long);

method py_to_p6(OpaquePointer $value) {
    if py_int_check($value) {
        return py_int_as_long($value);
    }
    return Any;
}

multi method run($python, :$eval!) {
    my $res = py_eval($python, 0);
    self.py_to_p6($res);
}

multi method run($python, :$file) {
    my $res = py_eval($python, 1);
    self.py_to_p6($res);
}

method BUILD {
    py_init_python();
}
