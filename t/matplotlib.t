use v6;
use Inline::Python;
use Test;

use matplotlib::pyplot:from<Python>;

pass; # we don't segfault

done-testing;
