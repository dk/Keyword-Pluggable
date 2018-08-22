#!perl
use warnings FATAL => 'all';
use strict;

use Test::More tests => 3;

{
    package Foo;

    use Keyword::Pluggable;

    sub import {
        Keyword::Pluggable::define peek => sub {
            substr ${$_[0]}, 0, 0, "ok 1, 'synthetic test';";
        };
        Keyword::Pluggable::define poke => sub {
            substr ${$_[0]}, 0, 0, "ok 2, 'expression' + ' test';";
        }, 1;
    }

    sub unimport {
        Keyword::Pluggable::undefine 'peek';
        Keyword::Pluggable::undefine 'poke';
    }

    BEGIN { $INC{"Foo.pm"} = 1; }
}

use Foo;

peek
ok 1, "natural test";
ok 2, "expression test";
