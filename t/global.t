#!perl
use warnings FATAL => 'all';
use strict;

use Test::More tests => 4;

BEGIN {
    package Foo;

    use Keyword::Pluggable;

    Keyword::Pluggable::define peek => sub {
        substr ${$_[0]}, 0, 0, "ok 1, 'synthetic test 1';";
    }, 0, 1;
    Keyword::Pluggable::define poke => sub {
        substr ${$_[0]}, 0, 0, "ok 2, 'synthetic test 2';";
    }, 1, 1;
}

{
	package Bar;
	peek
	ok 1, "natural test 1";
	poke
	ok 2, "natural test 2";
}
